---
assurance:
  id: t-4
  base: sha256:4e48b5611eb84cb3432b463852602a4e54374da0d4b9dd1eec13c5c9ff9b15aa
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
