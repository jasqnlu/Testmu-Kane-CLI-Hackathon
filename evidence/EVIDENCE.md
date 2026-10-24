# Weave evidence index

**Submission status: not ready.** M1 auth and group flows now have a validated Kane pack. Later product flows and submission gates remain open. Empty cells below mean unverified, not passing.

| Requirement | Test file | Red pack | Green pack | What Kane caught |
| --- | --- | --- | --- | --- |
| AUTH-01 | Tests/Kane/auth/existing-user-sees-their-name-after-sign-in_test.md; Tests/Kane/auth/reject-invalid-credentials-without-exposing-a-group_test.md; Tests/Kane/auth/keep-a-user-signed-out-when-sign-in-fails_test.md | — | [M1_auth_groups_smoke.evidence](packs/M1_auth_groups_smoke.evidence) | Kane passed valid sign-in, invalid credentials, and forced sign-in failure; user stayed signed out on errors. |
| GROUP-01 | Tests/Kane/groups/show-alice-s-study-members-and-40-credit-balance_test.md; Tests/Kane/groups/show-error-instead-of-fetched-data-when-study-group-fetch_test.md | — | [M1_auth_groups_smoke.evidence](packs/M1_auth_groups_smoke.evidence) | Kane passed member/balance display and the fetch-error state with no fetched balance or members. |
| CREDIT-01 | Pending | — | — | Not yet verified |
| CREDIT-02 | Pending | — | — | Not yet verified |
| EXT-01 | Pending | — | — | Not yet verified |
| EXT-02 | Pending | — | — | Not yet verified |
| EXT-03 | Pending | — | — | Not yet verified |
| RECOV-01 | [show-failure-and-restore-credits-after-failed-activation_test.md](../Tests/Kane/extensions/show-failure-and-restore-credits-after-failed-activation_test.md) | [RECOV-01_red_20261024.evidence](packs/RECOV-01_red_20261024.evidence) | Pending | Kane confirmed that failed mock activation left the group balance at 30 instead of restoring 40. |
| PRIV-01 | Pending | — | — | Not yet verified |
| SHARE-01 | Pending | — | — | Not yet verified |
| SHARE-02 | Pending | — | — | Not yet verified |
| AI-01 | Pending | — | — | Not yet verified |
| AI-02 | Pending | — | — | Not yet verified |
| SAFE-01 | Pending | — | — | Not yet verified |

## Final demo evidence

- Journey (`journey_final.evidence`): pending.
- Smoke suite (`smoke_final.evidence`): pending.
- Merged submission pack (`weave-final`): pending.
- M1 Kane coverage: 9 of 46 criteria proven, 37 owed (25.9% risk-weighted coverage); [Kane cover report](coverage-m1.ndjson) and [validated pack](packs/M1_auth_groups_smoke.evidence). Historical M0 report: [coverage](coverage-m0.ndjson) and [gaps](coverage-gaps-m0.ndjson).

Validate selected packs with `kane-cli evidence validate <path>` before indexing them. View a saved pack locally with `kane-cli evidence serve evidence/packs/<file>`.

## What Kane caught

- **Environment issue — M1 headless sign-in:** The ad hoc signed simulator app had no Keychain access group, so its first saved-session lookup failed. This was an environment issue, not a product bug; simulator-only Debug builds now store the session in the app sandbox.
- **RECOV-01 — failed activation kept the debit:** Pre-guard run `c0448d15-2859-40a5-ace0-c7ec70f39f85` (execution `8c24563e-1539-46e7-a1cf-931214f0e697`) confirmed the group balance stayed at 30 credits instead of the asserted 40, and the app showed a device-application error. A confirmed extension remained visible with an expiry. Full red evidence is in [RECOV-01_red_20261024.evidence](packs/RECOV-01_red_20261024.evidence); no fix has been applied yet.

## Not verified by Kane

- Ledger concurrency (CREDIT-01): requires SQL concurrency tests; execution pending.
- RLS privacy (PRIV-01 database half): requires SQL security tests; execution pending.
- M1 authenticated API/RLS privilege probes passed outside Kane; see [safe backend summary](backend-m1-api-checks.json). Dedicated SQL concurrency and privacy tests remain pending.
- Real Screen Time shielding: requires a physical device; not verified at hackathon. Simulator uses a deterministic mock provider.
- Release debug exclusion (SAFE-01): requires code review and unit/build checks; execution pending.

## Submission gates still open

- Public repository confirmed; existing October23 Pacific documentation history requires organizer interpretation of the same-day gate.
- Product OpenAI call verified from the Supabase draft-card Edge Function.
- Real red→green pair, green journey, and green smoke suite saved and validated.
- Requirement-linked committed replay tests, completed assurance loop, and exploration recorded.
- AI privacy gate passed five times; fallback checked.
- Final merged pack path identified for attachment.

## M0 setup evidence

| Check | Test | Result | Pack |
| --- | --- | --- | --- |
| Blank sign-in shell (setup only) | Tests/Kane/setup/m0_signin_smoke_test.md | Live objective passed, exit 0; not AUTH-01 | [M0_signin_green.evidence](packs/M0_signin_green.evidence) |

| Saved replay (setup only) | Tests/Kane/setup/m0_signin_smoke_test.md | test_md_done passed + exit 0 | [M0_replay_green.evidence](packs/M0_replay_green.evidence) |
| Build + setup suite | Scripts/verify.sh smoke | 1/1 passed, testrun_done + exit 0 | [M0_setup_suite_green.evidence](packs/M0_setup_suite_green.evidence) |

## M1 auth and group evidence

| Check | Test | Result | Pack |
| --- | --- | --- | --- |
| Auth, groups, setup smoke | `Scripts/verify.sh smoke` | 6/6 passed, 0 failed/broken/skipped, testrun_done + exit 0; 9 criteria proven across AUTH-01 and GROUP-01 | [M1_auth_groups_smoke.evidence](packs/M1_auth_groups_smoke.evidence) |

The first auth attempt exposed a simulator-only session-store failure because the headless Kane build is ad hoc signed without a Keychain access group. The test was stopped before its completion event; it is not a feature pass. Simulator builds now keep their test session in the app sandbox, while device builds continue to use Keychain. The rerun and full M1 smoke suite passed. The simulator store contains test credentials only and is not used by device builds.

All three integrity validations exited 0. Initial attempts found an Xcode27 Simulator.app path incompatibility and a saved-test relative ZIP path error; neither is product red/green evidence. Authentication, credits, privacy, AI and full journey remain unverified. Raw agent streams and assurance verdicts are retained alongside this index.
