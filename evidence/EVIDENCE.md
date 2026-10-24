# Weave evidence index

**Submission status: not ready.** Validated M0 setup packs are indexed below; product-feature evidence remains pending. Empty cells below mean unverified, not passing.

| Requirement | Test file | Red pack | Green pack | What Kane caught |
| --- | --- | --- | --- | --- |
| AUTH-01 | Pending | — | — | Not yet verified |
| GROUP-01 | Pending | — | — | Not yet verified |
| CREDIT-01 | Pending | — | — | Not yet verified |
| CREDIT-02 | Pending | — | — | Not yet verified |
| EXT-01 | Pending | — | — | Not yet verified |
| EXT-02 | Pending | — | — | Not yet verified |
| EXT-03 | Pending | — | — | Not yet verified |
| RECOV-01 | Pending | — | — | Not yet verified |
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
- Assurance coverage: [report](coverage-m0.ndjson) and [gaps](coverage-gaps-m0.ndjson), 5/5 use cases designed; 0% product requirements proven.

Validate selected packs with `kane-cli evidence validate <path>` before indexing them. View a saved pack locally with `kane-cli evidence serve evidence/packs/<file>`.

## Not verified by Kane

- Ledger concurrency (CREDIT-01): requires SQL concurrency tests; execution pending.
- RLS privacy (PRIV-01 database half): requires SQL security tests; execution pending.
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

All three integrity validations exited 0. Initial attempts found an Xcode27 Simulator.app path incompatibility and a saved-test relative ZIP path error; neither is product red/green evidence. Authentication, credits, privacy, AI and full journey remain unverified. Raw agent streams and assurance verdicts are retained alongside this index.
