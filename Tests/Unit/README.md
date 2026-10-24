# Session state regression checks

These five deterministic logic checks delay backend responses across Reset/account switching. They verify stale results and errors cannot overwrite the new session, persisted credentials, or loading state. They also verify sign-in remains usable when the initial group request returns unauthorized. The backend and credential store are in-memory fixtures: these checks do not access the network, Keychain, simulator, or UI.

Run from the repository root (macOS with Xcode):

```bash
mkdir -p build
xcrun swiftc -D DEBUG -parse-as-library \
  WeaveApp/Models/GroupSnapshot.swift \
  WeaveApp/Services/AppStore.swift \
  WeaveApp/Services/SupabaseService.swift \
  WeaveApp/Services/SessionKeychain.swift \
  WeaveApp/Services/ScreenTimeProvider.swift \
  Tests/Unit/FixtureConfiguration.swift Tests/Unit/SessionRaceChecks.swift \
  -o build/session-race-checks
build/session-race-checks
```

`FixtureConfiguration.swift` contains no credentials and is not part of the app target. Compile with this fixture instead of the ignored generated app configuration. A ten-second watchdog fails the checks if a regression prevents an expected async request from starting. Kane remains the UI verifier.
