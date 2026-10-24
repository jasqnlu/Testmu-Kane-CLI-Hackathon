# Weave project instructions

You are building **Weave**, an iOS app (SwiftUI + Supabase) for a one-day hackathon, and Kane CLI is your eyes. Every user-facing change you make is verified by Kane on the iOS Simulator before you commit it. You read Kane's result and decide what to do next from it.

**The product in one sentence:** screen-time limits fail because they're solitary, so Weave turns extra time into a shared group credit budget, where going over costs your friends something and your reasons stay private unless you choose to share.

**Core flow a judge must complete live:** sign in → see group and credit balance → hit personal limit → request a 10-minute extension → confirm → balance drops and extension is active → choose Keep Private or Share with Group → if sharing, an AI-drafted activity card is reviewed and posted to the feed.

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

## Repo-local skills

- [kane-cli](.agents/skills/kane-cli/SKILL.md): Official CLI command, assurance, mobile, replay, and evidence reference; custom project skills take precedence when they conflict.
- [kane-setup](.agents/skills/kane-setup/SKILL.md): Use once at session start, or when any Kane command exits 2, to check Kane CLI auth, simulator tooling, devices, and the app build. Not for running tests.
- [kane-assure](.agents/skills/kane-assure/SKILL.md): Use when Requirements/acceptance-criteria.md is created or changed. Turns requirements into a designed, requirement-linked Kane test suite and a coverage report.
- [kane-verify-loop](.agents/skills/kane-verify-loop/SKILL.md): Use after every change under WeaveApp/ or Supabase/ and before every commit. Builds, seeds, runs the matching Kane tests with --agent, reads the result, fixes, reruns, and records evidence.
- [kane-suite](.agents/skills/kane-suite/SKILL.md): Use to author, tag, compose, or batch-run committed _test.md files, and before any merge or demo to run the smoke suite.
- [kane-bughunt](.agents/skills/kane-bughunt/SKILL.md): Use after a feature first passes, to explore its edges with Kane bug detection and find real defects before judges do.
- [kane-llm-guard](.agents/skills/kane-llm-guard/SKILL.md): Use for any change to the AI activity-card feature (the draft-card Edge Function, its prompt, or the share screen). Verifies the OpenAI-drafted card never leaks the private reason.
- [kane-evidence](.agents/skills/kane-evidence/SKILL.md): Use before a commit that fixes a Kane-found bug, before the demo, and at submission to collect, validate, and index evidence packs for judges.

After any change to a file under WeaveApp/ or Supabase/, run the kane-verify-loop skill before committing.

## Scope and architecture

Follow [Requirements/master-spec.md](Requirements/master-spec.md), milestone order M0 through M7. Stop feature work after M6. All credit mutations occur in Postgres functions with row locks. Use a deterministic mock ScreenTimeProvider in DEBUG and a stub RealScreenTimeProvider. The draft-card Edge Function receives facts, never the private reason; its OpenAI key stays in Supabase secrets.
