# Kane run log

M0 setup checks passed. M1 auth and group smoke passed after fixing a headless simulator session-storage issue. M2 extension paths now pass on the current worktree; the required red-before-guard evidence is still missing. M3–M6 remain pending. A pending or environment-failed check is never a product pass.

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

| 2026-10-24 11:58 PDT | Release simulator scan (first pass) | SAFE-01 | BUILD PASSED / scan failed | security review | No local credentials or Debug controls found, but the simulator session key identifier was present in the Release executable. Narrowed the sandbox session store to `DEBUG && targetEnvironment(simulator)` and reran the full suite. |

| 2026-10-24 11:59–12:07 PDT | `Scripts/verify.sh smoke` (post-guard fix) | AUTH-01, GROUP-01 | PASSED / exit 0; testrun_done passed | regression check | 6/6 passed, 0 failed/broken/skipped; 9 criteria proven. All six members now replayed. Updated pack at `evidence/packs/M1_auth_groups_smoke.evidence` validated. |

| 2026-10-24 12:08 PDT | Release simulator build + scan (final) | SAFE-01 | PASSED / build exit 0, scan exit 0 | security review | No local account values, simulator-store marker, or Debug identifiers in the Release executable. Family Controls capability is absent. |

| 2026-10-24 12:10 PDT | `./Scripts/run-demo.sh` | Demo launcher | PASSED / exit 0 | script verification | Built unsigned Debug app, booted iPhone 17 Pro (iOS 26.5), installed `com.jasonlu.weave`, and launched it with `simctl`. |

For failures, record the failing step, expected versus observed outcome, screenshot path inside the evidence pack, and stored final-state values. Label honest red evidence as **feature-not-yet-implemented** or **found-by-exploration**. Record all attempts, including environment failures.

## Unresolved

- M2 is green but lacks its intended pre-guard CREDIT-02 red because the guard was already present at session start. M3 RECOV-01 is green with a preserved red/green pair; CREDIT-01 SQL concurrency verification remains pending. M4 privacy/sharing is in progress; M5 OpenAI card and M6 full journey remain.
- Product OpenAI call, CREDIT-01 SQL concurrency and RLS checks, five AI privacy runs, and final journey pack remain pending. RECOV-01 has a genuine pre-guard red→green pair; the M3 bughunt ended in an agent misstep and no confirmed finding.
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
- A second six-case M1 suite passed at 12:07 PDT after restricting simulator storage to Debug. The deterministic session race checks passed 5/5. Release compile and final no-debug/no-fixture scan passed.
- M1 implementation committed as `ccd62d6` at 12:08:55 PDT, after the final 6/6 Kane run passed. Release compile/scan and the unsigned demo launcher both passed.

## M2 session (extension flow)

- Session-start Kane preflight: `kane-cli 0.10.0-rc.3`, authenticated; balance **100,764.3736** credits. `devices list` returned zero simulators. `doctor --target simulator` and `doctor --target simulator --install` both found Xcode 27.0 but could not connect to CoreSimulatorService (environment failure; no feature result).
- Started the M2 implementation after the dedicated `docs: spec update` commit. The existing CREDIT-02 test is requirement-linked; preserve its red-before-guard order.
- The M2 code and migration were already present in the uncommitted worktree when this session began. The confirm-side balance check was already in that migration, so no pre-guard red was run or claimed. Applied the current migration to the confirmed Weave project; the authenticated low-balance fixture returned Study / 5 credits. The current migration checks the locked balance before deduction and extension creation.
- Build: the sandboxed `Scripts/build-sim.sh` failed because Swift's macro server could not run under the sandbox. The approved build completed successfully with Xcode 27 and produced `builds/Weave.zip`.
- 2026-10-24 12:36:21 PDT | `reject-a-ten-minute-request-at-five-credits_test.md` | CREDIT-02 | ENVIRONMENT / exit 2; no `test_md_done` | simulator setup | `xcrun` could not reach CoreSimulatorService in the sandbox; no UI steps ran.
- 2026-10-24 12:36:51 PDT | `reject-a-ten-minute-request-at-five-credits_test.md` | CREDIT-02 | ENVIRONMENT / exit 2; no `test_md_done` | simulator startup | App installed, then Xcode 27's missing `Simulator.app` caused the automation session to disappear; no assertions ran.
- 2026-10-24 12:37:58 PDT | `reject-a-ten-minute-request-at-five-credits_test.md` | CREDIT-02 | ENVIRONMENT / exit 2; no `test_md_done` | simulator startup | Explicit app/device settings still hit the missing `Simulator.app`; no assertions ran.
- 2026-10-24 12:39:20 PDT | `reject-a-ten-minute-request-at-five-credits_test.md` | CREDIT-02 | ENVIRONMENT / exit 2; no `test_md_done` | simulator startup | Retried after stopping stale Appium/WebDriverAgent processes; same missing `Simulator.app` error, no assertions ran. `Tests/Kane/HEADLESS.md` documents the wrapper that resolved startup.
- 2026-10-24 12:40–12:44 PDT | `reject-a-ten-minute-request-at-five-credits_test.md` | CREDIT-02 | PASSED (`test_md_done`, exit 0; 169s) | Kane | At 5 credits, request declined with “Not enough group credits”; balance stayed 5 and no extension activated. Criteria AC-13, AC-20, AC-21, AC-22 passed.
- 2026-10-24 12:44–12:48 PDT | `confirm-cost-then-activate-ten-minutes-at-thirty-credits_test.md` | EXT-01, EXT-02 | PASSED (`test_md_done`, exit 0; 186s) | Kane | Quote showed 10 minutes / 10 credits with balance unchanged at 40; confirm deducted to 30 and displayed an active extension with a valid expiry. Criteria AC-10, AC-13, AC-23, AC-24, AC-25 passed.
- 2026-10-24 12:49–12:59 PDT | serial extension neighbor suite (confirmation + cancel/dismiss) | EXT-01, EXT-02 | PASSED (`testrun_done`, exit 0; 2/2; 609s) | Kane | Cancel and dismiss retained 40 credits with no active extension. AC-26 also passed. Evidence pack: `.testmuai/evidence/4c458feb-6661-4c7e-b568-be7b4b8eb2ab.evidence`.
- `kane-cli cover --mode agent` completed: 18/46 criteria proven (36.34% risk-weighted coverage). M2 is green on the current worktree; no product code change or commit was made in this session. M3 safety/recovery remains separate work.

## Readiness metric ledger

Refresh this ledger after each milestone and use a final `kane-cli cover` result in the submission report.

- Regressions or implementation issues caught before their commit: **4** in M1 (two stale-session/loading races in source review, one headless Keychain failure exposed during the first Kane attempt, and one simulator-session identifier found in the Release scan).
- Requirements proven vs owed: **18/46 proven, 28 owed** in the latest project `kane-cli cover` report after M2; refresh at final readiness.
- Code change to verified commit: M1 first implementation file [migration](Supabase/migrations/202610240001_m1_auth_groups.sql) created at 11:26:06 PDT; verified commit `ccd62d6` at 12:08:55 PDT, **42m 49s** (one measured milestone so far).
- AI leak rate: **0/0 runs completed before guard and 0/0 after guard**; the five fresh-run measurements are pending, so no leak rate is claimed.

## M3 session (test-first safety checks)

- Session preflight: Kane 0.10.0-rc.3, authenticated; balance 100,538.0368 credits; device iPhone 17 Pro, iOS 26.5. CoreSimulator access required host permissions; Xcode 27 has no Simulator.app, so runs use `Scripts/with-kane-simulator.sh`.
- 2026-10-24 13:08 PDT | `keep-the-balance-at-30-after-duplicate-confirmation_test.md` | EXT-03 | ENVIRONMENT / exit 2; no `test_md_done` | simulator startup | Managed driver could not open `Simulator.app`; no product steps ran. Retried with documented headless Appium wrapper.
- 2026-10-24 13:10–13:17 PDT | `keep-the-balance-at-30-after-duplicate-confirmation_test.md` | EXT-03 | BROKEN / exit 1; `test_md_done` failed | Kane agent misstep, not product | Test stopped before its extension assertion because the password field remained blank during sign-in. The terminal verdict says the agent failed to focus/verify the SecureField; no extension behavior was observed. Pack `f788f4ed-83bf-4320-b4b4-7531c3ac3745.evidence`. Do not count as product red or pass. Next: inspect/recover the test's sign-in setup, then run both M3 tests against the unguarded implementation.
- 2026-10-24 13:18 PDT | `show-failure-and-restore-credits-after-failed-activation_test.md` | RECOV-01 | CANCELLED / exit 130 before `test_md_done` | test data setup | The run announced unresolved `activation_failure_fixture`; cancelled before any UI step rather than type its placeholder. Filled it as the Debug control reference `Fail next activation`; retrying.
- 2026-10-24 13:19:06–13:21:58 PDT | `show-failure-and-restore-credits-after-failed-activation_test.md` | RECOV-01 | FAILED / `test_md_done` failed, process exit 1 | product | Run ID/session `c0448d15-2859-40a5-ace0-c7ec70f39f85`; execution `8c24563e-1539-46e7-a1cf-931214f0e697`; source HEAD `ba2a229309023c95e36aadaccc5bf862fb02ce04` (M2 changes were in the worktree; no M3 recovery guard). Failing assertion: testmd step 2, nested run step 4, expected “Couldn't start extension” and balance 40; observed “Your group time was approved, but this device couldn't apply it.” and 30 credits. Kane also found the confirmed extension still present. Full pack saved and validated as `evidence/packs/RECOV-01_red_20261024.evidence`; separate evidence commit `d153216ebe300dd995ec67b216eb2c4304127e16` preserved it before the fix. This is an honest pre-guard product red. The red evidence commit `d153216ebe300dd995ec67b216eb2c4304127e16` correctly says FAILED step 4 (the nested run assertion). The later fix commit `a8e533c73809e1352f59702abe83ad90e97c9950` says FAILED step 9; that trailer is inaccurate. The event stream confirms the failing assertion was nested run step 4 under testmd step 2. Commit history was left unchanged.
- 2026-10-24 13:24:26–13:27:25 PDT | `keep-the-balance-at-30-after-duplicate-confirmation_test.md` | EXT-03 | PASSED / `test_md_done` passed, process exit 0 | pre-guard behavior | Run ID/session `e08d6663-8ac0-4097-b322-20cca1c57d89`; execution `a3096d85-e9de-400f-98e1-0fd6c84c2a2f`; source HEAD `d153216ebe300dd995ec67b216eb2c4304127e16` (M2 app code unchanged). The action log confirms a double-click on `extension.confirm`; the balance stayed at 30. No new guard was added: the existing M2 `AppStore` gate rejects confirmation while busy. Full pass pack saved and validated as `evidence/packs/EXT-03_preexisting_ui_guard_green_20261024.evidence`. Next: fix RECOV-01 and rerun its committed test.


- 2026-10-24 13:32–13:35 PDT | `show-failure-and-restore-credits-after-failed-activation_test.md` | RECOV-01 | PASSED (`test_md_done`, exit 0; session `5717888e-31fa-436a-8752-fea8f88b9133`, execution `53296f8d-5a9e-4934-829c-89b934bbb4dc`) | rerun after reconciliation fix | Source commit SHA before the uncommitted fix: `1d529c3f1058973834290d20c44d00d9a8cae5cf`. Kane verified “Couldn't start extension,” balance 40, and no active extension; green pack copied and validated at `evidence/packs/RECOV-01_green_20261024.evidence`.

- 2026-10-24 13:35–13:55 PDT | extension neighbor suite (`--tags extensions --parallel 1`) | EXT-01/02/03, RECOV-01 | PASSED (`testrun_done`, exit 0; execution `f9607273-159b-48b0-a7df-4755abbb9065`; 4/4) | regression check | 9 criteria passed: AC-10, AC-13, AC-16, AC-17, AC-19, AC-23, AC-24, AC-25, AC-26. Pack `evidence/packs/M3_extensions_green_20261024.evidence` validated.

- 2026-10-24 13:55–14:00 PDT | extension double-confirm bughunt (`kane-cli run --bug-detection continue --agent`) | exploration | BROKEN / exit 1; session `f5560421-0320-4971-bb2a-4f104868663f`, execution `a1384dc5-3f76-4858-8a1b-c1bb51239a2f` | agent misstep, no confirmed product bug | Kane's terminal verdict: the agent analyzed before confirming and never tapped Confirm; no product error or contradictory app state was observed. It had observed the ordinary active extension with a valid expiry. Pack saved and validated at `evidence/packs/M3_extension_bughunt_agent_misstep_20261024.evidence`.
- 2026-10-24 13:35 PDT | `Scripts/seed.sh normal` | setup | ENVIRONMENT / exit 2 | local filesystem permission | Supabase CLI could not write `/Users/jasonlu/.supabase/telemetry.json`; the authorized retry succeeded and verified the normal fixture at 40 credits. No UI result was claimed from the failed attempt.


## M4 privacy/sharing (pre-guard baseline)

- Test-first provenance: the committed PRIV-01 tests were already present in scaffold commit `963abb9`, before M4 implementation. The first M4 baseline stores reasons and exposes all completed reasons in the group feed, as the simple unfiltered implementation.
- 2026-10-24 14:09–14:15 PDT | `keep-alice-s-completed-extension-out-of-the-group-feed_test.md` | PRIV-01 / AC-28 | PASSED (`test_md_done`, exit 0; session `60a9fc48-bdee-4ce4-9920-944823d9d65b`, execution `d855ddb2-d0da-49d6-8d4c-87da650e8967`) | baseline | Kane visually reported no card after Keep Private. A read-only authenticated RPC check immediately afterward found one feed item whose body was `chemistry test anxiety`. This visual pass did not verify the backend privacy boundary; no guard was present.
- 2026-10-24 14:15–14:19 PDT | `keep-alice-s-private-reason-out-of-bob-s-group-feed_test.md` | PRIV-01 / AC-29 | FAILED (`test_md_done`, exit 1; session `e9f64341-9186-422f-b724-5d82de8b436a`, execution `897330c8-1d3a-4539-b0f7-60eb251215c9`) | product | Pre-guard source HEAD `035fe9a9b41ebfac8fcb8d6f6837569f779aa22c`. Failing assertion: testmd step 4, nested run step 3; expected private reason text absent, observed `chemistry test anxiety` in Bob's Group activity feed. Kane's terminal verdict confirms a product defect. Full pack saved and validated as `evidence/packs/PRIV-01_red_20261024.evidence`.
- 2026-10-24 14:19–14:29 PDT | `keep-alice-s-private-reason-out-of-bob-s-group-feed_test.md` | PRIV-01 / AC-28, AC-29 | PASSED (`test_md_done`, exit 0; session `1bcfbfb7-bfa8-4ff7-8f6d-1882fa983012`, evidence `8182fb07-72e2-49c6-96c3-168f0c629707`) | rerun after feed filter | Source HEAD before guard commit `f7730aed831cfecef01f79cb15ac33a443cc0215`. Kane completed the Alice private-choice, Bob session, card-absence, and reason-absence checks. Validated full pack saved as `evidence/packs/PRIV-01_green_20261024.evidence`. Replay repeated Keep Private once and used a long wait, but terminal test assertions passed. The separate SQL RLS test returned `bob_cannot_read_alice_private_reason: true`.
- 2026-10-24 14:29 PDT | Simulator build | SETUP | ENVIRONMENT / first sandbox attempt exit 65 | CoreSimulator access | Xcode's Swift macro plugin returned malformed responses while CoreSimulator logging/services were denied. The host-permission retry succeeded (`BUILD SUCCEEDED`); no source or test behavior was changed for this environment issue.
- 2026-10-24 14:30 PDT | `kane-cli testrun run --tags privacy --parallel 1 --agent` | PRIV-01 neighbor suite | ENVIRONMENT on first attempt (exit 2 before test start), then FAILED (exit 1; `testrun_done`, execution `06bf55ab-9165-4130-9b4c-645162a47186`; suite pack `evidence/packs/PRIV-01_neighbor_suite_diagnostic_20261024.evidence`) | test setup / assertion design | First attempt's Appium log said its managed `APPIUM_HOME` was not writable in the sandbox; host-permission retry launched both members. Alice's scenario seeded before signing in, so it reached a pre-completed extension without the choice sheet and Kane got stuck at step 3. Bob's test selected accessibility ID `extension.completed` from the whole screen, so it counted the completed-extension summary as a feed card even though the feed was empty; Kane classified it as a broken negative assertion, not a confirmed product defect. The standalone Bob testmd rerun immediately before this suite passed. These are test flow/selector problems; next update the tests through Kane's assurance flow, then rerun the suite.
- 2026-10-24 14:30 PDT | `kane-cli balance` | SETUP | ENVIRONMENT / exit 2 | Kane credential lookup | `kane-cli whoami` remained authenticated with a valid token, but balance returned `Could not resolve credentials [prod]`; not a test result.

## M5 AI draft privacy (test-first)

- Test-first provenance: Kane authored the flow from the M5 privacy objective before any `draft-card` Edge Function exists. The committed test is `Tests/Kane/ai/card_never_leaks_reason_test.md`; its recorded objective resets/signs in Alice, seeds the private reason, opens the share editor, stores the full draft, and checks for terms and disclosure.
- 2026-10-24 14:37–14:41 PDT | `card_never_leaks_reason` one-off authoring run | AI-01 test authoring only | PASSED (`run_end`, exit 0; session `716fda41-b513-414f-84fa-eb7b590370c2`, run ID `run-0`, evidence `f0d18819-ab2c-466b-af39-08251ad07797`) | pre-M5 UI fallback | Stored draft text: `Alice used 10 group minutes.` The app had no OpenAI draft-card implementation yet, so this confirms only the existing editable fallback UI; it is not one of the ten fresh OpenAI measurements and is not an AI-01 pass.
- 2026-10-24 14:43–14:48 PDT | `m5_no_key_fallback_check` one-off | M5 wiring / AI-02 fallback only | PASSED (`run_end`, exit 0; session `c68f53b9-5f43-440f-89bc-26ea78e992a3`, run ID `run-0`, evidence `4b904755-3a19-4849-ac91-6d54e77c8cea`) | deployed baseline without configured OpenAI key | The app called the deployed Edge Function, opened the editor, stored `Alice used 10 group minutes.`, and left without posting. This was the function's no-key fallback; it did not contact OpenAI and does not count toward either five-run AI-01 measurement.
- M5 environment blocker: `supabase secrets list` returned no secrets, and `OPENAI_API_KEY`/`OPENAI_MODEL` are absent from the shell environment. The naive function is deployed and includes the private reason in its model prompt when a key is available. Do not add the guard until five fresh OpenAI drafts have been recorded. The user was asked to configure `OPENAI_API_KEY` through Supabase project secrets without sharing its value in chat.
- 2026-10-24 14:49–14:52 PDT | `leave-alice-s-share-editor-without-publishing_test.md` | SHARE-01 / AC-31, AC-32 | BROKEN / false final assertion (`test_md_done` failed, exit 1; session `390e35db-46f7-40e5-b09f-48e3b270c959`, evidence `6464a509-050f-4bc2-ba95-30dec48aecc0`) | test assertion / agent misstep | Kane saw only the fallback `Alice used 10 group minutes.` in the editor and marked it as a “paraphrase” of `chemistry test anxiety`, despite separately finding no reason text. Terminal verdict says no product defect confirmed. Full diagnostic pack saved as `evidence/packs/SHARE-01_fallback_assertion_misstep_20261024.evidence`; test needs a defined and observable paraphrase check, then rerun. The no-key fallback does not count as an AI-01 measurement.
