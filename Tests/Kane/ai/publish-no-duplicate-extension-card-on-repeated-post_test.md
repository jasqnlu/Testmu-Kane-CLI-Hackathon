---
assurance:
  id: t-13
  base: sha256:86fae864ae735484a3aa0542aaf4f52c9752acffc2f3a69c1115c489553ab16a
target: simulator
app: ../../../builds/Weave.zip
device_name: iPhone 17 Pro
os_version: "26.5"
mode: testing
tags: [smoke, ai]
---

# Publish no duplicate extension card on repeated Post

> Repeat a Post attempt and establish that one edited card, not duplicate cards, is published.

## Step 1

Launch Weave on the iOS Simulator; reach Alice's completed extension using {{completed_extension_fixture}} and open Share with Group.

## Step 2 @verifies ac-31

In the share editor, replace the draft with a distinguishable extension-card text using {{share_card_text}}, inspect the Study group feed before posting, then assert no card with that unposted text appears.

## Step 3 @verifies ac-34

Return to Alice's share editor and repeat the Post attempt for this same edited card using {{post_retry_fixture}}; inspect the Study group feed, then assert exactly one card matching the edited text appears.
