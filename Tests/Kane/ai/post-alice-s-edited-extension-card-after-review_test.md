---
assurance:
  id: t-15
  base: sha256:6c1666e9711454938d6fc97f64f20bf69233917dc53bee2cc2d93b8c9c47edb6
target: simulator
app: ../../../builds/Weave.zip
device_name: iPhone 17 Pro
os_version: "26.5"
mode: testing
tags: [smoke, ai]
---

# Post Alice's edited extension card after review

> Open AI draft, edit it, keep feed unchanged before Post, then find exactly the edited text in Alice's group-feed card.

## Step 1

Launch Weave on the iOS Simulator; reach Alice's completed extension with stored private reason 'chemistry test anxiety' using {{private_reason_fixture}}.

## Step 2 @verifies ac-32, ac-38

From Alice's completed extension choose Share with Group and inspect the AI draft in the share editor, then assert the draft is editable and contains neither the stored reason nor a paraphrase.

## Step 3 @verifies ac-31

Edit the draft to {{share_card_text}} and inspect the Study group feed before pressing Post, then assert that unposted extension card is absent.

## Step 4 @verifies ac-37

Return to Alice's share editor and explicitly Post the edited card; inspect the Study group feed, then assert Alice's card shows {{share_card_text}}.
