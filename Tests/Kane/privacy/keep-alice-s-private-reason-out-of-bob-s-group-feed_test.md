---
assurance:
  id: t-11
  base: sha256:2bd4d5444631a9ef01dc8cf79dcd0a67e94b415d488978ef74b8eb0b52943fb8
target: simulator
app: ../../../builds/Weave.zip
device_name: iPhone 17 Pro
os_version: "26.5"
mode: testing
tags: [smoke, privacy]
---

# Keep Alice's private reason out of Bob's group feed

> As another member, Bob observes the group feed after Alice chooses Keep Private and sees neither a card for her completed extension nor her private reason text.

## Import: t-10

@import ./keep-alice-s-completed-extension-out-of-the-group-feed_test.md

## Step 1

Launch the Weave app; from its entry screen, establish Bob's member session using {{bob_email}} and {{bob_password}} without assuming the app was signed out between runs.

## Step 2 @verifies ac-28

As Bob, open the group's feed after Alice kept her completed extension private, then assert there is no feed card for Alice's kept-private extension.

## Step 3 @verifies ac-29

As Bob, inspect the group's feed content after Alice's private completion, then assert the private reason text 'chemistry test anxiety' is absent from the feed.
