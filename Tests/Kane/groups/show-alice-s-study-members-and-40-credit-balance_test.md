---
assurance:
  id: t-19
  base: sha256:fa319a14d6352160faead696a30b6481717f05adb43557bdd605dbd1b78f55e1
target: simulator
app: ../../../builds/Weave.zip
device_name: iPhone 17 Pro
os_version: "26.5"
mode: testing
tags: [smoke, groups]
---

# Show Alice's Study members and 40-credit balance

> With Alice in Study and the stated example data, a successful fetch shows Alice, Bob, Charlie and 40 credits.

## Step 1 @verifies ac-42, ac-43

Launch the Weave app; from its entry screen establish Alice's signed-in session with {{valid_email}} and {{valid_password}} using {{balance_40_fixture}} for the Study group, then reach the group screen and assert Alice, Bob and Charlie appear in Study's member list and the group balance reads "40 credits".
