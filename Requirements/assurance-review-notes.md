# Assurance review notes

## uc-1: AUTH-01 and SAFE-01

Kane design completed successfully and emitted four tests. Generated frontmatter incorrectly selected `target: emulator`, which means Android. The master spec requires iOS Simulator. Corrected metadata to `target: simulator`, the exact listed iPhone 17 Pro / 26.5 pair, and the simulator ZIP; preserved all generated steps and assurance links. Added requested tags.

The Release UI test points to a separate `builds/Weave-Release.zip` and carries `release, auth` tags, outside the Debug smoke selection. A Debug build cannot prove Release exclusion. SAFE-01 still requires code/build review; a UI check alone is insufficient.

Tests declare credential and failure-fixture variables with no configured values. They have not been executed and are not passing. Production authentication is not implemented at M0. Generated warnings include unapproved derived acceptance criteria and a dangling `check:` body tag; coverage gaps remain open.

## uc-2: credits, extensions, and recovery

Design completed with exit 0: six scenarios produced five mobile tests and one typed blocker for SQL-only concurrency. CREDIT-01 remains outside Kane; no UI test can prove ledger locking or concurrency. The generated files selected Android `target: emulator`; corrected only execution metadata to iOS `target: simulator`, `app: ./builds/Weave.zip`, and the exact iPhone 17 Pro / 26.5 device pair. Added `mode: testing` and `[smoke, credits]` or `[smoke, extensions]` tags. Preserved generated bodies and assurance links.

The tests require configured credentials and three setup variables (`balance_40_fixture`, `balance_5_fixture`, `activation_failure_fixture`); values are not yet supplied, and none of these tests has run. The designer reports unapproved derived criteria and dangling `check:` integrity warnings for two test bodies. These remain warnings, not proof or passes. The activation-recovery test does not fully exercise repeated recovery; that limitation remains a gap rather than an invented assertion.

## uc-3: private completion and Bob’s feed

Design completed with exit 0 (16.5 credits): three scenarios produced two mobile tests and one typed blocker for the SQL RLS access check. Corrected generated Android metadata to the specified iOS Simulator and added `[smoke, privacy]` tags. Preserved bodies, assurance links, and the sibling import between the two privacy tests. Alice and Bob credentials are still unfilled; the tests have not run. RLS remains an explicit SQL-only requirement. The generated `check:` integrity warning remains visible in the captured design output.

Version note: uc-2 and uc-3 were launched before the externally observed CLI change; parent reports those processes used 0.9.0. Before launching uc-4, `kane-cli --version` reported 0.10.0-rc.3. No CLI upgrade was performed by this worker.

## Replay path correction from actual Kane result

The first saved M0 replay exited 2 during app preparation: Kane resolves `app:` relative to the test file, not the repo cwd. `./builds/Weave.zip` resolved to `Tests/Kane/setup/builds/Weave.zip`. Corrected test metadata to `../../../builds/Weave.zip` for area folders (and the separate Release ZIP likewise). This is a test-path error, not a product regression; all assertions were preserved. The live green run remains valid; the failed replay is not a pass.

## uc-4: reviewed sharing, AI privacy, and fallback

Design completed with terminal complete and process exit 0 (22.23 credits) under CLI 0.10.0-rc.3. Six scenarios produced six tests. Corrected generated Android execution metadata and the explicit “Launch Weave on the Android emulator” phrase to iOS Simulator, because Weave is an iOS-only app in the source spec. All other generated actions/assertions and assurance blocks are preserved. Added `[smoke, ai]` tags, the recorded iPhone 17 Pro / 26.5 pair, and `app: ../../../builds/Weave.zip` relative to each test file, following the actual M0 replay path diagnosis.

The design declares six unset setup/text variables: `private_reason_fixture`, `completed_extension_fixture`, `ai_failure_fixture`, `post_failure_fixture`, `post_retry_fixture`, and `share_card_text`. Tests are designed, not executed. The privacy test groups five draft runs in one step; the M5 gate still requires five completed independent runs with stored draft values and evidence, and no failed/skipped run may count. The output warns that derived criteria are not yet approved. No product pass is claimed.

## uc-5: group overview and fetch failure

Design completed with terminal complete and process exit 0 (15.04 credits), producing two tests under CLI 0.10.0-rc.3. Corrected generated Android execution metadata to the specified iOS Simulator, used the test-relative simulator ZIP path, and added `[smoke, groups]` tags. Generated bodies and assurance links are unchanged. The added `group_fetch_failure_fixture` remains unset; credentials and the balance fixture are also required. Both tests are unexecuted. Derived-criteria approval warnings and three generated gaps remain visible in the captured output.

## Remaining design limitations

The four remaining use-case designs completed sequentially with no pause, using 74.91 credits in total. They produced 15 tests, all moved into `Tests/Kane/`; no design result is a UI pass. Credentials and generated fixtures must be supplied before authoring. SQL concurrency/RLS and the Release build remain separate verification work. A final journey test, Debug reset helper, and runnable deterministic app-side fixture controls must still be designed/configured for the later milestones.

## M1 fixture and setup review

All 46 generated criterion texts were read and matched against the supplied requirements; approvals are recorded in criteria-review-verdicts.json. This resolves derived-criterion approval warnings, without claiming execution. M1 introduces persistent Keychain sessions, so the M0 blank-shell smoke now explicitly resets via Debug before checking the same four controls. The old always-signed-out startup assumption no longer holds; assertions are unchanged. Its embedded M0 context was updated to acknowledge the implemented Debug tab. One-shot failure fixture directions are configured in ignored Kane variables.
