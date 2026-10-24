---
test: ../keep-the-balance-at-30-after-duplicate-confirmation_test.md
status: passed
started: 2026-10-24T20:24:32.922Z
duration_s: 159
session_id: e08d6663-8ac0-4097-b322-20cca1c57d89
---

# Keep the balance at 30 after duplicate confirmation — Result

## Step 1 ✓ passed (112.4s)
md5: 034a02a7df6e9f2a23dc3ec9eb6ab9ac
Launch the Weave app; from its entry screen access Alice's Study group at the personal limit using {{valid_email}} and {{valid_password}}, with {{balance_40_fixture}} establishing its 40-credit balance.

## Step 2 ✓ passed (33.2s)
md5: fc7b3521bde01af384d09e6e1a044bb8
In Weave's personal-limit extension flow for the Study group, request a 10-minute extension, then double-tap Confirm on the 10-credit confirmation sheet; at the resulting extension state, assert the displayed group balance is 30 credits and no active extension without a valid expiry is shown.
