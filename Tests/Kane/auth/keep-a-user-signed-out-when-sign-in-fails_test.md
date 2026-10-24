---
assurance:
  id: t-2
  base: sha256:83bafca3b9c5173fef55706c68664db0b4becd4058d473991467565007a13292
target: simulator
app: ../../../builds/Weave.zip
device_name: iPhone 17 Pro
os_version: "26.5"
mode: testing
tags: [smoke, auth]
---

# Keep a user signed out when sign-in fails

> A sign-in attempt that fails independently of invalid credentials leaves the user signed out with a clear error and no other user's group.

## Step 1

Launch the Weave app; from its entry screen reach the email-and-password sign-in surface.

## Step 2

Establish {{sign_in_failure_fixture}} so an attempted sign-in with otherwise valid credentials fails independently of credential validity.

## Step 3 @verifies ac-1, ac-2, ac-3

On Weave's sign-in surface, attempt sign-in with {{valid_email}} and {{valid_password}} under {{sign_in_failure_fixture}}, then assert a clear sign-in error is shown, the user remains signed out, and no other user's group is shown.
