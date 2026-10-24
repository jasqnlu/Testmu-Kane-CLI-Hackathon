-- Run after Scripts/seed.sh private-reason. The fixed test identity is Bob.
begin;
set local role authenticated;
select set_config('request.jwt.claim.sub', '714f2b4f-874d-41e1-9781-d0d1bf857bd1', true);
select not exists (
  select 1 from public.private_extension_reasons
  where reason = 'chemistry test anxiety'
) as bob_cannot_read_alice_private_reason;
rollback;
