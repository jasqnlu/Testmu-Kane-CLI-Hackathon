# Weave × Kane CLI — Codex Master Spec

Oct 24, 2026 · @Jason Lu

## How to use this doc

Paste everything from **Mission** down into a fresh Codex session opened at your repo root. Codex will write `AGENTS.md`, seven repo-local skills in `.agents/skills/`, the requirements file, and the evidence scaffolding, then start the build loop.

1. Create the public GitHub repo first and make the first commit today, so the "code written today" gate is provable from history.
2. On your Mac, run `kane-cli login` yourself before starting Codex. OAuth login is interactive, and pickers like `kane-cli config project` can't be run by an agent.
3. Paste this tab into Codex. Leave the **Optional** tab out until the core flow passes end to end.
4. Check the commands against the installed version with `kane-cli --help` if anything errors. Flags below come from the Kane CLI docs as of today.

Everything below this section is written to Codex, in second person.

## Mission

You are building **Weave**, an iOS app (SwiftUI + Supabase) for a one-day hackathon, and Kane CLI is your eyes. Every user-facing change you make is verified by Kane on the iOS Simulator before you commit it. You read Kane's result and decide what to do next from it.

**The product in one sentence:** screen-time limits fail because they're solitary, so Weave turns extra time into a shared group credit budget, where going over costs your friends something and your reasons stay private unless you choose to share.

**Core flow a judge must complete live:** sign in → see group and credit balance → hit personal limit → request a 10-minute extension → confirm → balance drops and extension is active → choose Keep Private or Share with Group → if sharing, an AI-drafted activity card is reviewed and posted to the feed.

### How this is judged (optimize for this)

Three gates must pass or the project cannot place:

1. All code written today; repo public.
2. OpenAI used in the build. Weave uses it in the product: a Supabase Edge Function calls the OpenAI API to draft the activity card. You, Codex, are also an OpenAI agent.
3. A Kane CLI evidence pack attached to the submission.

The Kane criterion is worth 25 points. Every skill you create targets one of its three parts:

| Part | Points | What earns it | Skill that earns it |
| --- | --- | --- | --- |
| Proof, not presence | 8 | A failed run that found a real bug plus the green rerun, or a green run across the full user journey | `kane-verify-loop`, `kane-bughunt` |
| Agent and Kane talked | 9 | You ran Kane with `--agent`, read the NDJSON, and changed your next action; visible in commits and run history | `kane-verify-loop` + commit convention |
| Range | 8 | Going past `kane-cli run`: committed `_test.md` replayed, the assurance loop (ingest → design → cover), exploration, mobile, Kane as part of the product (a gate or grader) | `kane-assure`, `kane-suite`, `kane-llm-guard`, `kane-evidence` |

The idea criterion rewards ideas where an untested agent would plausibly ship something broken. Weave has three such risks, and Kane must make each visible: double-spent credits, a private reason leaking into the group feed, and an LLM-drafted card that quotes the private reason.

## Hard rules

**Kane rules**

1. Never hand-write Playwright, XCUITest UI flows, or Selenium to verify UI. Kane is the UI verifier. XCTest stays for unit logic only.
2. Always pass `--agent` to `kane-cli run` and `kane-cli testmd run`. For `kane-cli testrun run`, also end the line with `< /dev/null`. Assurance commands that support it take `--mode agent`.
3. Decide pass or fail from the `run_end` event (or `test_md_done` for testmd) **and** the process exit code: 0 passed, 1 failed, 2 error, 3 timeout or cancelled. Never from progress lines.
4. Exit 2 or 3 is an **environment failure**, not a product pass or fail. Fix the environment; never mark a requirement passing from it.
5. One objective = one task. Split flows over \~15 steps. Use the "store as" pattern to extract values (for example "store the group balance as 'balance'") and read them from `final_state`.
6. Simulator runs: `--target simulator --app <path to Weave.zip>` with `--device-name` and `--os-version` copied exactly from `kane-cli devices list --target simulator`. Suites with simulator members run with `--parallel 1`.
7. Bounded retries: at most 3 fix attempts per failing test. After 3, stop, write the failure to `KANE_LOG.md` under **Unresolved**, and tell the user.
8. Run `kane-cli balance` at the start of the session and every \~20 runs. Prefer `testmd run` replays (cached, cheap) over fresh `run` calls once a flow is recorded.

**Integrity rules**

1. Fix the product, not the test. Change a `_test.md` or a requirement only when the test or requirement is provably wrong, and say why in the commit.
2. Never fake a failure. A red run in the evidence must come from a real defect: a test written before its feature or guard existed, or a bug found while exploring. Label which in `KANE_LOG.md`.
3. Never mark a skipped or environment-failed test as passing.
4. Kane cannot prove ledger concurrency, RLS security, or real Screen Time enforcement. Those need SQL tests or device checks; say so in the README.

**Commit convention** (this is how judges see that you and Kane talked)

Every commit that follows a Kane run carries trailers:

```
fix(ext): block extension when group balance < request

Kane-Run: extension_insufficient_test.md — FAILED step 4
  ("balance still shows 5, expected rejection banner")
Kane-Action: added server-side balance check in reserve_extension()
Kane-Rerun: PASSED (exit 0)
Req: CREDIT-02
```

Also append one line per run to `KANE_LOG.md`: time, test, result, what you changed next.

**Security rules**

1. The OpenAI key lives only in Supabase secrets, read by the Edge Function. Never in the app, the repo, or a Kane variables file.
2. Test accounts and seeded data only. Debug controls compile only under `#if DEBUG`.
3. Kane credentials and `.testmuai/variables/*.json` stay gitignored.

## Step 1: create the repo scaffolding and skills

Create these before writing any app code. All skills are **repo-local** in `.agents/skills/` at the repo root, so they exist only in this project and are committed with it. Do not install skills globally.

```
Weave/
├── AGENTS.md                      # points Codex at the skills + hard rules
├── README.md                      # run command, Kane section, verified-vs-not table
├── KANE_LOG.md                    # one line per Kane run + Unresolved section
├── .agents/skills/
│   ├── kane-cli/                  # official Kane skill, vendored (see below)
│   ├── kane-setup/SKILL.md
│   ├── kane-assure/SKILL.md
│   ├── kane-verify-loop/SKILL.md
│   ├── kane-suite/SKILL.md
│   ├── kane-bughunt/SKILL.md
│   ├── kane-llm-guard/SKILL.md
│   └── kane-evidence/SKILL.md
├── .testmuai/
│   ├── context.md                 # project context Kane loads on every run
│   └── variables/                 # gitignored: test-user creds (secret: true)
├── Requirements/
│   └── acceptance-criteria.md     # Step 3 below; Kane ingests this
├── WeaveApp/                      # SwiftUI app (Features/ Services/ Models/ Debug/)
├── Supabase/
│   ├── migrations/
│   ├── functions/draft-card/      # OpenAI call lives here
│   └── tests/                     # SQL: concurrency + RLS
├── Tests/
│   ├── Unit/
│   └── Kane/                      # *_test.md, committed, tagged
├── evidence/
│   ├── EVIDENCE.md                # index judges read first
│   └── packs/                     # selected sealed .evidence files
└── Scripts/
    ├── build-sim.sh               # xcodebuild → zip Weave.app → builds/Weave.zip
    ├── seed.sh <scenario>         # resets Supabase test data
    └── verify.sh <tag|path>       # build + seed + Kane, one command
```

**Vendor the official Kane skill.** The Kane CLI repo ships its skill at `.agents/skills/kane-cli` in `github.com/LambdaTest/kane-cli`. Copy that folder into this repo's `.agents/skills/kane-cli/` (sparse checkout or download) instead of running the global `npx @testmuai/kane-cli-skill` installer. Our custom skills build on it; when they conflict, ours win for this project.

**AGENTS.md** must contain: the product sentence, the core flow, all Hard rules above, the list of skills with one line each on when to use them, and this standing instruction: *"After any change to a file under WeaveApp/ or Supabase/, run the kane-verify-loop skill before committing."*

**.testmuai/context.md** tells Kane about the app on every run: it's an iOS app called Weave; a **Debug** tab exists in test builds with buttons to seed scenarios and control the mock Screen Time provider; credits are shown as "N credits"; seeded users are Alice, Bob, and Charlie.

**Scripts/build-sim.sh** must build for the simulator with `xcodebuild -scheme Weave -sdk iphonesimulator -configuration Debug -derivedDataPath build`, then zip `Weave.app` into `builds/Weave.zip`, because the simulator target takes a `.zip`. Gitignore `build/` and `builds/`.

## Step 2: write the seven skills

Each skill below becomes `.agents/skills/<name>/SKILL.md`: the YAML block is the frontmatter (between `---` lines), and everything under it until the next skill is the body. Keep the descriptions as written; they decide when you trigger each skill.

### Skill 1: kane-setup

```yaml
name: kane-setup
description: Use once at session start, or when any Kane command exits 2, to check Kane CLI auth, simulator tooling, devices, and the app build. Not for running tests.
```

**Goal:** a verified environment, recorded once, so every later run uses the same device and build.

1. `kane-cli --version` and `kane-cli whoami`. If not logged in, stop and ask the user to run `kane-cli login` (interactive; you cannot do it).
2. `kane-cli balance`. Write the number to `KANE_LOG.md`.
3. `kane-cli doctor --target simulator`. If any check fails, run `kane-cli doctor --target simulator --install` and re-check. Requires an Apple Silicon Mac with Xcode; if the machine isn't one, stop and tell the user.
4. `kane-cli devices list --target simulator`. Pick one iPhone; record its exact name and OS version.
5. Persist defaults so every run matches: `kane-cli config set-target simulator`, `kane-cli config set-device-name "<name>"`, `kane-cli config set-os-version <ver>`, `kane-cli config set-app ./builds/Weave.zip`.
6. Run `Scripts/build-sim.sh`, then the smoke objective: `kane-cli run "Open Weave and verify the sign-in screen is visible" --target simulator --app ./builds/Weave.zip --agent`.
7. Write `Tests/Kane/ENVIRONMENT.md`: Kane version, device, OS, date, smoke result. Commit it.

### Skill 2: kane-assure

```yaml
name: kane-assure
description: Use when Requirements/acceptance-criteria.md is created or changed. Turns requirements into a designed, requirement-linked Kane test suite and a coverage report.
```

**Goal:** tests derived from the spec, not from whatever the code happens to do. This is the assurance loop the Range points reward.

1. `kane-cli context ingest Requirements/acceptance-criteria.md`
2. `kane-cli context extract` (use the headless mode flag shown by `kane-cli context extract --help`). Every proposed use-case must cite the requirement IDs.
3. `kane-cli context review`. Approve proposals that match a requirement ID exactly; reject invented ones. If headless review needs a verdicts file, write `Requirements/review-verdicts.json` and commit it, so the decisions are visible.
4. For each approved use-case: `kane-cli design tests --use-case <ref>`. Move generated `_test.md` files into `Tests/Kane/<area>/` and add `tags:` frontmatter (`smoke`, plus the area: `auth`, `groups`, `credits`, `extensions`, `privacy`, `ai`).
5. Read every generated test. If a step contradicts the requirement, fix the test and note it in the commit.
6. `kane-cli cover` and `kane-cli cover gaps`. Save output to `evidence/coverage-<time>.txt`.
7. When a requirement changes later: `kane-cli maintain reconcile`, then repeat 4 to 6.

Commit: `test(assure): design suite from acceptance criteria` with a `Req:` trailer listing IDs covered.

### Skill 3: kane-verify-loop

```yaml
name: kane-verify-loop
description: Use after every change under WeaveApp/ or Supabase/ and before every commit. Builds, seeds, runs the matching Kane tests with --agent, reads the result, fixes, reruns, and records evidence.
```

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

### Skill 4: kane-suite

```yaml
name: kane-suite
description: Use to author, tag, compose, or batch-run committed _test.md files, and before any merge or demo to run the smoke suite.
```

**Goal:** committed, replayable tests (Range points) and a green full-journey run (Proof points).

- File format: frontmatter (`mode: testing`, `tags: [smoke, credits]`), then `## Step title` sections with one plain-English instruction each and a `Verify ...` line where something must be true.
- Shared setup goes in `Tests/Kane/helpers/` and is pulled in with `@import ./helpers/<file>.md`. Create `helpers/reset_and_sign_in_alice.md`: open the Debug tab, tap **Reset**, tap **Sign in as Alice**, verify the Group screen shows.
- Record a new flow from a live run when useful: `kane-cli run "<objective>" --name <flow> --agent` writes `.testmuai/tests/<flow>_test.md`; move it into `Tests/Kane/`.
- Commit the `output-*` replay caches next to tests so replays are reproducible.
- Smoke suite: `kane-cli testrun run --tags smoke --parallel 1 --name "smoke" < /dev/null`.
- Full journey test (the demo flow) is `Tests/Kane/journey/full_journey_test.md`, tagged `smoke, journey`. It must run sign-in → extension → share → AI card → feed in one file.
- Preview a suite without running it: add `--dry-run`.

### Skill 5: kane-bughunt

```yaml
name: kane-bughunt
description: Use after a feature first passes, to explore its edges with Kane bug detection and find real defects before judges do.
```

**Goal:** at least one honest red-then-green story with evidence.

1. Pick the feature's riskiest edges: double-tapping Confirm, requesting more minutes than the balance, backgrounding mid-request, the mock provider failing activation (Debug tab → **Fail next activation**).
2. Explore each with bug detection on: `kane-cli run "<edge objective>" --bug-detection continue --agent`.
3. Any confirmed bug: write a `_test.md` that reproduces it, run it to capture the red pack, fix, rerun green, commit with trailers. Mark it **found-by-exploration** in `KANE_LOG.md`.
4. Copy both packs (red and green) into `evidence/packs/` via `kane-evidence`.

### Skill 6: kane-llm-guard

```yaml
name: kane-llm-guard
description: Use for any change to the AI activity-card feature (the draft-card Edge Function, its prompt, or the share screen). Verifies the OpenAI-drafted card never leaks the private reason.
```

**Goal:** Kane as the grader of nondeterministic LLM output. This is Weave's most distinctive use of Kane.

1. **Write the test first**, before the guard exists: `Tests/Kane/ai/card_never_leaks_reason_test.md`. Seed Alice's extension with the private reason **"chemistry test anxiety"**. Steps: tap Share with Group → wait for the AI draft → store the draft text as 'draft' → verify the draft does not contain "chemistry", "anxiety", or a paraphrase of the reason.
2. Run it against the first version of `draft-card`, where the reason is in the model's context with only a prompt instruction not to use it. Run it exactly **5 times** as five fresh `kane-cli run` calls. Never use cached `testmd` replays for these privacy measurements. Start each call with Debug → Reset, then create a new private-reason seed so the app invokes OpenAI again. Store each generated draft text in that run's `final_state`. Log all five stored draft texts in `KANE_LOG.md`, with the run IDs, to prove that each call generated a fresh draft. If any run leaks, that's a real red result.
3. Fix in layers: keep the reason out of the prompt entirely (send only minutes, time of day, and achievement), then add a server-side check that rejects drafts containing reason terms and regenerates.
4. Rerun with five more fresh `kane-cli run` calls. Reset and reseed before every call, store each new draft in `final_state`, and log all five texts and run IDs in `KANE_LOG.md`. All five must pass. Commit with trailers and `Req: AI-01`.
5. If all 5 first-version runs pass, don't fabricate a failure. Record "no leak observed in 5 runs" honestly, still ship the layered fix, and note that Kane gates the feature. In the final readiness report, state the AI leak rate before and after the guard as leaked drafts out of five.

### Skill 7: kane-evidence

```yaml
name: kane-evidence
description: Use before a commit that fixes a Kane-found bug, before the demo, and at submission to collect, validate, and index evidence packs for judges.
```

**Goal:** the evidence pack gate, plus a page judges can skim in 30 seconds.

1. Sealed packs land in `.testmuai/evidence/`. Copy only the ones that matter into `evidence/packs/` with descriptive names, e.g. `CREDIT-02_red.evidence`, `CREDIT-02_green.evidence`, `smoke_final.evidence`.
2. Validate each: `kane-cli evidence validate <path>` (exit 0 = valid).
3. For the final submission, merge the smoke and journey packs: `kane-cli evidence merge <packs...> --run-id weave-final`.
4. Run `kane-cli cover` one last time and save the output.
5. Maintain `evidence/EVIDENCE.md`: a table of requirement ID, test file, red pack (if any), green pack, what Kane caught. Below it, a **Not verified by Kane** list: ledger concurrency (SQL test), RLS (SQL test), real Screen Time shielding (physical device or unverified).
6. Before reporting readiness, refresh `kane-cli cover` and include exact counts for requirements proven and owed. Also report regressions caught before commit (an integer, including zero), median elapsed time from code change to verified commit, and AI leak rate before and after the guard as leaked drafts out of five. Cite the run IDs and five stored draft texts in `KANE_LOG.md`; cached replays do not count as fresh AI generations. If the five-run comparison is incomplete, report completed runs and mark its rate and readiness as pending instead of inventing a rate.
7. Tell the user how to view a pack locally: `kane-cli evidence serve evidence/packs/<file>`.

## Step 3: write Requirements/acceptance-criteria.md

Write this file before any feature code, then run `kane-assure` on it. Each requirement has an ID, preconditions, expected behavior, failure states, and an **observable outcome** Kane can see on screen. Write it as markdown with one `### ID: title` heading per requirement, using this content:

| ID | Preconditions | Expected behavior | Observable outcome | Verified by |
| --- | --- | --- | --- | --- |
| AUTH-01 | Test user exists | User signs in with email and password | Group screen shows the user's name | Kane |
| GROUP-01 | Alice is in group "Study" | Group screen lists members and balance | Shows Alice, Bob, Charlie and "40 credits" | Kane |
| CREDIT-01 | Balance 40 | Two simultaneous 10-min reservations never spend the same credits | Ledger total equals sum of reservations | SQL concurrency test |
| CREDIT-02 | Balance 5 | 10-min request is rejected | "Not enough group credits" message; balance still 5 | Kane + SQL |
| EXT-01 | Alice at personal limit, balance 40 | Request needs an explicit Confirm tap | Confirm sheet shows "10 minutes · 10 credits" before anything is spent | Kane |
| EXT-02 | Confirmed extension | Balance drops, extension starts with an expiry | Balance "30 credits"; banner "Extension active, ends at HH:MM" | Kane |
| EXT-03 | Extension active | Double-tapping Confirm does not double-spend | Balance is 30, not 20 | Kane + SQL |
| RECOV-01 | Mock provider set to fail activation | Server reservation is reconciled | Error "Couldn't start extension"; balance returns to 40 | Kane |
| PRIV-01 | Alice finished an extension with a private reason | Keep Private posts nothing | Bob's feed shows no card from Alice; no reason text anywhere | Kane + RLS test |
| SHARE-01 | Alice taps Share with Group | AI drafts a card; Alice can edit it; nothing posts until she taps Post | Draft editor visible; feed unchanged until Post | Kane |
| SHARE-02 | Alice taps Post | Card appears in group feed | Feed shows Alice's card with her edited text | Kane |
| AI-01 | Private reason "chemistry test anxiety" stored | AI draft never contains the reason or a paraphrase | Stored draft text has none of the reason terms, 5 of 5 runs | Kane (5 runs) |
| AI-02 | OpenAI call fails or times out | User gets a plain fallback card, flow continues | Fallback text "Alice used 10 group minutes" in editor | Kane |
| SAFE-01 | Release build | Debug tab and debug routes don't exist | (Code check: all debug code under `#if DEBUG`) | Unit test + review |

Add under the table: *Out of scope for Kane, verified elsewhere: CREDIT-01 (SQL), PRIV-01 RLS half (SQL), real Screen Time shielding (physical device; not verified at hackathon).*

## Step 4: build the core, in this order

Build only what's in the core flow. Anything else is in the Optional tab, and you don't touch it until milestone M6 passes. Each milestone ends with `kane-verify-loop` green and a commit.

**Architecture you must keep**

- `ScreenTimeProvider` protocol with `MockScreenTimeProvider` (simulator, deterministic) and a stub `RealScreenTimeProvider`. The app reads the mock in DEBUG. Screen Time APIs don't work in the simulator, so the mock is how Kane tests the flow; say that in the README.
- Do not add the Family Controls capability. Simulator builds need no Apple signing certificate or keys; the deterministic mock provider covers Screen Time in the simulator.
- All credit changes happen in Postgres functions (`reserve_extension`, `confirm_extension`, `release_reservation`) using row locks, never in the client.
- **Debug tab** (DEBUG only): buttons Reset, Sign in as Alice, Sign in as Bob, Seed: normal / low-balance / private-reason, Set usage at limit, Fail next activation. Kane tests start here, so they're deterministic.
- `draft-card` Edge Function: receives the extension or achievement facts (never the reason), calls the OpenAI API with the key from Supabase secrets, returns a 1 to 2 sentence supportive card. Model name comes from an env var `OPENAI_MODEL`; pick a current small model from OpenAI's docs. Timeout 8 s with the AI-02 fallback.

**Milestones**

1. **M0 Setup.** Scaffolding, skills, AGENTS.md, `kane-setup` passes with a smoke run on a blank app. Write the requirements file and run `kane-assure`. You now have a designed suite that fails, which is correct.
2. **M1 Auth + group.** AUTH-01, GROUP-01. Supabase schema, seeded users, group screen.
3. **M2 Extensions.** EXT-01, EXT-02, CREDIT-02. Write `extension_insufficient_test.md` and run it **before** adding the server balance check, so the red run is real. Then fix and go green.
4. **M3 Safety.** EXT-03 (double tap), RECOV-01 (failed activation). Run `kane-bughunt` on the extension flow. Write the SQL concurrency test for CREDIT-01.
5. **M4 Privacy + sharing.** PRIV-01, SHARE-01, SHARE-02. Write the RLS test.
6. **M5 AI card.** AI-01 and AI-02 via `kane-llm-guard`. This is the OpenAI gate and the headline Kane story.
7. **M6 Journey.** `full_journey_test.md` green; smoke suite green; `kane-cli cover` saved; `kane-evidence` run. **Stop feature work here** and tell the user the core is done.
8. **M7 Repo polish.** README with: one-line pitch, `Scripts/verify.sh smoke` as the run command, setup steps, a "What Kane caught" section linking `evidence/EVIDENCE.md`, and a verified-vs-not table. Confirm someone could clone and run it tonight.

After each milestone, send the user a 2-line status: what passed, what Kane caught, what's next.

## Definition of done for Kane points

Before telling the user the project is ready to submit, confirm every box and report any that are open.

**Proof, not presence (8)**

- [ ] At least one real red→green pair in `evidence/packs/` (planned: CREDIT-02; likely: AI-01 or a bughunt find)
- [ ] `full_journey_test.md` green end to end, pack saved as `journey_final.evidence`
- [ ] Smoke suite green in one `testrun` pack

**Agent and Kane talked (9)**

- [ ] Every fix commit after a Kane run has `Kane-Run / Kane-Action / Kane-Rerun / Req` trailers
- [ ] `KANE_LOG.md` shows runs in order, including the failed attempts, not just the wins
- [ ] At least one entry where a Kane result changed the plan (e.g. a test-classified failure where you fixed the test with a reason)

**Range (8)**

- [ ] `_test.md` files committed under `Tests/Kane/` with tags, replayed via `testmd run` and `testrun run`
- [ ] Assurance loop ran: `context ingest` → `extract` → `review` → `design tests` → `cover`, with outputs committed
- [ ] Mobile target used throughout (`--target simulator`)
- [ ] Exploration with `--bug-detection continue`
- [ ] Kane as part of the product: Kane is the grader that gates the AI card feature (`kane-llm-guard`), stated in the README

**Gates**

- [ ] Repo public, all commits dated today
- [ ] OpenAI called from `draft-card`; mentioned in the README
- [ ] `evidence/EVIDENCE.md` and packs committed; tell the user which pack file to attach to the submission

**Required readiness report values**

When reporting readiness, include these measured values, even when a value is zero:

- Regressions caught before commit: integer count, with references to the run or review entries in `KANE_LOG.md`.
- Requirements proven and owed: exact proven/total counts and owed count from the final `kane-cli cover` output.
- Median time from code change to verified commit: calculate from the recorded code-change and verification/commit times in `KANE_LOG.md`; state the sample count.
- AI leak rate before and after the guard: leaked drafts out of five fresh `kane-cli run` calls for each phase. Every run starts with Reset and a new seed; cached replays do not count. Include the run IDs and all stored draft texts in `KANE_LOG.md`.

If a five-run phase is incomplete, report how many fresh runs completed and mark its rate and readiness as pending. Never label an unrun draft as a non-leak.

When everything is checked, give the user: the 3 strongest Kane catches in one line each (they'll open the demo video with these), and the path to the merged final pack.

Deferred scope, with when to start each item: Optional

## Sources

Commands checked against the docs on Oct 24, 2026.

- [Kane CLI command and flag reference](https://www.testmuai.com/docs/kane-cli-cli-reference.md)
- [Kane CLI README (assurance, testmd, evidence, agent rules)](https://github.com/LambdaTest/kane-cli)
- [Codex Agent Skills: where skills live](https://developers.openai.com/codex/skills)
