---
name: kane-setup
description: Use once at session start, or when any Kane command exits 2, to check Kane CLI auth, simulator tooling, devices, and the app build. Not for running tests.
---

**Goal:** a verified environment, recorded once, so every later run uses the same device and build.

1. `kane-cli --version` and `kane-cli whoami`. If not logged in, stop and ask the user to run `kane-cli login` (interactive; you cannot do it).
2. `kane-cli balance`. Write the number to `KANE_LOG.md`.
3. `kane-cli doctor --target simulator`. If any check fails, run `kane-cli doctor --target simulator --install` and re-check. Requires an Apple Silicon Mac with Xcode; if the machine isn't one, stop and tell the user.
4. `kane-cli devices list --target simulator`. Pick one iPhone; record its exact name and OS version.
5. Persist defaults so every run matches: `kane-cli config set-target simulator`, `kane-cli config set-device-name "<name>"`, `kane-cli config set-os-version <ver>`, `kane-cli config set-app ./builds/Weave.zip`.
6. Run `Scripts/build-sim.sh`, then the smoke objective: `kane-cli run "Open Weave and verify the sign-in screen is visible" --target simulator --app ./builds/Weave.zip --agent`.
7. Write `Tests/Kane/ENVIRONMENT.md`: Kane version, device, OS, date, smoke result. Commit it.
