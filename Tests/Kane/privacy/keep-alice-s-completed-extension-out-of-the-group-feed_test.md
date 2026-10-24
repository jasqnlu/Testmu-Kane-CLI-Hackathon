---
assurance:
  id: t-10
  base: sha256:5020e5216caefa549730b353f7adf5b868aef5e6739ffb30febe53908d242558
target: simulator
app: ../../../builds/Weave.zip
device_name: iPhone 17 Pro
os_version: "26.5"
mode: testing
tags: [smoke, privacy]
---

# Keep Alice's completed extension out of the group feed

> Alice completes an extension with a private reason and chooses Keep Private, without creating a group feed card for that extension.

## Step 1

Launch the Weave app; from its entry screen, reach the member sign-in flow.

## Step 2

Sign in as Alice using {{valid_email}} and {{valid_password}}, and reach her extension flow.

## Step 3

Complete an extension with the private reason 'chemistry test anxiety' and reach its sharing choice.

## Step 4 @verifies ac-28

Choose Keep Private for Alice's completed extension and inspect the group's feed, then assert there is no feed card for that extension.
