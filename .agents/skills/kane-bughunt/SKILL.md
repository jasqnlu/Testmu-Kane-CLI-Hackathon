---
name: kane-bughunt
description: Use after a feature first passes, to explore its edges with Kane bug detection and find real defects before judges do.
---

**Goal:** at least one honest red-then-green story with evidence.

1. Pick the feature's riskiest edges: double-tapping Confirm, requesting more minutes than the balance, backgrounding mid-request, the mock provider failing activation (Debug tab → **Fail next activation**).
2. Explore each with bug detection on: `kane-cli run "<edge objective>" --bug-detection continue --agent`.
3. Any confirmed bug: write a `_test.md` that reproduces it, run it to capture the red pack, fix, rerun green, commit with trailers. Mark it **found-by-exploration** in `KANE_LOG.md`.
4. Copy both packs (red and green) into `evidence/packs/` via `kane-evidence`.
