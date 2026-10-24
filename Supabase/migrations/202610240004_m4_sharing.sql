begin;

create table public.private_extension_reasons (
  extension_id uuid primary key references public.group_extensions(id) on delete cascade,
  group_id uuid not null references public.groups(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  reason text not null check (length(reason) between 1 and 500),
  share_state text not null default 'pending' check (share_state in ('pending', 'private', 'shared')),
  created_at timestamptz not null default clock_timestamp()
);
alter table public.private_extension_reasons enable row level security;
create policy private_reason_owner_read on public.private_extension_reasons
  for select to authenticated using (user_id = auth.uid());
revoke all on public.private_extension_reasons from public, anon, authenticated;
grant select on public.private_extension_reasons to authenticated;

create table public.group_feed_cards (
  id uuid primary key default gen_random_uuid(),
  extension_id uuid not null unique references public.group_extensions(id) on delete cascade,
  group_id uuid not null references public.groups(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  body text not null check (length(body) between 1 and 500),
  created_at timestamptz not null default clock_timestamp()
);
alter table public.group_feed_cards enable row level security;
create policy feed_member_read on public.group_feed_cards for select to authenticated
  using (public.weave_is_group_member(group_id));
revoke all on public.group_feed_cards from public, anon, authenticated;
grant select on public.group_feed_cards to authenticated;

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
      order by ge.created_at desc limit 1),
    'completed_extension', (select jsonb_build_object('id', ge.id, 'minutes', ge.minutes,
      'reason', r.reason, 'share_state', r.share_state)
      from public.group_extensions ge join public.private_extension_reasons r on r.extension_id = ge.id
      where ge.group_id = v_group.id and ge.user_id = v_user and ge.status = 'completed'
        and r.share_state in ('pending', 'private')
      order by ge.created_at desc limit 1)
  );
end; $$;
revoke all on function public.group_snapshot() from public, anon;
grant execute on function public.group_snapshot() to authenticated;

create or replace function public.group_feed()
returns jsonb language plpgsql stable security definer set search_path = ''
as $$
declare v_user uuid := auth.uid(); v_group uuid;
begin
  if v_user is null then raise exception 'Sign in to view the feed' using errcode = '42501'; end if;
  select gm.group_id into v_group from public.group_members gm where gm.user_id = v_user order by gm.group_id limit 1;
  if v_group is null then raise exception 'No group found for this user' using errcode = 'P0002'; end if;
  -- Straightforward baseline: every completed reason appears in the feed. Kane's privacy test
  -- must run against this baseline before the sharing filter is added.
  return coalesce((
    select jsonb_agg(jsonb_build_object('id', ge.id, 'user_name', p.display_name,
      'body', coalesce(c.body, r.reason), 'created_at', extract(epoch from ge.created_at)::bigint)
      order by ge.created_at desc)
    from public.group_extensions ge
    join public.private_extension_reasons r on r.extension_id = ge.id
    join public.profiles p on p.id = ge.user_id
    left join public.group_feed_cards c on c.extension_id = ge.id
    where ge.group_id = v_group and ge.status = 'completed'
  ), '[]'::jsonb);
end; $$;
revoke all on function public.group_feed() from public, anon;
grant execute on function public.group_feed() to authenticated;

create or replace function public.choose_extension_sharing(
  p_extension_id uuid, p_reason text, p_share boolean, p_body text default null
)
returns jsonb language plpgsql security definer set search_path = ''
as $$
declare v_user uuid := auth.uid(); v_group uuid; v_reason text;
begin
  if v_user is null then raise exception 'Sign in to save sharing choice' using errcode = '42501'; end if;
  if p_extension_id is null then raise exception 'Completed extension is required' using errcode = '22023'; end if;
  if p_reason is null or length(btrim(p_reason)) not between 1 and 500 then
    raise exception 'A private reason is required' using errcode = '22023';
  end if;
  select ge.group_id into v_group from public.group_extensions ge
    where ge.id = p_extension_id and ge.user_id = v_user and ge.status in ('active', 'completed');
  if v_group is null then raise exception 'Completed extension not found' using errcode = 'P0002'; end if;
  perform 1 from public.groups g where g.id = v_group for update;
  insert into public.private_extension_reasons(extension_id, group_id, user_id, reason)
    values (p_extension_id, v_group, v_user, btrim(p_reason))
    on conflict (extension_id) do update set reason = excluded.reason
    returning reason into v_reason;
  update public.group_extensions set status = 'completed'
    where id = p_extension_id and user_id = v_user and status = 'active';
  if p_share then
    if p_body is null or length(btrim(p_body)) not between 1 and 500 then
      raise exception 'A reviewed card is required' using errcode = '22023';
    end if;
    update public.private_extension_reasons set share_state = 'shared' where extension_id = p_extension_id;
    insert into public.group_feed_cards(extension_id, group_id, user_id, body)
      values (p_extension_id, v_group, v_user, btrim(p_body))
      on conflict (extension_id) do update set body = excluded.body;
  else
    update public.private_extension_reasons set share_state = 'private' where extension_id = p_extension_id;
    delete from public.group_feed_cards where extension_id = p_extension_id and user_id = v_user;
  end if;
  return public.group_snapshot();
end; $$;
revoke all on function public.choose_extension_sharing(uuid, text, boolean, text) from public, anon;
grant execute on function public.choose_extension_sharing(uuid, text, boolean, text) to authenticated;

create or replace function public.debug_seed_private_reason()
returns jsonb language plpgsql security definer set search_path = ''
as $$
declare v_user uuid := auth.uid(); v_group uuid; v_extension uuid;
begin
  select tm.group_id into v_group from weave_private.test_members tm
    where tm.user_id = v_user and tm.group_id = 'a11ce000-0000-4000-8000-000000000001'::uuid;
  if v_group is null then raise exception 'Test account required' using errcode = '42501'; end if;
  perform 1 from public.groups g where g.id = v_group for update;
  delete from public.group_extensions where group_id = v_group;
  update public.groups set balance = 40 where id = v_group;
  insert into public.group_extensions(group_id, user_id, minutes, credits, status, expires_at)
    values (v_group, v_user, 10, 10, 'completed', clock_timestamp()) returning id into v_extension;
  insert into public.private_extension_reasons(extension_id, group_id, user_id, reason)
    values (v_extension, v_group, v_user, 'chemistry test anxiety');
  return public.group_snapshot();
end; $$;
revoke all on function public.debug_seed_private_reason() from public, anon;
grant execute on function public.debug_seed_private_reason() to authenticated;

notify pgrst, 'reload schema';
commit;
