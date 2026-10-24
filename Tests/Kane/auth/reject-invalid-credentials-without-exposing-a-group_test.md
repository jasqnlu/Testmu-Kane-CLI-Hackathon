---
assurance:
  id: t-1
  base: sha256:14a76e08c2ec23e9b591f70e0a08fe256942b4f0b4d41981f2ecbf07a1cceeec
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
