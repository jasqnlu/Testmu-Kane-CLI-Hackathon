# Weave backend

Project `wwlbaihtcyyfxoesyytr` hosts Weave. The M1 migration creates profiles, groups, group membership, membership-safe RLS helpers, and authenticated snapshot/reset RPCs. The M2 migration adds group extensions, quote/confirm RPCs, and an allowlisted low-balance fixture. Application roles cannot directly insert, update, or delete balances, memberships, or extensions.

Run `Scripts/configure-backend.py` after authenticating the Supabase CLI with permission to manage the project. It creates only the three owned, confirmed `@weave.test` accounts and the fixed Study test group. It preserves unrelated accounts/data and refuses to adopt preexisting accounts without its ownership marker and locally saved credentials. It merges test variables into the ignored Kane variables file. Secrets are never printed.

Local generated contracts:

- `Config/Backend.json`: `{"url":"https://wwlbaihtcyyfxoesyytr.supabase.co","anonKey":"<public client key>"}`.
- `Config/TestAccounts.json`: lowercase `alice`, `bob`, `charlie` objects, each containing `email`, `password`, and `id`. Include only in DEBUG app builds.
- `.supabase/admin-keys.json`: server administration key; never bundle in an app.

All generated configuration/credentials are gitignored with file mode 600. The OpenAI key is not needed at M1 and must later be configured only as a Supabase secret. `OPENAI_MODEL` and `OPENAI_API_KEY` were absent when secret names were checked at M1 setup.

Use `/auth/v1/token?grant_type=password` to sign in and pass the returned access token as the Bearer token, with the client key in `apikey`, for both RPCs:

- `POST /rest/v1/rpc/group_snapshot` with `{}`: returns `{"user_name":"Alice","group_id":"<uuid>","group_name":"Study","balance":40,"members":[{"id":"<uuid>","name":"Alice"},...]}`. Rejects missing identity/group/profile.
- `POST /rest/v1/rpc/debug_reset_normal` with `{}`: available only to the allowlisted seeded identities and fixed owned Study test group; locks the group row, clears test extensions, restores 40 credits, and returns the group snapshot. It has no arbitrary group or balance input. Client controls calling it belong under `#if DEBUG`.
- `POST /rest/v1/rpc/extension_quote` with `{"p_minutes":10}`: returns the user's quote. M2 deliberately adds its quote-time low-balance rejection only after the requirement-linked red run proves the UI currently offers a quote at 5 credits; `confirm_extension` already rejects insufficient balance atomically.
- `POST /rest/v1/rpc/confirm_extension` with `{"p_minutes":10}`: locks the Study group row, rechecks the balance, deducts 10 credits, records the active expiry, and returns the updated group snapshot. The client cannot mutate balance directly.
- `POST /rest/v1/rpc/release_reservation` with `{"p_extension_id":"<extension uuid>"}`: locks the group row, marks the signed-in user's active extension as failed, refunds its credits once, and returns the updated snapshot. Repeating the call does not refund again.
- `POST /rest/v1/rpc/debug_seed_low_balance` with `{}`: available only to fixed owned test identities and Study; clears test extensions and sets the group to 5 credits, without caller-supplied group or balance.

Apply migrations in order to a freshly configured project:

```sh
supabase db query --linked --project-ref wwlbaihtcyyfxoesyytr --file Supabase/migrations/202610240001_m1_auth_groups.sql --output json
supabase db query --linked --project-ref wwlbaihtcyyfxoesyytr --file Supabase/migrations/202610240002_m2_extensions.sql --output json
supabase db query --linked --project-ref wwlbaihtcyyfxoesyytr --file Supabase/migrations/202610240003_m3_activation_reconciliation.sql --output json
```

`Scripts/seed.sh normal` ensures the owned membership/profile fixtures and performs the reset using Alice's authenticated session, then checks the returned snapshot. `Scripts/seed.sh low-balance` uses the authenticated allowlisted fixture RPC to set the fixed Study group to 5 credits. Private-reason seed remains deferred to M4. Safe setup summaries are written under `evidence/`; authenticated API checks are not Kane UI passes.

Documentation consulted: [Supabase RLS](https://supabase.com/docs/guides/database/postgres/row-level-security), [Auth admin user creation](https://supabase.com/docs/reference/javascript/auth-admin-createuser), and [Management API query execution](https://supabase.com/docs/reference/api/v1-run-a-query).
