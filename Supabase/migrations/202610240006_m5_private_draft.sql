begin;

create or replace function public.store_private_extension_reason(
  p_extension_id uuid,
  p_reason text
)
returns void language plpgsql security definer set search_path = ''
as $$
declare
  v_user uuid := auth.uid();
  v_group uuid;
begin
  if v_user is null then raise exception 'Sign in to save your reason' using errcode = '42501'; end if;
  if p_extension_id is null then raise exception 'An extension is required' using errcode = '22023'; end if;
  if p_reason is null or length(btrim(p_reason)) not between 1 and 500 then
    raise exception 'A private reason is required' using errcode = '22023';
  end if;

  select ge.group_id into v_group
    from public.group_extensions ge
    where ge.id = p_extension_id
      and ge.user_id = v_user
      and ge.status in ('active', 'completed')
    for update;
  if v_group is null then raise exception 'Extension not found' using errcode = 'P0002'; end if;

  insert into public.private_extension_reasons(extension_id, group_id, user_id, reason, share_state)
    values (p_extension_id, v_group, v_user, btrim(p_reason), 'private')
    on conflict (extension_id) do update
      set reason = excluded.reason,
          share_state = 'private';
end;
$$;
revoke all on function public.store_private_extension_reason(uuid, text) from public, anon;
grant execute on function public.store_private_extension_reason(uuid, text) to authenticated;

notify pgrst, 'reload schema';
commit;
