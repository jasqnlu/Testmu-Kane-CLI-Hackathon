---
assurance:
  id: t-12
  base: sha256:f1b2704c87f1c6786d7c27914d5d110c6696e12c5492ab37f79bbcf20ce5dd8a
target: simulator
app: ../../../builds/Weave.zip
device_name: iPhone 17 Pro
os_version: "26.5"
mode: testing
tags: [smoke, ai]
---

# Keep private reason out of five completed AI drafts

> With Alice's stored reason 'chemistry test anxiety', inspect five completed AI drafts and reject/regenerate contaminated drafts without publication.

## Step 1

Launch Weave on the iOS Simulator; enter Alice's completed extension with the stored private reason 'chemistry test anxiety' using {{private_reason_fixture}}.

## Step 2 @verifies ac-32, ac-33

From Alice's completed extension, choose Share with Group and inspect the AI-generated card in the share editor across five completed draft runs; reject incomplete runs, then assert five of five completed drafts contain neither 'chemistry test anxiety' nor a paraphrase of that stored reason.

## Step 3 @verifies ac-31

Without tapping Post on the inspected drafts, inspect the Study group feed, then assert no card from these unposted drafts appears.
