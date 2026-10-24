begin;
create schema if not exists weave_private;
revoke all on schema weave_private from public, anon, authenticated;

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null check (length(display_name) between 1 and 80)
);
create table public.groups (
  id uuid primary key default gen_random_uuid(),
  name text not null check (length(name) between 1 and 80),
  balance integer not null default 0 check (balance >= 0)
);
create table public.group_members (
  group_id uuid not null references public.groups(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  primary key (group_id, user_id)
);
create index group_members_user_id_idx on public.group_members(user_id);
create table weave_private.test_members (
  user_id uuid primary key references auth.users(id) on delete cascade,
  group_id uuid not null references public.groups(id) on delete cascade
);

-- Definer helpers consult membership without recursively evaluating table policies.
create function public.weave_is_group_member(p_group_id uuid)
returns boolean language sql stable security definer set search_path = ''
as $$ select exists(select 1 from public.group_members gm where gm.group_id = p_group_id and gm.user_id = auth.uid()); $$;
create function public.weave_can_view_profile(p_user_id uuid)
returns boolean language sql stable security definer set search_path = ''
as $$ select auth.uid() = p_user_id or exists (
  select 1 from public.group_members mine join public.group_members theirs on theirs.group_id = mine.group_id
  where mine.user_id = auth.uid() and theirs.user_id = p_user_id
); $$;
revoke all on function public.weave_is_group_member(uuid), public.weave_can_view_profile(uuid) from public, anon;
grant execute on function public.weave_is_group_member(uuid), public.weave_can_view_profile(uuid) to authenticated;

alter table public.profiles enable row level security;
alter table public.groups enable row level security;
alter table public.group_members enable row level security;
create policy profiles_read_shared on public.profiles for select to authenticated using (public.weave_can_view_profile(id));
create policy groups_read_member on public.groups for select to authenticated using (public.weave_is_group_member(id));
create policy members_read_group on public.group_members for select to authenticated using (public.weave_is_group_member(group_id));
revoke all on public.profiles, public.groups, public.group_members from anon, authenticated;
grant select on public.profiles, public.groups, public.group_members to authenticated;

create function public.group_snapshot()
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
  return jsonb_build_object('user_name', v_name, 'group_id', v_group.id, 'group_name', v_group.name,
    'balance', v_group.balance, 'members', (select coalesce(jsonb_agg(jsonb_build_object('id',p.id,'name',p.display_name) order by p.display_name),'[]'::jsonb)
      from public.group_members gm join public.profiles p on p.id = gm.user_id where gm.group_id = v_group.id));
end; $$;
revoke all on function public.group_snapshot() from public, anon;
grant execute on function public.group_snapshot() to authenticated;

-- Test fixture only: identity allowlist + fixed owned group; no arbitrary balance argument.
create function public.debug_reset_normal()
returns jsonb language plpgsql security definer set search_path = ''
as $$
declare v_group uuid;
begin
  select tm.group_id into v_group from weave_private.test_members tm
    where tm.user_id = auth.uid() and tm.group_id = 'a11ce000-0000-4000-8000-000000000001'::uuid;
  if v_group is null then raise exception 'Test account required' using errcode = '42501'; end if;
  perform 1 from public.groups where id = v_group for update;
  update public.groups set balance = 40 where id = v_group;
  return public.group_snapshot();
end; $$;
revoke all on function public.debug_reset_normal() from public, anon;
grant execute on function public.debug_reset_normal() to authenticated;
notify pgrst, 'reload schema';
commit;
