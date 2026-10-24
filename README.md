# Weave

Weave turns extra screen time into a shared group credit budget, where going over costs your friends something and your reasons stay private unless you choose to share.

**Current status: M0 simulator checkpoint verified; backend selection required for M1.** The SwiftUI simulator app builds, and its blank sign-in screen passed a live Kane simulator check. Saved replay and the M0 setup suite also passed with exit 0. The auth, group, credit ledger, privacy, and AI features are not yet verified. This repository is not ready to submit. The implementation plan and acceptance criteria are in [Requirements](Requirements/acceptance-criteria.md).

The intended judge flow is sign in → group balance → personal limit → request 10 minutes → Confirm → active extension and reduced balance → Keep Private or Share with Group → review/edit an AI draft → Post to the group feed.

## Setup and run

Use an Apple Silicon Mac with full Xcode, an installed iPhone simulator runtime, Git, Node/npm, and Kane CLI. Supabase CLI and a configured test backend will be required for M1 onward.

```sh
git clone https://github.com/jasqnlu/Testmu-Kane-CLI-Hackathon.git
cd Testmu-Kane-CLI-Hackathon
npm install -g @testmuai/kane-cli@rc
kane-cli login
kane-cli whoami
kane-cli balance
kane-cli doctor --target simulator
kane-cli devices list --target simulator
```

Run the interactive login yourself. If the doctor reports missing simulator tooling, run `kane-cli doctor --target simulator --install`, then re-check it. Copy the exact iPhone name and OS version from the devices listing:

```sh
kane-cli config set-target simulator
kane-cli config set-device-name "<exact iPhone name>"
kane-cli config set-os-version "<exact OS version>"
Scripts/build-sim.sh
kane-cli config set-app ./builds/Weave.zip
```

Build and verify from any working directory using the script path, or run this at the repository root:

```sh
Scripts/verify.sh smoke
```

On Xcode 27, verification uses the supported headless Appium configuration documented in [HEADLESS.md](Tests/Kane/HEADLESS.md). Kane remains the UI verifier.

The build script runs:

```sh
xcodebuild -scheme Weave -sdk iphonesimulator -configuration Debug -derivedDataPath build
```

It packages `Weave.app` as `builds/Weave.zip`, the input format for Kane's simulator target. At M0, the smoke command explicitly verifies **only the blank app** and skips server seeding. During M0, `smoke` selects only `Tests/Kane/setup/`; it exits with an error if no runnable tests exist. It does not claim a feature or full-journey pass. Feature selections such as `Scripts/verify.sh credits` or `Scripts/verify.sh Tests/Kane/credits/example_test.md` require backend seeding; `Scripts/seed.sh normal` currently fails clearly because that backend is not configured.

## Kane verification

Kane is the UI verifier. Repo-local skills in [.agents/skills](.agents/skills) implement setup, requirement-driven assurance design, build/seed/run/fix loops, replay suites, exploration, AI privacy checks, and sealed evidence collection. Runs use agent output; results require both the completed terminal event and process exit. Errors, timeouts, and skipped checks never count as passes.

[AGENTS.md](AGENTS.md) records the rules. [KANE_LOG.md](KANE_LOG.md) records completed runs and next actions. The designed suite is under `Tests/Kane/`: 19 unexecuted feature tests plus the saved M0 smoke. All five use cases are designed; current product coverage is 0%, not a feature pass. After every change under `WeaveApp/` or `Supabase/`, run the verification loop before committing. The intended final command remains `Scripts/verify.sh smoke`; M1 will replace the blank-app seed exception with deterministic server setup.

### What Kane caught

No product defect has been verified yet. Kane exposed an obsolete Xcode simulator UI path and a moved-test ZIP path error; both are environment/test issues, not product red/green evidence. See the [evidence index](evidence/EVIDENCE.md) for real red/green pairs, coverage, and final journey/smoke packs as they are produced. No final submission pack is available yet. View a collected pack with `kane-cli evidence serve evidence/packs/<file>`.

| Area | Verification method | Current status |
| --- | --- | --- |
| Installed tooling | Local command checks | Apple Silicon host; Kane, Xcode, Supabase, and GitHub CLIs found; simulator doctor passed after driver install; Xcode 27 headless workaround documented |
| Blank-app sign-in smoke | Kane on iOS Simulator | Live objective passed, exit 0; [pack](evidence/packs/M0_signin_green.evidence) |
| Auth and group (AUTH-01, GROUP-01) | Kane | Pending |
| Confirmation, credits, duplicate taps, recovery | Kane and SQL where specified | Pending |
| Ledger concurrency (CREDIT-01) | SQL concurrency test | Pending; Kane cannot prove this |
| Keep Private and reviewed sharing | Kane | Pending |
| RLS access to private reasons | SQL security test | Pending; Kane cannot prove this |
| AI privacy gate and fallback | Kane, five privacy repetitions | Pending |
| Full journey and smoke suite | Kane sealed evidence | Pending |
| Release debug exclusion (SAFE-01) | Unit/build checks and review | Pending |
| Real Screen Time shielding | Physical device | Not verified at hackathon |

## Backend and privacy architecture

The planned backend is Supabase. All credit changes must occur in locked Postgres functions (`reserve_extension`, `confirm_extension`, and `release_reservation`), with idempotent confirmation and activation-failure reconciliation. The client must not change balances directly.

The app uses a deterministic `MockScreenTimeProvider` in DEBUG for simulator checks and a stub `RealScreenTimeProvider`. Simulator results do not demonstrate real Screen Time enforcement. Debug controls and test sign-ins compile only under `#if DEBUG`.

The planned `draft-card` Supabase Edge Function calls OpenAI using `OPENAI_MODEL` and an API key stored only in Supabase secrets. It receives extension facts, never the private reason, and falls back after an 8-second timeout. This product OpenAI call is **not implemented or verified yet**. Kane's `kane-llm-guard` workflow will gate the AI card feature with five privacy checks and a fallback check before it is declared ready.

Use seeded test accounts only. Keep credentials in ignored `.testmuai/variables/` files marked `secret: true`; never commit keys, passwords, or local secret configuration.

## Repository history and submission gates

Existing initial documentation commits are dated **October 23, 2026 Pacific**. Preserve that history. The October 24 “all code written today” gate needs organizer review against the actual code commits; do not rewrite dates or claim this gate has passed. The repository is confirmed public. A working product OpenAI call and a validated final Kane journey/smoke pack remain submission gates.
