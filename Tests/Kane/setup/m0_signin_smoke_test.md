---
mode: testing
tags: [smoke, setup]
max_steps: 50
target: simulator
app: ../../../builds/Weave.zip
os_version: '26.5'
device_name: iPhone 17 Pro
local_context: >-
  # Weave iOS test context


  Current milestone: M0 blank sign-in shell. The backend and Debug tab are not
  implemented yet. The behaviors below describe the acceptance target for later
  milestones, not existing functionality. For the M0 smoke objective, verify the
  sign-in screen only.


  Weave is an iOS app built with SwiftUI and Supabase. It turns extra screen
  time into a shared group credit budget. Private reasons remain private unless
  the user deliberately shares a reviewed activity card.


  Seeded test users are Alice, Bob, and Charlie. Their group is Study. The
  normal scenario starts with 40 credits; the low-balance scenario starts with 5
  credits. Credits appear on screen as "N credits". A 10-minute extension costs
  10 credits and requires an explicit Confirm tap.


  Debug builds include a Debug tab with Reset, Sign in as Alice, Sign in as Bob,
  Seed: normal, Seed: low-balance, Seed: private-reason, Set usage at limit, and
  Fail next activation controls. Use these controls to reset test state and
  control the deterministic mock ScreenTimeProvider. Real Screen Time
  enforcement is not available in the simulator.


  The confirmation sheet displays "10 minutes · 10 credits". Successful
  activation displays "Extension active, ends at HH:MM" and a 30-credit balance.
  Insufficient credits display "Not enough group credits". Failed activation
  displays "Couldn't start extension" and restores the reservation.


  Keep Private creates no group feed card. Share with Group opens an editable AI
  draft; it posts only after Post. The private-reason scenario uses "chemistry
  test anxiety"; the AI draft must not quote or paraphrase that reason. On AI
  failure the editor shows "Alice used 10 group minutes".


  Use only seeded test accounts. Credentials live in ignored .testmuai/variables
  files with secret: true; never include credentials in objectives or evidence
  summaries.
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
Open Weave and verify the sign-in screen is visible with Email, Password, and Sign in controls
