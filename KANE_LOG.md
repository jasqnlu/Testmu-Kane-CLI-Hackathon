# Kane run log

M0 setup checks passed. M1 auth and group smoke passed after fixing a headless simulator session-storage issue. M2–M6 are pending. A pending or environment-failed check is never a product pass.

## Session environment

- Date: 2026-10-24 (America/Los_Angeles).
- Kane version: 0.10.0-rc.3.
- Starting balance: 101,078.2211 credits (preflight, authenticated).
- Simulator device and OS: iPhone 17 Pro, iOS 26.5 (exact Kane device listing).
- Blank-app smoke result: live run, saved replay and setup suite passed with exit 0.

## Runs

| Time | Test / objective | Requirement | Result / exit | Classification | What changed next |
| --- | --- | --- | --- | --- | --- |

| 2026-10-24 11:11–11:13 PDT | m0_signin_smoke | M0 setup | ENVIRONMENT / exit 2; no run_end | environment | App installed/uploaded; driver could not find /Applications/Xcode.app/Contents/Developer/Applications/Simulator.app. No UI steps ran; locate simulator UI before retry. |

| 2026-10-24 11:15–11:17 PDT | m0_signin_smoke headless retry | M0 setup | PASSED / exit 0; run_end passed | environment repaired | Verified Email, Password, Sign in and sign-in screen; preserved saved test/cache; next replay and setup-only suite. Kane version 0.10.0-rc.3. |

| 2026-10-24 11:18 PDT | m0_signin_smoke saved replay | M0 setup | ENVIRONMENT / exit 2; no test_md_done | test metadata | Relative app path resolved below test directory; corrected area-test app paths to ../../../builds/Weave.zip. No UI steps ran; rerun same test. |

| 2026-10-24 11:18–11:20 PDT | m0_signin_smoke saved replay, corrected ZIP path | M0 setup | PASSED / exit 0; test_md_done passed | test metadata fixed | Replay completed in 52 seconds (cached execution 4.94s); evidence saved. Next: documented build + setup suite. |

| 2026-10-24 11:20–11:21 PDT | Scripts/verify.sh smoke (M0 setup only) | M0 setup | PASSED / exit 0; testrun_done passed | verification | Build succeeded; 1/1 replayed test passed, 0 skipped/broken; suite evidence validated. Next: backend selection for M1. |

| 2026-10-24 11:32–11:34 PDT | M1 existing-user sign-in, first attempt | AUTH-01 | STOPPED / exit 130; no test_md_done | simulator integration | Screenshot showed "Couldn't access your saved sign-in" before network sign-in. Headless app is ad hoc signed and has no Keychain access group. Added app-sandbox session storage for simulator builds only; iOS device builds retain Keychain. No pass claimed. |

| 2026-10-24 11:35–11:38 PDT | Existing-user sign-in rerun | AUTH-01 | PASSED / exit 0; test_md_done passed | verification | Supabase accepted Alice's credentials; Kane saw "Hi, Alice" and final_state `signed_in_user_name_shown=true`. |

| 2026-10-24 11:39–11:57 PDT | `Scripts/verify.sh smoke` (M1) | AUTH-01, GROUP-01 | PASSED / exit 0; testrun_done passed | verification | 6/6 passed, 0 failed/broken/skipped; 9 criteria proven. Pack validated at `evidence/packs/M1_auth_groups_smoke.evidence`. Next: M2 extensions, insufficient-credit red test first. |

| 2026-10-24 11:35 PDT | Release simulator scan (first pass) | SAFE-01 | BUILD PASSED / scan failed | security review | No local credentials or Debug controls found, but the simulator session key identifier was present in the Release executable. Narrowed the sandbox session store to `DEBUG && targetEnvironment(simulator)` and reran the full suite. |

| 2026-10-24 11:59–12:07 PDT | `Scripts/verify.sh smoke` (post-guard fix) | AUTH-01, GROUP-01 | PASSED / exit 0; testrun_done passed | regression check | 6/6 passed, 0 failed/broken/skipped; 9 criteria proven. All six members now replayed. Updated pack at `evidence/packs/M1_auth_groups_smoke.evidence` validated. |

For failures, record the failing step, expected versus observed outcome, screenshot path inside the evidence pack, and stored final-state values. Label honest red evidence as **feature-not-yet-implemented** or **found-by-exploration**. Record all attempts, including environment failures.

## Unresolved

- M2–M6 feature work remains: extension ledger, safety/recovery, privacy/sharing, OpenAI card, and full journey.
- Product OpenAI call, SQL concurrency/RLS checks, a genuine red→green pair, exploration, five AI privacy runs, and final journey pack remain pending.
- Dedicated SQL concurrency and RLS tests are still required. Existing authenticated API privilege probes are summarized in `evidence/backend-m1-api-checks.json`.

## Setup and assurance events

- 2026-10-24 11:07 PDT: simulator doctor exit 2; sandbox denied CoreSimulator access and managed driver missing. Installed driver with elevated permissions; doctor rerun exit 0. No product assertion ran.
- 2026-10-24: requirements ingest exit 0. Extraction exit 1 with EPERM creating Kane assurance logs outside workspace; environment failure, no product coverage. Retrying with elevated access.
- Public repo confirmed. Existing commits dcaaed9 and 3f1a6a8 are October 23 Pacific (October 24 UTC); they contain pre-existing scaffolding. History preserved; all-code-today gate needs judge interpretation.

- 2026-10-24 11:10 PDT: elevated extraction complete, exit 0; 5 use cases reviewed against source citations and approved per master spec. Mapping and verdicts saved in Requirements/. Next: design each approved use case.
- 2026-10-24 11:10 PDT: M0 build exit 65 at codesign due Desktop Finder/iCloud metadata; simulator-only signing disabled, rebuild exit 0. No UI verification claimed from build.

- 2026-10-24 11:20 PDT: assurance designs uc-1 through uc-5 all completed with process exit 0. 19 feature tests retained; 5/5 use cases designed. `cover` and `cover gaps` exit 0; product requirements 0% proven. 101,078.2211 credits remain. Generated criteria approval, fixture variables, SQL-only checks and live feature runs remain open.

## M1 session (project confirmed by user)

- User confirmed project wwlbaihtcyyfxoesyytr, renamed Weave. Public schema was empty before migration. M1 schema and three owned test accounts created; no unrelated data reset.
- Preflight: Kane0.10.0-rc.3 authenticated, simulator doctor passed; starting balance101,078.2211.
- Backend authenticated seed/API/RLS privilege checks passed; these are not Kane UI passes. Safe summaries: evidence/backend-m1-api-checks.json and backend-m1-seed.json.
- Before UI verification, read-only review found delayed group fetch/refresh could restore a signed-out identity or stale group. Fixing session generation invalidation before the first M1 Kane run; this was code review, not a Kane catch.
- OPENAI_API_KEY and OPENAI_MODEL absent from Supabase secret-name listing; user asked to set API key through dashboard, no key requested in chat.
- M1 suite completed at 11:57 PDT: all six smoke cases passed; detailed criterion coverage is in the validated run pack. The initial simulator-store failure and simulator-only fix are recorded above.
- A second six-case M1 suite passed at 12:07 PDT after restricting simulator storage to Debug. The deterministic session race checks passed 5/5. Release compile and final no-debug/no-fixture scan are completing before the M1 commit.
