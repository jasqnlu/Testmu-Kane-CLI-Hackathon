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
- `POST /rest/v1/rpc/group_feed` with `{}`: returns only explicitly shared group activity cards. Private reasons are stored in an owner-readable RLS table and are never selected into the group feed.
- `POST /rest/v1/rpc/choose_extension_sharing` with an extension ID, reason, share choice, and reviewed body: completes the extension and stores the owner's reason; a shared card is published only when the owner chooses Share with Group and posts it.
- `POST /rest/v1/rpc/store_private_extension_reason` with `p_extension_id` and `p_reason`: saves the signed-in owner's reason privately before drafting. It accepts only the owner's active or completed extension and does not publish a card.
- `POST /rest/v1/rpc/debug_seed_private_reason` with `{}`: DEBUG-only fixture for Alice's completed extension, private reason, and sharing choice.
- `POST /functions/v1/draft-card` with an authenticated extension ID and non-private facts: loads the reason only through its owner-only RLS policy, sends only minutes, time of day, and achievement to OpenAI, then checks candidate text against the private reason and retries once if it overlaps. A contaminated or invalid draft returns the plain fallback. `OPENAI_API_KEY` is a Supabase secret; `OPENAI_MODEL` is optional and defaults to `gpt-6-luna`.

Apply migrations in order to a freshly configured project:

```sh
supabase db query --linked --project-ref wwlbaihtcyyfxoesyytr --file Supabase/migrations/202610240001_m1_auth_groups.sql --output json
supabase db query --linked --project-ref wwlbaihtcyyfxoesyytr --file Supabase/migrations/202610240002_m2_extensions.sql --output json
supabase db query --linked --project-ref wwlbaihtcyyfxoesyytr --file Supabase/migrations/202610240003_m3_activation_reconciliation.sql --output json
supabase db query --linked --project-ref wwlbaihtcyyfxoesyytr --file Supabase/migrations/202610240004_m4_sharing.sql --output json
supabase db query --linked --project-ref wwlbaihtcyyfxoesyytr --file Supabase/migrations/202610240005_m4_private_feed_filter.sql --output json
supabase db query --linked --project-ref wwlbaihtcyyfxoesyytr --file Supabase/migrations/202610240006_m5_private_draft.sql --output json
supabase functions deploy draft-card --project-ref wwlbaihtcyyfxoesyytr
```

Set `OPENAI_API_KEY` using Supabase project secrets before testing the OpenAI path. Never store it in the app, repository, or Kane variable files. The function returns the editable plain card when the key is absent or a generation fails.

`Scripts/seed.sh normal` ensures the owned membership/profile fixtures and performs the reset using Alice's authenticated session, then checks the returned snapshot. `Scripts/seed.sh low-balance` uses the authenticated allowlisted fixture RPC to set the fixed Study group to 5 credits. The private-reason fixture is an authenticated DEBUG-only RPC. Safe setup summaries are written under `evidence/`; authenticated API checks are not Kane UI passes.

Documentation consulted: [Supabase RLS](https://supabase.com/docs/guides/database/postgres/row-level-security), [Auth admin user creation](https://supabase.com/docs/reference/javascript/auth-admin-createuser), and [Management API query execution](https://supabase.com/docs/reference/api/v1-run-a-query).
