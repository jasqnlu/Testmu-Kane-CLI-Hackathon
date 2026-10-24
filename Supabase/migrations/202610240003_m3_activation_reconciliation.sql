begin;

create or replace function public.release_reservation(p_extension_id uuid)
returns jsonb language plpgsql security definer set search_path = ''
as $$
declare
  v_user uuid := auth.uid();
  v_group uuid;
  v_credits integer;
  v_status text;
begin
  if v_user is null then
    raise exception 'Sign in to release the extension reservation' using errcode = '42501';
  end if;
  if p_extension_id is null then
    raise exception 'Extension reservation is required' using errcode = '22023';
  end if;

  select ge.group_id into v_group
    from public.group_extensions ge
    where ge.id = p_extension_id and ge.user_id = v_user;
  if v_group is null then
    raise exception 'Extension reservation not found' using errcode = 'P0002';
  end if;

  -- Use the same lock order as confirmation. The status transition makes retries idempotent.
  perform 1 from public.groups g where g.id = v_group for update;
  select ge.credits, ge.status into v_credits, v_status
    from public.group_extensions ge
    where ge.id = p_extension_id and ge.group_id = v_group and ge.user_id = v_user
    for update;
  if not found then
    raise exception 'Extension reservation not found' using errcode = 'P0002';
  end if;

  if v_status = 'active' then
    update public.group_extensions
      set status = 'failed'
      where id = p_extension_id and group_id = v_group and user_id = v_user and status = 'active';
    if found then
      update public.groups set balance = balance + v_credits where id = v_group;
    end if;
  end if;

  return public.group_snapshot();
end; $$;
revoke all on function public.release_reservation(uuid) from public, anon;
grant execute on function public.release_reservation(uuid) to authenticated;

notify pgrst, 'reload schema';
commit;
