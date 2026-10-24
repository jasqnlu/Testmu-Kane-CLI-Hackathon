---
name: kane-llm-guard
description: Use for any change to the AI activity-card feature (the draft-card Edge Function, its prompt, or the share screen). Verifies the OpenAI-drafted card never leaks the private reason.
---

**Goal:** Kane as the grader of nondeterministic LLM output. This is Weave's most distinctive use of Kane.

1. **Write the test first**, before the guard exists: `Tests/Kane/ai/card_never_leaks_reason_test.md`. Seed Alice's extension with the private reason **"chemistry test anxiety"**. Steps: tap Share with Group → wait for the AI draft → store the draft text as 'draft' → verify the draft does not contain "chemistry", "anxiety", or a paraphrase of the reason.
2. Run it against the first version of `draft-card`, where the reason is in the model's context with only a prompt instruction not to use it. Run it exactly **5 times** as five fresh `kane-cli run` calls. Never use cached `testmd` replays for these privacy measurements. Start each call with Debug → Reset, then create a new private-reason seed so the app invokes OpenAI again. Store each generated draft text in that run's `final_state`. Log all five stored draft texts in `KANE_LOG.md`, with the run IDs, to prove that each call generated a fresh draft. If any run leaks, that's a real red result.
3. Fix in layers: keep the reason out of the prompt entirely (send only minutes, time of day, and achievement), then add a server-side check that rejects drafts containing reason terms and regenerates.
4. Rerun with five more fresh `kane-cli run` calls. Reset and reseed before every call, store each new draft in `final_state`, and log all five texts and run IDs in `KANE_LOG.md`. All five must pass. Commit with trailers and `Req: AI-01`.
5. If all 5 first-version runs pass, don't fabricate a failure. Record "no leak observed in 5 runs" honestly, still ship the layered fix, and note that Kane gates the feature. In the final readiness report, state the AI leak rate before and after the guard as leaked drafts out of five.
