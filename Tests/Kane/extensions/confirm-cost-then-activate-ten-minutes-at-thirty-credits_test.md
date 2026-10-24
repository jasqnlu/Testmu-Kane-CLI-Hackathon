---
assurance:
  id: t-8
  base: sha256:fa0de8c824b9de064600289e950a27712e7cfd0dd7af20597e3b2024324074ba
target: simulator
app: ../../../builds/Weave.zip
device_name: iPhone 17 Pro
os_version: "26.5"
mode: testing
tags: [smoke, extensions]
---

# Confirm cost then activate ten minutes at thirty credits

> Confirm sheet quotes 10 minutes and 10 credits before explicit confirmation, then balance becomes 30 credits and extension has expiry.

## Step 1

Launch the Weave app; from its entry screen access Alice's Study group at the personal limit using {{valid_email}} and {{valid_password}}, with {{balance_40_fixture}} establishing its 40-credit balance.

## Step 2 @verifies ac-23, ac-10

In Weave's personal-limit extension flow for the 40-credit Study group, request a 10-minute extension and reach its confirmation sheet without confirming; then assert it displays "10 minutes · 10 credits" and the group balance remains 40 credits.

## Step 3 @verifies ac-24, ac-25, ac-13

On that 10-credit confirmation sheet in Weave, explicitly Confirm the 10-minute extension; at its resulting state, assert the balance displays 30 credits and the banner reads "Extension active, ends at HH:MM" with a valid expiry.
