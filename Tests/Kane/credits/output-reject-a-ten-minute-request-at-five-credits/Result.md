---
test: ../reject-a-ten-minute-request-at-five-credits_test.md
status: passed
started: 2026-10-24T19:41:19.331Z
duration_s: 169
session_id: 1aa37404-78de-403b-82ce-1cc590c72691
---

# Reject a ten-minute request at five credits — Result

## Step 1 ✓ passed (112s)
md5: ba84decf6a32c8410d8da6bf41f9de3f
Launch the Weave app; from its entry screen access Alice's Study group at the personal limit using {{valid_email}} and {{valid_password}}, with {{balance_5_fixture}} establishing a 5-credit balance.

## Step 2 ✓ passed (35.4s)
md5: fc15843978536fd21442bbb4bc70b16f
In Weave's personal-limit extension flow for the 5-credit Study group, request a 10-minute extension; at the rejection state, assert "Not enough group credits" is shown, the displayed balance remains 5 credits, and no extension is active.
