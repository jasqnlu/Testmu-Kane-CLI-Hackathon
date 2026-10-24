---
assurance:
  id: t-6
  base: sha256:9580d0f30adaea6a4359f8eb431f30a7afbbaa1ebe627d4acc32fa59cded95a7
target: simulator
app: ../../../builds/Weave.zip
device_name: iPhone 17 Pro
os_version: "26.5"
mode: testing
tags: [smoke, extensions]
---

# Keep the balance at 30 after duplicate confirmation

> Duplicate confirmation attempts resolve to the original reservation and extension and balance remains 30.

## Step 1

Launch the Weave app; from its entry screen access Alice's Study group at the personal limit using {{valid_email}} and {{valid_password}}, with {{balance_40_fixture}} establishing its 40-credit balance.

## Step 2 @verifies ac-19, ac-13

In Weave's personal-limit extension flow for the Study group, request a 10-minute extension, then double-tap Confirm on the 10-credit confirmation sheet; at the resulting extension state, assert the displayed group balance is 30 credits and no active extension without a valid expiry is shown.
