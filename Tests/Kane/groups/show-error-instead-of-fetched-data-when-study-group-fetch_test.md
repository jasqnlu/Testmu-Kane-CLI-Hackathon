---
assurance:
  id: t-18
  base: sha256:6906a26b98543b534c876bc0dc69b6c1f46b2036aee82d0c1cea99d3e6e04df2
target: simulator
app: ../../../builds/Weave.zip
device_name: iPhone 17 Pro
os_version: "26.5"
mode: testing
tags: [smoke, groups]
---

# Show error instead of fetched data when Study group fetch fails

> When fetching the Study group fails, the screen displays an error instead of invented members or a balance.

## Step 1 @verifies ac-44, ac-45, ac-46

Launch the Weave app; from its entry screen establish Alice's signed-in session with {{valid_email}} and {{valid_password}} and reach the Study group screen while {{group_fetch_failure_fixture}} makes its group fetch fail, then assert a group-fetch error is shown, no members are presented as fetched, and no credit balance is presented as fetched.
