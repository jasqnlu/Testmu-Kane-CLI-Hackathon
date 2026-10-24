begin;

create or replace function public.group_feed()
returns jsonb language plpgsql stable security definer set search_path = ''
as $$
declare v_user uuid := auth.uid(); v_group uuid;
begin
  if v_user is null then raise exception 'Sign in to view the feed' using errcode = '42501'; end if;
  select gm.group_id into v_group from public.group_members gm where gm.user_id = v_user order by gm.group_id limit 1;
  if v_group is null then raise exception 'No group found for this user' using errcode = 'P0002'; end if;
  return coalesce((
    select jsonb_agg(jsonb_build_object('id', c.id, 'user_name', p.display_name,
      'body', c.body, 'created_at', extract(epoch from c.created_at)::bigint)
      order by c.created_at desc)
    from public.group_feed_cards c
    join public.private_extension_reasons r on r.extension_id = c.extension_id
    join public.profiles p on p.id = c.user_id
    where c.group_id = v_group and r.share_state = 'shared'
  ), '[]'::jsonb);
end; $$;
revoke all on function public.group_feed() from public, anon;
grant execute on function public.group_feed() to authenticated;

notify pgrst, 'reload schema';
commit;
