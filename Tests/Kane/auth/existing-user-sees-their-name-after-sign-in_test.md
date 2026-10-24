---
assurance:
  id: t-4
  base: sha256:2d437d75ef54b4f168a99e32dae0d20c16c0f0b196de0352faf637c9ba359694
target: simulator
app: ../../../builds/Weave.zip
device_name: iPhone 17 Pro
os_version: "26.5"
mode: testing
tags: [smoke, auth]
---

# Existing user sees their name after sign-in

> An existing user signs in with valid email and password and sees their own name on the group screen.

## Step 1

Launch the Weave app; from its entry screen reach the email-and-password sign-in surface.

## Step 2 @verifies ac-4

On Weave's sign-in surface, sign in as the existing user with {{valid_email}} and {{valid_password}}; on the resulting group screen, then assert the signed-in user's name {{expected_user_name}} is shown.
