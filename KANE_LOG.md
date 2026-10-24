# Kane run log

M0 live smoke, saved replay and setup suite passed. Product-feature tests have not run. Environment checks and run outcomes are appended below. A pending or environment-failed check is never a product pass.

## Session environment

- Date: 2026-10-24 (America/Los_Angeles).
- Kane version: 0.9.0.
- Starting balance: 101,200 credits (preflight, authenticated).
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

For failures, record the failing step, expected versus observed outcome, screenshot path inside the evidence pack, and stored final-state values. Label honest red evidence as **feature-not-yet-implemented** or **found-by-exploration**. Record all attempts, including environment failures.

## Unresolved

- Backend not selected: no local Docker/Podman; hosted projects discovered but none confirmed for Weave. M1–M7 and all feature requirements remain pending.
- Product OpenAI call, SQL concurrency/RLS checks, real red→green pair, exploration, five AI privacy runs and final journey pack remain pending.
- Designed criteria approval and fixture variables remain open; see Requirements/assurance-review-notes.md.

## Setup and assurance events

- 2026-10-24 11:07 PDT: simulator doctor exit 2; sandbox denied CoreSimulator access and managed driver missing. Installed driver with elevated permissions; doctor rerun exit 0. No product assertion ran.
- 2026-10-24: requirements ingest exit 0. Extraction exit 1 with EPERM creating Kane assurance logs outside workspace; environment failure, no product coverage. Retrying with elevated access.
- Public repo confirmed. Existing commits dcaaed9 and 3f1a6a8 are October 23 Pacific (October 24 UTC); they contain pre-existing scaffolding. History preserved; all-code-today gate needs judge interpretation.

- 2026-10-24 11:10 PDT: elevated extraction complete, exit 0; 5 use cases reviewed against source citations and approved per master spec. Mapping and verdicts saved in Requirements/. Next: design each approved use case.
- 2026-10-24 11:10 PDT: M0 build exit 65 at codesign due Desktop Finder/iCloud metadata; simulator-only signing disabled, rebuild exit 0. No UI verification claimed from build.

- 2026-10-24 11:20 PDT: assurance designs uc-1 through uc-5 all completed with process exit 0. 19 feature tests retained; 5/5 use cases designed. `cover` and `cover gaps` exit 0; product requirements 0% proven. 101,078.2211 credits remain. Generated criteria approval, fixture variables, SQL-only checks and live feature runs remain open.
