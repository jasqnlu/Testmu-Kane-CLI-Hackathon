---
assurance:
  id: t-5
  base: sha256:b48c6beb898593fc6bb309bd77273b9b0b69337eff40d405db19cbb96d19ad99
target: simulator
app: ../../../builds/Weave.zip
device_name: iPhone 17 Pro
os_version: "26.5"
mode: testing
tags: [smoke, extensions]
---

# Show failure and restore credits after failed activation

> Fail provider activation, show Couldn't start extension, return balance to 40 and avoid repeated refunds.

## Step 1

Launch the Weave app; from its entry screen access Alice's Study group as a member at the personal limit using {{valid_email}} and {{valid_password}}, with {{balance_40_fixture}} establishing a 40-credit group balance and {{activation_failure_fixture}} configuring mock-provider activation failure.

## Step 2 @verifies ac-16, ac-17, ac-13

From the personal-limit extension flow in Weave, request 10 minutes against the 40-credit Study group balance and explicitly Confirm the 10-credit extension; on the resulting failure state, assert the error reads "Couldn't start extension" and the displayed balance is 40 credits and no extension without a valid expiry is shown.
