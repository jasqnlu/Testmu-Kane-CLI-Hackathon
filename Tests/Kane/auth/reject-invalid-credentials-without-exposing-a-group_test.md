---
assurance:
  id: t-1
  base: sha256:e3784f37eee460aff8bf328f6d9fafc303f2f46bf595d8686fdc23712a63d5b7
target: simulator
app: ../../../builds/Weave.zip
device_name: iPhone 17 Pro
os_version: "26.5"
mode: testing
tags: [smoke, auth]
---

# Reject invalid credentials without exposing a group

> Invalid email/password combinations leave the user signed out with a clear error and without exposing another user's group.

## Step 1

Launch the Weave app; from its entry screen reach the email-and-password sign-in surface.

## Step 2 @verifies ac-1, ac-2, ac-3

On Weave's sign-in surface, attempt sign-in with {{valid_email}} and {{incorrect_password}}, then assert a clear sign-in error is shown, the user remains signed out, and no other user's group is shown.

## Step 3 @verifies ac-1, ac-2, ac-3

On Weave's sign-in surface, attempt sign-in with {{unrecognized_email}} and {{valid_password}}, then assert a clear sign-in error is shown, the user remains signed out, and no other user's group is shown.

## Step 4 @verifies ac-1, ac-2, ac-3

On Weave's sign-in surface, attempt sign-in with {{unrecognized_email}} and {{incorrect_password}}, then assert a clear sign-in error is shown, the user remains signed out, and no other user's group is shown.
