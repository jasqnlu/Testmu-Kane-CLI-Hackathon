---
assurance:
  id: t-14
  base: sha256:e73d38000c42f8b92a9cf701bb28da5f3c3e98bf677f83df018b85984b1e2ed8
target: simulator
app: ../../../builds/Weave.zip
device_name: iPhone 17 Pro
os_version: "26.5"
mode: testing
tags: [smoke, ai]
---

# Show failure without claiming the extension card was posted

> Cause publication failure and show an error without claiming a card appeared in the group feed.

## Step 1

Launch Weave on the iOS Simulator; reach Alice's completed extension using {{completed_extension_fixture}} and prepare Share with Group with {{post_failure_fixture}} active.

## Step 2 @verifies ac-31

In Alice's share editor, prepare a distinguishable card using {{share_card_text}} and inspect the Study group feed before posting, then assert the unposted card is absent.

## Step 3 @verifies ac-35, ac-36

In Alice's share editor, attempt Post under the publication-failure fixture; inspect the resulting screen, then assert a posting error appears and no publication success claim appears.
