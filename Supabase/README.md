# M1 backend

Project `wwlbaihtcyyfxoesyytr` hosts Weave. The initial public schema was empty before M1 deployment. The migration creates profiles, groups, group membership, membership-safe RLS helpers, and two authenticated RPCs. Application roles can select permitted rows but cannot insert, update, or delete balances or memberships. Credit reservation functions are deferred to M2.

Run `Scripts/configure-backend.py` after authenticating the Supabase CLI with permission to manage the project. It creates only the three owned, confirmed `@weave.test` accounts and the fixed Study test group. It preserves unrelated accounts/data and refuses to adopt preexisting accounts without its ownership marker and locally saved credentials. It merges test variables into the ignored Kane variables file. Secrets are never printed.

Local generated contracts:

- `Config/Backend.json`: `{"url":"https://wwlbaihtcyyfxoesyytr.supabase.co","anonKey":"<public client key>"}`.
- `Config/TestAccounts.json`: lowercase `alice`, `bob`, `charlie` objects, each containing `email`, `password`, and `id`. Include only in DEBUG app builds.
- `.supabase/admin-keys.json`: server administration key; never bundle in an app.

All generated configuration/credentials are gitignored with file mode 600. The OpenAI key is not needed at M1 and must later be configured only as a Supabase secret. `OPENAI_MODEL` and `OPENAI_API_KEY` were absent when secret names were checked at M1 setup.

Use `/auth/v1/token?grant_type=password` to sign in and pass the returned access token as the Bearer token, with the client key in `apikey`, for both RPCs:

- `POST /rest/v1/rpc/group_snapshot` with `{}`: returns `{"user_name":"Alice","group_id":"<uuid>","group_name":"Study","balance":40,"members":[{"id":"<uuid>","name":"Alice"},...]}`. Rejects missing identity/group/profile.
- `POST /rest/v1/rpc/debug_reset_normal` with `{}`: available only to the allowlisted seeded identities and fixed owned Study test group; locks the group row, restores 40 credits, and returns the same snapshot. It has no arbitrary group or balance input. Client controls calling it belong under `#if DEBUG`.

`Scripts/seed.sh normal` ensures the owned membership/profile fixtures and performs the reset using Alice's authenticated session, then checks the returned snapshot. `low-balance` and `private-reason` deliberately exit 2 until their milestones implement their server data. The safe setup summary is written to `evidence/backend-m1-seed.json`. An authenticated API check is not a Kane UI pass.

Documentation consulted: [Supabase RLS](https://supabase.com/docs/guides/database/postgres/row-level-security), [Auth admin user creation](https://supabase.com/docs/reference/javascript/auth-admin-createuser), and [Management API query execution](https://supabase.com/docs/reference/api/v1-run-a-query).
