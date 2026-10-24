# Weave evidence index

**Submission status: not ready.** M1 auth/group and M2 extension flows have validated Kane evidence. M3 RECOV-01 has a validated pre-guard red and green rerun; the four-test extension regression suite passed. CREDIT-01 SQL concurrency verification remains pending. The M2 pre-guard CREDIT-02 red is missing because the server guard was already present in the starting worktree. Remaining product flows and submission gates are open. Empty cells below mean unverified, not passing.

| Requirement | Test file | Red pack | Green pack | What Kane caught |
| --- | --- | --- | --- | --- |
| AUTH-01 | Tests/Kane/auth/existing-user-sees-their-name-after-sign-in_test.md; Tests/Kane/auth/reject-invalid-credentials-without-exposing-a-group_test.md; Tests/Kane/auth/keep-a-user-signed-out-when-sign-in-fails_test.md | — | [M1_auth_groups_smoke.evidence](packs/M1_auth_groups_smoke.evidence) | Kane passed valid sign-in, invalid credentials, and forced sign-in failure; user stayed signed out on errors. |
| GROUP-01 | Tests/Kane/groups/show-alice-s-study-members-and-40-credit-balance_test.md; Tests/Kane/groups/show-error-instead-of-fetched-data-when-study-group-fetch_test.md | — | [M1_auth_groups_smoke.evidence](packs/M1_auth_groups_smoke.evidence) | Kane passed member/balance display and the fetch-error state with no fetched balance or members. |
| CREDIT-01 | Pending | — | — | Not yet verified |
| CREDIT-02 | [reject-a-ten-minute-request-at-five-credits_test.md](../Tests/Kane/credits/reject-a-ten-minute-request-at-five-credits_test.md) | — | [CREDIT-02_green_20261024.evidence](packs/CREDIT-02_green_20261024.evidence) | Kane confirmed a 10-minute request is rejected at 5 credits and the balance stays 5; no pre-guard red was available in the starting worktree. |
| EXT-01 | [cancel-and-dismiss-without-activating-or-spending_test.md](../Tests/Kane/extensions/cancel-and-dismiss-without-activating-or-spending_test.md) | — | [M2_extensions_green_20261024.evidence](packs/M2_extensions_green_20261024.evidence) | Kane confirmed cancelling or dismissing the confirmation sheet leaves the 40-credit balance untouched. |
| EXT-02 | [confirm-cost-then-activate-ten-minutes-at-thirty-credits_test.md](../Tests/Kane/extensions/confirm-cost-then-activate-ten-minutes-at-thirty-credits_test.md) | — | [M2_extensions_green_20261024.evidence](packs/M2_extensions_green_20261024.evidence) | Kane confirmed an explicit 10-credit confirmation leaves 30 credits and shows an active extension with an expiry. |
| EXT-03 | [keep-the-balance-at-30-after-duplicate-confirmation_test.md](../Tests/Kane/extensions/keep-the-balance-at-30-after-duplicate-confirmation_test.md) | — | [EXT-03_preexisting_ui_guard_green_20261024.evidence](packs/EXT-03_preexisting_ui_guard_green_20261024.evidence) | Double-tap Confirm kept the balance at 30 on the existing M2 baseline, which already blocks confirmation while busy. |
| RECOV-01 | [show-failure-and-restore-credits-after-failed-activation_test.md](../Tests/Kane/extensions/show-failure-and-restore-credits-after-failed-activation_test.md) | [RECOV-01_red_20261024.evidence](packs/RECOV-01_red_20261024.evidence) | [RECOV-01_green_20261024.evidence](packs/RECOV-01_green_20261024.evidence) | At testmd step 2 (nested run assertion step 4), Kane caught the debit remaining after activation failure; the rerun confirmed the error appears and the 40-credit balance is restored with no active extension. |
| PRIV-01 | [keep-alice-s-completed-extension-out-of-the-group-feed_test.md](../Tests/Kane/privacy/keep-alice-s-completed-extension-out-of-the-group-feed_test.md); [keep-alice-s-private-reason-out-of-bob-s-group-feed_test.md](../Tests/Kane/privacy/keep-alice-s-private-reason-out-of-bob-s-group-feed_test.md) | [PRIV-01_red_20261024.evidence](packs/PRIV-01_red_20261024.evidence) | [PRIV-01_green_20261024.evidence](packs/PRIV-01_green_20261024.evidence) | Kane confirmed Bob could see Alice’s private reason, “chemistry test anxiety,” in the group feed (testmd step 4, nested assertion step 3). After the feed filter, the committed checks passed for both the card and reason being absent; the separate SQL RLS check also passed. The later neighbor suite exposed a seed-before-sign-in flow and a whole-screen card selector in its test recordings; see [diagnostic suite pack](packs/PRIV-01_neighbor_suite_diagnostic_20261024.evidence), not a product red.
| SHARE-01 | Pending | — | — | Not yet verified |
| SHARE-02 | [post-alice-s-edited-extension-card-after-review_test.md](../Tests/Kane/ai/post-alice-s-edited-extension-card-after-review_test.md) (related committed flow; direct Kane objective run) | — | [SHARE-02_fallback_post_20261024.evidence](packs/SHARE-02_fallback_post_20261024.evidence) | Kane verified one Alice card with the edited text after explicit Post, with the private reason absent. This used the no-key fallback, not an OpenAI draft. |
| AI-01 | Share → AI draft → edit → Post (short objective) | — | [AI-01_post_guard_green_20261024.evidence](packs/AI-01_post_guard_green_20261024.evidence) | Passed with source=openai; edited card posted once and private reason absent. |
| AI-02 | Fresh OpenAI draft privacy samples | — | [AI-02_sample_1_20261024.evidence](packs/AI-02_sample_1_20261024.evidence) | 2/5 sampled so far; see KANE_LOG.md. |
| SAFE-01 | Pending | — | — | Not yet verified |

The full M3 extension regression suite is [M3_extensions_green_20261024.evidence](packs/M3_extensions_green_20261024.evidence) (4/4, 9 criteria).

## Final demo evidence

- Journey (`journey_final.evidence`): pending.
- Smoke suite (`smoke_final.evidence`): pending.
- Merged submission pack (`weave-final`): pending.
- M1 Kane coverage: 9 of 46 criteria proven, 37 owed (25.9% risk-weighted coverage); [Kane cover report](coverage-m1.ndjson) and [validated pack](packs/M1_auth_groups_smoke.evidence). Historical M0 report: [coverage](coverage-m0.ndjson) and [gaps](coverage-gaps-m0.ndjson).

Validate selected packs with `kane-cli evidence validate <path>` before indexing them. View a saved pack locally with `kane-cli evidence serve evidence/packs/<file>`.

## What Kane caught

- **M5 AI-02 privacy sample 2/5:** A second fresh Kane run returned source=openai and “Great work! You used 10 group minutes this afternoon and completed a group extension. Nice achievement!”; checked privacy terms were absent. The editor was cancelled without posting. Pack: [AI-02 sample 2](packs/AI-02_sample_2_20261024.evidence).
- **M5 AI-02 privacy sample 1/5:** Fresh Kane run returned source=openai and the draft “Nice work this afternoon! You used 10 group minutes and completed a group extension.”; checked privacy terms were absent. The editor was cancelled without posting. Pack: [AI-02 sample 1](packs/AI-02_sample_1_20261024.evidence).
- **M5 AI-01 green:** Kane verified Share → OpenAI draft → edit → Post in session `d0eda25c-0b1a-485f-a932-6ff0ce26529e` (run-0, exit 0). It confirmed the editor used OpenAI, the private reason was absent from the draft, the edited walk card appeared once, and the reason stayed out of the feed. Pack: [AI-01 post-guard green](packs/AI-01_post_guard_green_20261024.evidence).
- **M5 AI-01 agent misstep:** session `bf2bdaa6-8c65-46dc-8b75-5dc690dce560` posted the card successfully with OpenAI source and passed its privacy check, then the agent continued into a later group-load error and marked the run failed. No card or privacy defect was confirmed. Pack: [post-after-success misstep](packs/AI-01_post_guard_after_post_agent_misstep_20261024.evidence).
- **M4 PRIV-01 red/green pair complete:** the pre-guard Bob-feed test failed at nested run step 3 with Alice's private reason visible; the post-filter rerun passed. Packs: [PRIV-01 red](packs/PRIV-01_red_20261024.evidence) and [PRIV-01 green](packs/PRIV-01_green_20261024.evidence).
- **M5 headless session-store issue (environment):** the OpenAI baseline Kane session registered a test but stalled before any test step or terminal event. The local Kane process was stopped, and the dedicated iPhone 17 Pro simulator was shut down and erased. This is an environment issue, not a product bug; it is not counted as a run.
- **M5 direct function probe:** The first authenticated call returned fallback because OpenAI reported exhausted API credits. After the user added $5, a second direct call returned HTTP 200 with `source: openai`; the redacted 71-character draft is indexed at [successful direct probe](packs/AI-01_direct_openai_success_20261024.json). This proves the deployed API path, but it is not a Kane AI-01 or AI-02 pass.
- **M5 AI-01 test navigation misstep:** Kane's committed test seeded a completed extension and then tried to open Share with Group from its noninteractive summary card. The app only offers that action while the extension is active; Kane did not reach the editor or test draft-card. No product defect was confirmed. See [navigation diagnostic pack](packs/AI-01_baseline_test_navigation_misstep_20261024.evidence).
- **M5 AI-01 authoring misstep:** Reauthoring repeated the setup order error: seed private-reason before sign-in, leaving Kane on the completed summary with no Share action. No draft request was made and no product defect was confirmed. See [authoring diagnostic pack](packs/AI-01_test_author_misstep_20261024.evidence).
- **M5 AI-01 false paraphrase classification:** On the third attempt, Kane reached an OpenAI draft, but its agent treated generic activity text (“You used 10 group minutes”) as a paraphrase of “chemistry test anxiety” and stopped before edit/Post. The terminal result itself said the draft did not repeat or restate the reason. No product defect was confirmed; the three-attempt limit for this test is reached. See [final baseline diagnostic pack](packs/AI-01_baseline_false_paraphrase_misstep_20261024.evidence).

- **Environment issue — M1 headless sign-in:** The ad hoc signed simulator app had no Keychain access group, so its first saved-session lookup failed. This was an environment issue, not a product bug; simulator-only Debug builds now store the session in the app sandbox.
- **RECOV-01 — failed activation kept the debit:** Pre-guard run `c0448d15-2859-40a5-ace0-c7ec70f39f85` (execution `8c24563e-1539-46e7-a1cf-931214f0e697`) confirmed at testmd step 2 / nested run step 4 that the group balance stayed at 30 credits instead of the asserted 40, and the app showed a device-application error. A confirmed extension remained visible with an expiry. Full red evidence is in [RECOV-01_red_20261024.evidence](packs/RECOV-01_red_20261024.evidence). After reconciliation, green run `5717888e-31fa-436a-8752-fea8f88b9133` (execution `53296f8d-5a9e-4934-829c-89b934bbb4dc`) verified “Couldn't start extension,” balance 40, and no active extension; validated green evidence is in [RECOV-01_green_20261024.evidence](packs/RECOV-01_green_20261024.evidence).

- **PRIV-01 — private reason leaked to Bob:** Pre-guard session `e9f64341-9186-422f-b724-5d82de8b436a` (execution `897330c8-1d3a-4539-b0f7-60eb251215c9`) failed at testmd step 4 / nested run step 3: Bob’s feed showed “chemistry test anxiety.” See [PRIV-01_red_20261024.evidence](packs/PRIV-01_red_20261024.evidence). The earlier Alice-only test passed visually, but an authenticated feed RPC check found the same private text in its response.
- **PRIV-01 — feed filter rerun:** Post-guard testmd session `1bcfbfb7-bfa8-4ff7-8f6d-1882fa983012` (evidence `8182fb07-72e2-49c6-96c3-168f0c629707`) passed, exit 0. Kane replayed Alice’s Keep Private flow, then as Bob asserted the private completion card and “chemistry test anxiety” were absent. Validated pack: [PRIV-01_green_20261024.evidence](packs/PRIV-01_green_20261024.evidence).
- **PRIV-01 — neighbor-suite test issues:** Suite execution `06bf55ab-9165-4130-9b4c-645162a47186` failed for two test-specific reasons: its Alice seed action ran before authentication, and its Bob card selector matched Alice’s completed-extension summary outside the feed. Kane classified the latter as a broken assertion with no confirmed product defect. The standalone Bob rerun passed. See [diagnostic suite pack](packs/PRIV-01_neighbor_suite_diagnostic_20261024.evidence); the suite needs an assurance-flow correction and rerun.
- **M5 — missing-key fallback only:** Kane run `c68f53b9-5f43-440f-89bc-26ea78e992a3` verified the deployed Edge Function fallback opened the editable draft and left it unpublished. The stored text was `Alice used 10 group minutes.` No OpenAI request occurred; see [AI-02 missing-key fallback pack](packs/AI-02_missing-key_fallback_20261024.evidence). This is not an AI-01 pass.
- **SHARE-01 — fallback assertion misstep:** In session `390e35db-46f7-40e5-b09f-48e3b270c959`, Kane saw the generic fallback draft but its final evaluator labeled that text a paraphrase of “chemistry test anxiety.” The terminal verdict classified this as a broken assertion/agent misstep with no confirmed product defect. See [SHARE-01 fallback assertion diagnostic](packs/SHARE-01_fallback_assertion_misstep_20261024.evidence). A reliable paraphrase check remains open.
- **M3 extension bughunt:** Kane found no confirmed product defect; the session ended as an agent misstep because it analyzed before tapping Confirm. See [bughunt pack](packs/M3_extension_bughunt_agent_misstep_20261024.evidence).

## Not verified by Kane

- Ledger concurrency (CREDIT-01): requires SQL concurrency tests; execution pending.
- RLS privacy (PRIV-01 database half): one authenticated Bob-versus-Alice reason isolation SQL check passed; wider RLS policy coverage remains limited.
- M1 authenticated API/RLS privilege probes passed outside Kane; see [safe backend summary](backend-m1-api-checks.json). Dedicated SQL concurrency and privacy tests remain pending.
- Real Screen Time shielding: requires a physical device; not verified at hackathon. Simulator uses a deterministic mock provider.
- Release debug exclusion (SAFE-01): requires code review and unit/build checks; execution pending.

## Submission gates still open

- Public repository confirmed; existing October23 Pacific documentation history requires organizer interpretation of the same-day gate.
- Product OpenAI call verified from the Supabase draft-card Edge Function.
- Real red→green pair, green journey, and green smoke suite saved and validated.
- Requirement-linked committed replay tests, completed assurance loop, and exploration recorded.
- AI privacy gate: fresh AI-02 sample count to be recorded after sampling; fallback checked.
- Final merged pack path identified for attachment.

## M0 setup evidence

| Check | Test | Result | Pack |
| --- | --- | --- | --- |
| Blank sign-in shell (setup only) | Tests/Kane/setup/m0_signin_smoke_test.md | Live objective passed, exit 0; not AUTH-01 | [M0_signin_green.evidence](packs/M0_signin_green.evidence) |

| Saved replay (setup only) | Tests/Kane/setup/m0_signin_smoke_test.md | test_md_done passed + exit 0 | [M0_replay_green.evidence](packs/M0_replay_green.evidence) |
| Build + setup suite | Scripts/verify.sh smoke | 1/1 passed, testrun_done + exit 0 | [M0_setup_suite_green.evidence](packs/M0_setup_suite_green.evidence) |

## M1 auth and group evidence

| Check | Test | Result | Pack |
| --- | --- | --- | --- |
| Auth, groups, setup smoke | `Scripts/verify.sh smoke` | 6/6 passed, 0 failed/broken/skipped, testrun_done + exit 0; 9 criteria proven across AUTH-01 and GROUP-01 | [M1_auth_groups_smoke.evidence](packs/M1_auth_groups_smoke.evidence) |

The first auth attempt exposed a simulator-only session-store failure because the headless Kane build is ad hoc signed without a Keychain access group. The test was stopped before its completion event; it is not a feature pass. Simulator builds now keep their test session in the app sandbox, while device builds continue to use Keychain. The rerun and full M1 smoke suite passed. The simulator store contains test credentials only and is not used by device builds.

All three integrity validations exited 0. Initial attempts found an Xcode27 Simulator.app path incompatibility and a saved-test relative ZIP path error; neither is product red/green evidence. Authentication, credits, privacy, AI and full journey remain unverified. Raw agent streams and assurance verdicts are retained alongside this index.
