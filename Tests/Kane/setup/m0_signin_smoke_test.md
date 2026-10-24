---
mode: testing
tags: [smoke, setup]
max_steps: 50
target: simulator
app: ../../../builds/Weave.zip
os_version: '26.5'
device_name: iPhone 17 Pro
local_context: >-
  Weave is now at M1. A Debug tab is present. For this setup test, open Debug,
  tap Reset to clear any restored session, and return to Sign in before checking
  the email, password and sign-in controls. Other features are unverified.
variables:
  global.valid_email:
    value: ''
    secret: false
    syntax: '{{valid_email}}'
    type: global
  secrets.user.valid_password:
    value: ''
    secret: true
    syntax: '{{valid_password}}'
    type: secret
  secrets.user.incorrect_password:
    value: ''
    secret: true
    syntax: '{{incorrect_password}}'
    type: secret
  global.unrecognized_email:
    value: ''
    secret: false
    syntax: '{{unrecognized_email}}'
    type: global
  global.sign_in_failure_fixture:
    value: ''
    secret: false
    syntax: '{{sign_in_failure_fixture}}'
    type: global
  global.expected_user_name:
    value: ''
    secret: false
    syntax: '{{expected_user_name}}'
    type: global
  global.balance_40_fixture:
    value: ''
    secret: false
    syntax: '{{balance_40_fixture}}'
    type: global
  global.balance_5_fixture:
    value: ''
    secret: false
    syntax: '{{balance_5_fixture}}'
    type: global
  global.activation_failure_fixture:
    value: ''
    secret: false
    syntax: '{{activation_failure_fixture}}'
    type: global
---

# Session: m0_signin_smoke

## Step 1
Open Weave, open the Debug tab, tap Reset, return to the Sign in tab, and verify the sign-in screen is visible with Email, Password, and Sign in controls
