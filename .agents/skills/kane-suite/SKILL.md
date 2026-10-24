---
name: kane-suite
description: Use to author, tag, compose, or batch-run committed _test.md files, and before any merge or demo to run the smoke suite.
---

**Goal:** committed, replayable tests (Range points) and a green full-journey run (Proof points).

- File format: frontmatter (`mode: testing`, `tags: [smoke, credits]`), then `## Step title` sections with one plain-English instruction each and a `Verify ...` line where something must be true.
- Shared setup goes in `Tests/Kane/helpers/` and is pulled in with `@import ./helpers/<file>.md`. Create `helpers/reset_and_sign_in_alice.md`: open the Debug tab, tap **Reset**, tap **Sign in as Alice**, verify the Group screen shows.
- Record a new flow from a live run when useful: `kane-cli run "<objective>" --name <flow> --agent` writes `.testmuai/tests/<flow>_test.md`; move it into `Tests/Kane/`.
- Commit the `output-*` replay caches next to tests so replays are reproducible.
- Smoke suite: `kane-cli testrun run --tags smoke --parallel 1 --name "smoke" < /dev/null`.
- Full journey test (the demo flow) is `Tests/Kane/journey/full_journey_test.md`, tagged `smoke, journey`. It must run sign-in → extension → share → AI card → feed in one file.
- Preview a suite without running it: add `--dry-run`.
