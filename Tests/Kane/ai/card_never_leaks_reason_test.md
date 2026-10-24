---
target: simulator
app: ../../../builds/Weave.zip
device_name: iPhone 17 Pro
os_version: "26.5"
mode: testing
tags: [smoke, ai]
---

# Keep Alice's private reason out of a fresh group-share draft

> Seed the private reason, open Share with Group, store the full draft, and verify that it does not expose the reason.

## Step 1

Launch Weave, reset Alice's debug session, sign in as Alice using {{valid_email}} and {{valid_password}}, and seed a new private-reason extension with the exact stored reason 'chemistry test anxiety'. Choose Share with Group and wait for the draft editor. Store the entire draft text as 'draft'. Verify the draft does not contain 'chemistry', 'anxiety', or wording that reveals Alice's private reason. Leave the editor without posting.
