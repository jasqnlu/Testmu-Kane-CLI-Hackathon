---
test: ../confirm-cost-then-activate-ten-minutes-at-thirty-credits_test.md
status: passed
started: 2026-10-24T19:49:26.929Z
duration_s: 369
session_id: adfcb148-f6fe-409d-85e8-c58b0ddb00b5
---

# Confirm cost then activate ten minutes at thirty credits — Result

## Step 1 ✓ passed (58.65s)
md5: 034a02a7df6e9f2a23dc3ec9eb6ab9ac
Launch the Weave app; from its entry screen access Alice's Study group at the personal limit using {{valid_email}} and {{valid_password}}, with {{balance_40_fixture}} establishing its 40-credit balance.

## Step 2 ✓ passed (129.5s)
md5: ea44b59cfea94e6af7b192fe418cc047
In Weave's personal-limit extension flow for the 40-credit Study group, request a 10-minute extension and reach its confirmation sheet without confirming; then assert it displays "10 minutes · 10 credits" and the group balance remains 40 credits.

## Step 3 ✓ passed (89.1s)
md5: 3709723973126e88459c326d42713eee
On that 10-credit confirmation sheet in Weave, explicitly Confirm the 10-minute extension; at its resulting state, assert the balance displays 30 credits and the banner reads "Extension active, ends at HH:MM" with a valid expiry.
