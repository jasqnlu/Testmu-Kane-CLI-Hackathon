---
assurance:
  id: t-3
  base: sha256:0c1752e90e0900e0e38746119193da1c960cf726bad0c943e514ae0461e8f489
target: simulator
app: ../../../builds/Weave-Release.zip
device_name: iPhone 17 Pro
os_version: "26.5"
mode: testing
tags: [release, auth]
---

# Release app does not expose debug UI

> In a Release build, the app does not show a Debug tab or debug-only controls.

## Step 1 @verifies ac-7

Launch the Weave Release app; inspect its app navigation from the entry screen, then assert no Debug tab is present.

## Step 2 @verifies ac-8

In the Weave Release app, inspect reachable sign-in and authenticated group surfaces using {{valid_email}} and {{valid_password}}, then assert no debug-only controls appear on those surfaces.
