# Weave

Study groups try to keep each other off their phones, but limits are solitary and asking for more time means explaining yourself. Weave gives the group a shared time budget: going over costs everyone a little, and your reason stays private unless you choose to share.

**Private-exception demo flow:** a member hits their screen-time limit and asks for ten more minutes. The group budget covers the request, with a small cost shared by everyone. The member keeps their reason private by default, then may choose to share an editable activity card with the group.

**Demo command:** `./Scripts/run-demo.sh` builds the unsigned simulator app, boots an iPhone simulator, installs Weave, and opens it. Walk through the private-exception flow above as features become available.

**Test command:** `./Scripts/verify.sh smoke` runs the verified smoke tests serially through Kane.

**Current status: M1 auth and group flows verified.** The app signs in through Supabase, shows the signed-in user's group and balance, and handles invalid credentials and group-fetch errors. Kane passed all six M1 smoke cases; the validated evidence pack is indexed in [evidence/EVIDENCE.md](evidence/EVIDENCE.md). Extensions, credit mutations, privacy, and AI are still in progress. This repository is not ready to submit. The implementation plan and acceptance criteria are in [Requirements](Requirements/acceptance-criteria.md).

The intended judge flow is sign in → group balance → personal limit → request 10 minutes → Confirm → active extension and reduced balance → Keep Private or Share with Group → review/edit an AI draft → Post to the group feed.

## Setup and run

Use an Apple Silicon Mac with full Xcode, an installed iPhone simulator runtime, Git, Node/npm, Kane CLI, and Supabase CLI. Configure the Weave Supabase project and its local public URL/key before building. Keep test account credentials in the ignored local configuration files; never commit them.

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
```

On Xcode 27, verification uses the supported headless Appium configuration documented in [HEADLESS.md](Tests/Kane/HEADLESS.md). Kane remains the UI verifier. Simulator builds do not use Apple signing or keys. Debug simulator tests store their session in the app sandbox; iOS device builds use Keychain. The app uses a deterministic mock Screen Time provider in the simulator and does not add Family Controls.

The demo build script calls the simulator build step:

```sh
xcodebuild -scheme Weave -sdk iphonesimulator -configuration Debug -derivedDataPath build
```

`Scripts/build-sim.sh` also packages `Weave.app` as `builds/Weave.zip`, the input format for Kane's simulator target. `./Scripts/verify.sh smoke` seeds the normal owned fixture and runs M1 setup, auth, and group tests serially. Later features are not included until their milestones are verified.

## Kane verification

Kane is the UI verifier. Repo-local skills in [.agents/skills](.agents/skills) implement setup, requirement-driven assurance design, build/seed/run/fix loops, replay suites, exploration, AI privacy checks, and sealed evidence collection. Runs use agent output; results require both the completed terminal event and process exit. Errors, timeouts, and skipped checks never count as passes.

[AGENTS.md](AGENTS.md) records the rules. [KANE_LOG.md](KANE_LOG.md) records completed runs and next actions. The requirement-linked suite is under `Tests/Kane/`; M1 auth and group tests now pass through the live Supabase backend. After every change under `WeaveApp/` or `Supabase/`, run the verification loop before committing. The final command remains `Scripts/verify.sh smoke`, with each milestone adding its verified paths.

### What Kane caught

Kane exposed a headless simulator session-store incompatibility before the M1 auth run; the simulator-only storage path fixed it and the rerun passed. No feature red/green pair has been recorded yet. See the [evidence index](evidence/EVIDENCE.md) for proven requirements and open gates. No final submission pack is available yet. View a collected pack with `kane-cli evidence serve evidence/packs/<file>`.

| Area | Verification method | Current status |
| --- | --- | --- |
| Installed tooling | Local command checks | Apple Silicon host; Kane, Xcode, Supabase, and GitHub CLIs found; simulator doctor passed after driver install; Xcode 27 headless workaround documented |
| Blank-app sign-in smoke | Kane on iOS Simulator | Live objective passed, exit 0; [pack](evidence/packs/M0_signin_green.evidence) |
| Auth and group (AUTH-01, GROUP-01) | Kane on iOS Simulator | M1 verified; 6/6 smoke tests passed, [pack](evidence/packs/M1_auth_groups_smoke.evidence) |
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

The October 23, 2026 Pacific commits contain planning documents only; organizers confirmed that a pre-hackathon spec is allowed. All code was written on October 24, 2026 Pacific, and the “code written today” gate is **confirmed by organizers**. Preserve the existing commit history. The repository is confirmed public. A working product OpenAI call and a validated final Kane journey/smoke pack remain submission gates.
