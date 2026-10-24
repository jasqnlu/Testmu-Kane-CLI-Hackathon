# Weave test environment

- Date: 2026-10-24, America/Los_Angeles.
- Host: Apple Silicon (arm64), Xcode 27.0 (27A266a).
- Kane CLI: started at 0.9.0; later commands observed 0.10.0-rc.3. Authenticated; starting balance 101,200.
- Selected device: `iPhone 17 Pro`, OS `26.5`, exactly from Kane's device list.
- Build: `Scripts/build-sim.sh`, Debug simulator; exit 0, `builds/Weave.zip`.
- Simulator doctor: exit 0 after installing managed dependencies 0.0.1 and allowing CoreSimulator sandbox access.
- Initial smoke: environment failure, exit 2, no terminal result or UI steps. Appium expected obsolete Simulator.app; Xcode27 provides DeviceHub.app instead.
- Smoke verification: supported headless Appium retry passed (run_end + exit 0); saved replay passed (test_md_done + exit 0, 52 seconds). Setup suite passed: Scripts/verify.sh smoke, 1/1 tests, testrun_done passed and exit 0. No feature requirement is passing.
