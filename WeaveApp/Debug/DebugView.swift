#if DEBUG
import SwiftUI

struct DebugView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        NavigationStack {
            Form {
                Section("Test session") {
                    Button("Reset") { store.debugReset() }
                        .accessibilityIdentifier("debug.reset")
                    Button("Sign in as Alice") { Task { await store.debugSignIn("alice") } }
                        .accessibilityIdentifier("debug.signInAlice")
                    Button("Sign in as Bob") { Task { await store.debugSignIn("bob") } }
                        .accessibilityIdentifier("debug.signInBob")
                }
                Section("Server scenarios") {
                    Button("Seed: normal") { Task { await store.debugSeedNormal() } }
                        .accessibilityIdentifier("debug.seedNormal")
                    Button("Seed: low-balance — unavailable until M2") {}
                        .disabled(true)
                    Button("Seed: private-reason — unavailable until M4") {}
                        .disabled(true)
                }
                Section("Mock Screen Time") {
                    Button("Set usage at limit") { store.debugSetAtLimit() }
                        .accessibilityIdentifier("debug.setLimit")
                    Button("Fail next activation") { store.debugFailActivation() }
                        .accessibilityIdentifier("debug.failActivation")
                }
                Section("Network failure fixtures") {
                    Button("Fail next sign-in") { store.debugFailSignIn() }
                        .accessibilityIdentifier("debug.failSignIn")
                    Button("Fail next group fetch") { store.debugFailGroupFetch() }
                        .accessibilityIdentifier("debug.failGroupFetch")
                }
                if let notice = store.debugNotice {
                    Section("Status") { Text(notice).accessibilityIdentifier("debug.status") }
                }
            }
            .disabled(store.isBusy || store.isGroupLoading)
            .navigationTitle("Debug")
            .scrollContentBackground(.hidden)
            .background(WeaveStyle.cream)
        }
    }
}
#endif
