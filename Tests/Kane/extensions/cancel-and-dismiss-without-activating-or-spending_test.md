---
assurance:
  id: t-9
  base: sha256:f404e53e8f3810a09ea9973a6506c442215367541b08c4e4a441ae82b51de94e
target: simulator
app: ../../../builds/Weave.zip
device_name: iPhone 17 Pro
os_version: "26.5"
mode: testing
tags: [smoke, extensions]
---

# Cancel and dismiss without activating or spending

> At 40 credits, cancel or dismiss the confirmation sheet and retain balance without activating an extension.

## Step 1

Launch the Weave app; from its entry screen access Alice's Study group at the personal limit using {{valid_email}} and {{valid_password}}, with {{balance_40_fixture}} establishing its 40-credit balance.

## Step 2 @verifies ac-26, ac-10

In Weave's personal-limit extension flow for the 40-credit Study group, request 10 minutes and Cancel the 10-credit confirmation sheet; on returning to the extension flow, assert the group balance remains 40 credits and no extension is active.

## Step 3 @verifies ac-26, ac-10

With the Study group still at 40 credits in Weave's personal-limit extension flow, request 10 minutes again and dismiss the 10-credit confirmation sheet without Confirm; on returning to the flow, assert the group balance remains 40 credits and no extension is active.
