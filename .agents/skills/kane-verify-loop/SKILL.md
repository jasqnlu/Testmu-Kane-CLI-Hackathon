---
name: kane-verify-loop
description: Use after every change under WeaveApp/ or Supabase/ and before every commit. Builds, seeds, runs the matching Kane tests with --agent, reads the result, fixes, reruns, and records evidence.
---

**Goal:** the core loop. This skill is where "Agent and Kane talked" points come from, so the trail must be visible.

1. **Scope.** Map changed files to requirement IDs and to `Tests/Kane/` files (by tag or path). If a changed behavior has no test, run `kane-assure` for it first.
2. **Build.** `Scripts/build-sim.sh`. Fix compile errors before any Kane run.
3. **Seed.** `Scripts/seed.sh <scenario>` for server state. Tests reset app-side mock state through the Debug tab as their first step.
4. **Run.** `kane-cli testmd run Tests/Kane/<area>/<name>_test.md --agent`. Wait for `test_md_done` and the process exit.
5. **Read.** On failure, record: failing step number and remark, expected vs observed, the screenshot path from the evidence pack, and the `final_state` values.
6. **Classify** as one of: product, backend, test, environment, API limitation. Only product and backend failures get code fixes. Environment → `kane-setup`. Test → fix the test with a stated reason.
7. **Fix** the smallest code change that addresses the classified cause.
8. **Rerun** the same test. Then run neighbors: `kane-cli testrun run --tags <area> --parallel 1 < /dev/null`.
9. **Record.** Append to `KANE_LOG.md`; commit with the `Kane-Run / Kane-Action / Kane-Rerun / Req` trailers from Hard rules.
10. **Stop** after 3 failed fix attempts on one test. Log it under Unresolved and tell the user.

If a run shows the test passing *before* you've implemented the feature, the test is too weak. Strengthen it with an explicit "verify" or "store as" assertion.
