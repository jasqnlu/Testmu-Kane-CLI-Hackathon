---
assurance:
  id: t-10
  base: sha256:9737d4c2a1488fac8e625080c4cfc613719bd4fa04234a24655ea65599fb3540
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
