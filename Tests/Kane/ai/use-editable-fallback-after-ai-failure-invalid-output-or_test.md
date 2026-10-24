---
assurance:
  id: t-17
  base: sha256:867fad48c52bbd2b2e2a25a9136f1c1e61ca5c9ae4a730d68052d34efd09207c
target: simulator
app: ../../../builds/Weave.zip
device_name: iPhone 17 Pro
os_version: "26.5"
mode: testing
tags: [smoke, ai]
---

# Use editable fallback after AI failure invalid output or timeout

> For OpenAI failure, invalid output, or timeout after 8 seconds, show the exact plain card in the editor and preserve editing, review and Post.

## Step 1

Launch Weave on the iOS Simulator; reach Alice's completed extension using {{completed_extension_fixture}} with {{ai_failure_fixture}} configured for OpenAI failure, invalid output and timeout after 8 seconds in separate iterations.

## Step 2 @verifies ac-39

For each configured failure mode, choose Share with Group on the completed extension and inspect Alice's editor, then assert the plain card text equals 'Alice used 10 group minutes'.

## Step 3 @verifies ac-40

Edit the fallback card to {{share_card_text}} in Alice's editor and inspect it before posting, then assert the edited text is present in the editor.

## Step 4 @verifies ac-31

While the edited fallback remains unposted, inspect the Study group feed, then assert no card from the unposted draft appears.

## Step 5 @verifies ac-41

Return to Alice's editor, review and explicitly Post the edited fallback; inspect the Study group feed, then assert Alice's edited fallback card appears.
