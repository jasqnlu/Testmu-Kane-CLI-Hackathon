---
test: ../cancel-and-dismiss-without-activating-or-spending_test.md
status: passed
started: 2026-10-24T19:55:54.951Z
duration_s: 193
session_id: 342a219f-fd64-47fd-96fa-481c2d46445f
---

# Cancel and dismiss without activating or spending — Result

## Step 1 ✓ passed (98.5s)
md5: 034a02a7df6e9f2a23dc3ec9eb6ab9ac
Launch the Weave app; from its entry screen access Alice's Study group at the personal limit using {{valid_email}} and {{valid_password}}, with {{balance_40_fixture}} establishing its 40-credit balance.

## Step 2 ✓ passed (43.2s)
md5: 4c9cb3b29f58e57937eda1676b2fb42a
In Weave's personal-limit extension flow for the 40-credit Study group, request 10 minutes and Cancel the 10-credit confirmation sheet; on returning to the extension flow, assert the group balance remains 40 credits and no extension is active.

## Step 3 ✓ passed (41.4s)
md5: 3be63108312771299471b69e99397633
With the Study group still at 40 credits in Weave's personal-limit extension flow, request 10 minutes again and dismiss the 10-credit confirmation sheet without Confirm; on returning to the flow, assert the group balance remains 40 credits and no extension is active.
