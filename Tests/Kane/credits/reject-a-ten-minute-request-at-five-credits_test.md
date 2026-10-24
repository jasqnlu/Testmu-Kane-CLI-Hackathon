---
assurance:
  id: t-7
  base: sha256:455a01e072328a5095892b29f60025fff27a530100316ff3726277ff0a409aee
target: simulator
app: ../../../builds/Weave.zip
device_name: iPhone 17 Pro
os_version: "26.5"
mode: testing
tags: [smoke, credits]
---

# Reject a ten-minute request at five credits

> At 5 credits reject request, show Not enough group credits, keep balance 5 with no activation.

## Step 1

Launch the Weave app; from its entry screen access Alice's Study group at the personal limit using {{valid_email}} and {{valid_password}}, with {{balance_5_fixture}} establishing a 5-credit balance.

## Step 2 @verifies ac-20, ac-21, ac-22, ac-13

In Weave's personal-limit extension flow for the 5-credit Study group, request a 10-minute extension; at the rejection state, assert "Not enough group credits" is shown, the displayed balance remains 5 credits, and no extension is active.
