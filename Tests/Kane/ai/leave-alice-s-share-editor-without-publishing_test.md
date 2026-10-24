---
assurance:
  id: t-16
  base: sha256:0fc3847157853e74f35ee9ae7b88098aaac080df168e743ca634629c8ad65d57
target: simulator
app: ../../../builds/Weave.zip
device_name: iPhone 17 Pro
os_version: "26.5"
mode: testing
tags: [smoke, ai]
---

# Leave Alice's share editor without publishing

> After drafting or editing, exit the share editor without tapping Post and find no group card.

## Step 1

Launch Weave on the iOS Simulator; reach Alice's completed extension with stored reason 'chemistry test anxiety' using {{private_reason_fixture}}.

## Step 2 @verifies ac-32

From the completed extension open Share with Group and inspect the AI-generated draft in the editor, then assert neither the stored reason nor its paraphrase appears in that draft.

## Step 3 @verifies ac-31

For each available Cancel and dismiss exit from Alice's editor, leave an edited or untouched draft without tapping Post and inspect the Study group feed, then assert no card from the abandoned draft appears.
