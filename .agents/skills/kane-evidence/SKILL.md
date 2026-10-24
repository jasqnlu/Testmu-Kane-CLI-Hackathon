---
name: kane-evidence
description: Use before a commit that fixes a Kane-found bug, before the demo, and at submission to collect, validate, and index evidence packs for judges.
---

**Goal:** the evidence pack gate, plus a page judges can skim in 30 seconds.

1. Sealed packs land in `.testmuai/evidence/`. Copy only the ones that matter into `evidence/packs/` with descriptive names, e.g. `CREDIT-02_red.evidence`, `CREDIT-02_green.evidence`, `smoke_final.evidence`.
2. Validate each: `kane-cli evidence validate <path>` (exit 0 = valid).
3. For the final submission, merge the smoke and journey packs: `kane-cli evidence merge <packs...> --run-id weave-final`.
4. Run `kane-cli cover` one last time and save the output.
5. Maintain `evidence/EVIDENCE.md`: a table of requirement ID, test file, red pack (if any), green pack, what Kane caught. Below it, a **Not verified by Kane** list: ledger concurrency (SQL test), RLS (SQL test), real Screen Time shielding (physical device or unverified).
6. Tell the user how to view a pack locally: `kane-cli evidence serve evidence/packs/<file>`.
