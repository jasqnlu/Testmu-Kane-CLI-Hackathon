// Logic-only async regression checks. No network, Keychain, or UI automation.
import Foundation

@MainActor
private final class MemorySessions: SessionStoring {
    var value: AuthSession?
    init(_ value: AuthSession? = nil) { self.value = value }
    func load() -> AuthSession? { value }
    func save(_ session: AuthSession) { value = session }
    func clear() { value = nil }
}

private actor ControlledBackend: BackendServing {
    private var held: Set<String> = []
    private var groupWaiters: [String: CheckedContinuation<GroupSnapshot, Error>] = [:]
    private var refreshWaiters: [String: CheckedContinuation<AuthSession, Error>] = [:]
    private var arrivals: [String: [CheckedContinuation<Void, Never>]] = [:]
    var rejectNextGroup = false

    func hold(_ operation: String) { held.insert(operation) }
    func rejectGroup() { rejectNextGroup = true }
    func waitFor(_ operation: String) async {
        if groupWaiters[operation] != nil || refreshWaiters[operation] != nil { return }
        await withCheckedContinuation { arrivals[operation, default: []].append($0) }
    }
    private func arrived(_ operation: String) {
        for waiter in arrivals.removeValue(forKey: operation) ?? [] { waiter.resume() }
    }
    func finishGroup(_ operation: String, error: Error? = nil) {
        guard let waiter = groupWaiters.removeValue(forKey: operation) else { preconditionFailure("Missing group waiter") }
        held.remove(operation)
        if let error { waiter.resume(throwing: error) }
        else { waiter.resume(returning: Self.group(operation.contains("bob") ? "Bob" : "Alice")) }
    }
    func finishRefresh(_ operation: String, error: Error? = nil) {
        guard let waiter = refreshWaiters.removeValue(forKey: operation) else { preconditionFailure("Missing refresh waiter") }
        held.remove(operation)
        if let error { waiter.resume(throwing: error) }
        else { waiter.resume(returning: Self.session("alice")) }
    }
    func signIn(email: String, password: String) async throws -> AuthSession { Self.session(email) }
    func refresh(_ session: AuthSession) async throws -> AuthSession {
        let operation = "refresh:" + session.accessToken
        if held.contains(operation) {
            return try await withCheckedThrowingContinuation { continuation in
                refreshWaiters[operation] = continuation
                arrived(operation)
            }
        }
        return Self.session(session.accessToken)
    }
    func signOut(_ session: AuthSession) async throws {}
    func groupSnapshot(_ session: AuthSession) async throws -> GroupSnapshot {
        if rejectNextGroup { rejectNextGroup = false; throw BackendError.unauthorized }
        let operation = "group:" + session.accessToken
        if held.contains(operation) {
            return try await withCheckedThrowingContinuation { continuation in
                groupWaiters[operation] = continuation
                arrived(operation)
            }
        }
        return Self.group(session.accessToken.contains("bob") ? "Bob" : "Alice")
    }
    func extensionQuote(_ session: AuthSession, minutes: Int) async throws -> ExtensionQuote {
        ExtensionQuote(minutes: minutes, cost: minutes, balance: 40)
    }
    func confirmExtension(_ session: AuthSession, minutes: Int) async throws -> GroupSnapshot {
        Self.group(session.accessToken.contains("bob") ? "Bob" : "Alice")
    }
    func releaseReservation(_ session: AuthSession, extensionID: UUID) async throws -> GroupSnapshot {
        Self.group(session.accessToken.contains("bob") ? "Bob" : "Alice")
    }
    #if DEBUG
    func resetNormal(_ session: AuthSession) async throws -> GroupSnapshot { try await groupSnapshot(session) }
    func seedLowBalance(_ session: AuthSession) async throws -> GroupSnapshot { try await groupSnapshot(session) }
    #endif
    static func session(_ name: String, expired: Bool = false) -> AuthSession {
        AuthSession(accessToken: name, refreshToken: name + "-refresh", expiresAt: expired ? 0 : Date().timeIntervalSince1970 + 3600, expiresIn: 3600)
    }
    static func group(_ name: String) -> GroupSnapshot {
        GroupSnapshot(userName: name, groupId: UUID(), groupName: "Study", balance: 40, members: [])
    }
}

private struct CheckFailed: Error { let message: String }

@MainActor
@main
private struct SessionRaceChecks {
    static func check(_ condition: @autoclosure () -> Bool, _ message: String) throws {
        guard condition() else { throw CheckFailed(message: message) }
    }

    static func main() async throws {
        let watchdog = Task {
            do { try await Task.sleep(nanoseconds: 10_000_000_000) } catch { return }
            FileHandle.standardError.write(Data("FAIL: session race checks timed out.\n".utf8))
            exit(1)
        }
        defer { watchdog.cancel() }
        // A completed Alice request must not resurrect her after Reset.
        do {
            let backend = ControlledBackend()
            let memory = MemorySessions()
            let store = AppStore(backend: backend, sessionStorage: memory)
            await store.signIn(email: "alice", password: "fixture")
            await backend.hold("group:alice")
            let old = Task { await store.loadGroup() }
            await backend.waitFor("group:alice")
            store.debugReset()
            await backend.finishGroup("group:alice")
            await old.value
            try check(store.session == nil && store.group == nil && memory.value == nil, "Reset allowed stale Alice data to return")
        }

        // A stale unauthorized result cannot sign Bob out or clear Bob's loading indicator.
        do {
            let backend = ControlledBackend()
            let memory = MemorySessions()
            let store = AppStore(backend: backend, sessionStorage: memory)
            await store.signIn(email: "alice", password: "fixture")
            await backend.hold("group:alice")
            let old = Task { await store.loadGroup() }
            await backend.waitFor("group:alice")
            store.debugReset()
            await backend.hold("group:bob")
            let bob = Task { await store.signIn(email: "bob", password: "fixture") }
            await backend.waitFor("group:bob")
            await backend.finishGroup("group:alice", error: BackendError.unauthorized)
            await old.value
            try check(store.session?.accessToken == "bob" && memory.value?.accessToken == "bob", "Stale unauthorized response cleared Bob's session")
            try check(store.isGroupLoading && store.groupError == nil && store.authError == nil, "Stale request changed Bob's loading or errors")
            await backend.finishGroup("group:bob")
            await bob.value
            try check(store.group?.userName == "Bob" && !store.isGroupLoading && !store.isBusy, "Bob did not finish independently of Alice's old request")
        }

        // Both success and failure from a delayed restore must respect a local Reset.
        for shouldFail in [false, true] {
            let backend = ControlledBackend()
            let memory = MemorySessions(ControlledBackend.session("alice", expired: true))
            let store = AppStore(backend: backend, sessionStorage: memory)
            await backend.hold("refresh:alice")
            let restore = Task { await store.restoreSession() }
            await backend.waitFor("refresh:alice")
            store.debugReset()
            await backend.finishRefresh("refresh:alice", error: shouldFail ? BackendError.unauthorized : nil)
            await restore.value
            try check(store.session == nil && store.group == nil && memory.value == nil && store.authError == nil && !store.isRestoring, "Delayed restore overrode Reset")
        }

        // Expiration during the sign-in's initial group fetch must leave Sign in usable.
        do {
            let backend = ControlledBackend()
            await backend.rejectGroup()
            let store = AppStore(backend: backend, sessionStorage: MemorySessions())
            await store.signIn(email: "alice", password: "fixture")
            try check(store.session == nil && !store.isBusy, "Unauthorized initial group fetch left Sign in disabled")
        }
        print("PASS: 5 deterministic session race checks (no network or Keychain access).")
    }
}
