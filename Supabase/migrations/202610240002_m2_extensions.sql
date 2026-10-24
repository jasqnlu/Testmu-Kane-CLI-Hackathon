begin;

create table if not exists public.group_extensions (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.groups(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  minutes integer not null check (minutes = 10),
  credits integer not null check (credits = 10),
  status text not null default 'active' check (status in ('active', 'completed', 'cancelled', 'failed')),
  created_at timestamptz not null default clock_timestamp(),
  expires_at timestamptz not null
);
create index if not exists group_extensions_user_active_idx
  on public.group_extensions(user_id, expires_at desc) where status = 'active';
alter table public.group_extensions enable row level security;
revoke all on public.group_extensions from public, anon, authenticated;

create or replace function public.group_snapshot()
returns jsonb language plpgsql stable security definer set search_path = ''
as $$
declare v_user uuid := auth.uid(); v_group public.groups%rowtype; v_name text;
begin
  if v_user is null then raise exception 'Sign in to view your group' using errcode = '42501'; end if;
  select g.* into v_group from public.groups g join public.group_members gm on gm.group_id = g.id
    where gm.user_id = v_user order by g.id limit 1;
  if not found then raise exception 'No group found for this user' using errcode = 'P0002'; end if;
  select p.display_name into v_name from public.profiles p where p.id = v_user;
  if v_name is null then raise exception 'User profile is missing' using errcode = 'P0002'; end if;
  return jsonb_build_object(
    'user_name', v_name,
    'group_id', v_group.id,
    'group_name', v_group.name,
    'balance', v_group.balance,
    'members', (select coalesce(jsonb_agg(jsonb_build_object('id',p.id,'name',p.display_name) order by p.display_name),'[]'::jsonb)
      from public.group_members gm join public.profiles p on p.id = gm.user_id where gm.group_id = v_group.id),
    'active_extension', (select jsonb_build_object('id', ge.id, 'minutes', ge.minutes,
      'expires_at', extract(epoch from ge.expires_at)::bigint)
      from public.group_extensions ge where ge.group_id = v_group.id and ge.user_id = v_user
        and ge.status = 'active' and ge.expires_at > statement_timestamp()
      order by ge.created_at desc limit 1)
  );
end; $$;
revoke all on function public.group_snapshot() from public, anon;
grant execute on function public.group_snapshot() to authenticated;

create or replace function public.debug_reset_normal()
returns jsonb language plpgsql security definer set search_path = ''
as $$
declare v_group uuid;
begin
  select tm.group_id into v_group from weave_private.test_members tm
    where tm.user_id = auth.uid() and tm.group_id = 'a11ce000-0000-4000-8000-000000000001'::uuid;
  if v_group is null then raise exception 'Test account required' using errcode = '42501'; end if;
  perform 1 from public.groups where id = v_group for update;
  delete from public.group_extensions where group_id = v_group;
  update public.groups set balance = 40 where id = v_group;
  return public.group_snapshot();
end; $$;
revoke all on function public.debug_reset_normal() from public, anon;
grant execute on function public.debug_reset_normal() to authenticated;

create or replace function public.debug_seed_low_balance()
returns jsonb language plpgsql security definer set search_path = ''
as $$
declare v_group uuid;
begin
  select tm.group_id into v_group from weave_private.test_members tm
    where tm.user_id = auth.uid() and tm.group_id = 'a11ce000-0000-4000-8000-000000000001'::uuid;
  if v_group is null then raise exception 'Test account required' using errcode = '42501'; end if;
  perform 1 from public.groups where id = v_group for update;
  delete from public.group_extensions where group_id = v_group;
  update public.groups set balance = 5 where id = v_group;
  return public.group_snapshot();
end; $$;
revoke all on function public.debug_seed_low_balance() from public, anon;
grant execute on function public.debug_seed_low_balance() to authenticated;

create or replace function public.extension_quote(p_minutes integer)
returns jsonb language plpgsql stable security definer set search_path = ''
as $$
declare v_user uuid := auth.uid(); v_group uuid; v_balance integer;
begin
  if v_user is null then raise exception 'Sign in to request extra time' using errcode = '42501'; end if;
  if p_minutes <> 10 then raise exception 'Unsupported extension length' using errcode = '22023'; end if;
  select gm.group_id into v_group from public.group_members gm where gm.user_id = v_user order by gm.group_id limit 1;
  if v_group is null then raise exception 'No group found for this user' using errcode = 'P0002'; end if;
  select g.balance into v_balance from public.groups g where g.id = v_group;
  return jsonb_build_object('minutes', p_minutes, 'cost', p_minutes, 'balance', v_balance);
end; $$;
revoke all on function public.extension_quote(integer) from public, anon;
grant execute on function public.extension_quote(integer) to authenticated;

create or replace function public.confirm_extension(p_minutes integer)
returns jsonb language plpgsql security definer set search_path = ''
as $$
declare v_user uuid := auth.uid(); v_group uuid; v_balance integer;
begin
  if v_user is null then raise exception 'Sign in to confirm extra time' using errcode = '42501'; end if;
  if p_minutes <> 10 then raise exception 'Unsupported extension length' using errcode = '22023'; end if;
  select gm.group_id into v_group from public.group_members gm where gm.user_id = v_user order by gm.group_id limit 1;
  if v_group is null then raise exception 'No group found for this user' using errcode = 'P0002'; end if;
  select g.balance into v_balance from public.groups g where g.id = v_group for update;
  if v_balance < p_minutes then raise exception 'Not enough group credits' using errcode = 'P0001'; end if;
  update public.groups set balance = balance - p_minutes where id = v_group;
  insert into public.group_extensions(group_id, user_id, minutes, credits, expires_at)
    values (v_group, v_user, p_minutes, p_minutes, clock_timestamp() + make_interval(mins => p_minutes));
  return public.group_snapshot();
end; $$;
revoke all on function public.confirm_extension(integer) from public, anon;
grant execute on function public.confirm_extension(integer) to authenticated;

notify pgrst, 'reload schema';
commit;
