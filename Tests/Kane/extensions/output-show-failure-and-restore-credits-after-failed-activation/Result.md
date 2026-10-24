---
test: ../show-failure-and-restore-credits-after-failed-activation_test.md
status: passed
started: 2026-10-24T20:47:55.338Z
duration_s: 442
session_id: 8288cb81-4869-4752-8141-0e2f6fd5bcfb
---

# Show failure and restore credits after failed activation — Result

## Step 1 ✓ passed (246.2s)
md5: b921a0e511e38ec186b9f85cd245b026
Launch the Weave app; from its entry screen access Alice's Study group as a member at the personal limit using {{valid_email}} and {{valid_password}}, with {{balance_40_fixture}} establishing a 40-credit group balance and {{activation_failure_fixture}} configuring mock-provider activation failure.

## Step 2 ✓ passed (35.5s)
md5: 9d31c2ffc5ee7e3e66ef7ab3b49a09bd
From the personal-limit extension flow in Weave, request 10 minutes against the 40-credit Study group balance and explicitly Confirm the 10-credit extension; on the resulting failure state, assert the error reads "Couldn't start extension" and the displayed balance is 40 credits and no extension without a valid expiry is shown.
