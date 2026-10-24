---
name: kane-assure
description: Use when Requirements/acceptance-criteria.md is created or changed. Turns requirements into a designed, requirement-linked Kane test suite and a coverage report.
---

**Goal:** tests derived from the spec, not from whatever the code happens to do. This is the assurance loop the Range points reward.

1. `kane-cli context ingest Requirements/acceptance-criteria.md`
2. `kane-cli context extract` (use the headless mode flag shown by `kane-cli context extract --help`). Every proposed use-case must cite the requirement IDs.
3. `kane-cli context review`. Approve proposals that match a requirement ID exactly; reject invented ones. If headless review needs a verdicts file, write `Requirements/review-verdicts.json` and commit it, so the decisions are visible.
4. For each approved use-case: `kane-cli design tests --use-case <ref>`. Move generated `_test.md` files into `Tests/Kane/<area>/` and add `tags:` frontmatter (`smoke`, plus the area: `auth`, `groups`, `credits`, `extensions`, `privacy`, `ai`).
5. Read every generated test. If a step contradicts the requirement, fix the test and note it in the commit.
6. `kane-cli cover` and `kane-cli cover gaps`. Save output to `evidence/coverage-<time>.txt`.
7. When a requirement changes later: `kane-cli maintain reconcile`, then repeat 4 to 6.

Commit: `test(assure): design suite from acceptance criteria` with a `Req:` trailer listing IDs covered.
