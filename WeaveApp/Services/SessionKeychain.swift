import Foundation
import Security

@MainActor
protocol SessionStoring {
    func load() throws -> AuthSession?
    func save(_ session: AuthSession) throws
    func clear() throws
}

struct KeychainSessionStore: SessionStoring {
    func load() throws -> AuthSession? { try SessionKeychain.load() }
    func save(_ session: AuthSession) throws { try SessionKeychain.save(session) }
    func clear() throws { try SessionKeychain.clear() }
}

enum SessionKeychain {
    // Kane's headless Debug simulator installs an ad hoc signed build without
    // a keychain access group. Keep its test session in the app sandbox so the
    // real sign-in flow remains verifiable there. All other builds use
    // Keychain below.
    #if DEBUG && targetEnvironment(simulator)
    private static let simulatorSessionKey = "com.jasonlu.weave.auth.session"

    static func load() throws -> AuthSession? {
        guard let data = UserDefaults.standard.data(forKey: simulatorSessionKey) else { return nil }
        return try JSONDecoder().decode(AuthSession.self, from: data)
    }

    static func save(_ session: AuthSession) throws {
        UserDefaults.standard.set(try JSONEncoder().encode(session), forKey: simulatorSessionKey)
    }

    static func clear() throws {
        UserDefaults.standard.removeObject(forKey: simulatorSessionKey)
    }
    #else
    private static let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrService as String: "com.jasonlu.weave.auth",
        kSecAttrAccount as String: "supabase-session"
    ]

    static func load() throws -> AuthSession? {
        var lookup = query
        lookup[kSecReturnData as String] = true
        lookup[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: CFTypeRef?
        let status = SecItemCopyMatching(lookup as CFDictionary, &result)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess, let data = result as? Data else {
            throw SessionStorageError.unavailable
        }
        return try JSONDecoder().decode(AuthSession.self, from: data)
    }

    static func save(_ session: AuthSession) throws {
        let data = try JSONEncoder().encode(session)
        let updates: [String: Any] = [kSecValueData as String: data]
        let status = SecItemUpdate(query as CFDictionary, updates as CFDictionary)
        if status == errSecItemNotFound {
            var item = query
            item[kSecValueData as String] = data
            item[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
            guard SecItemAdd(item as CFDictionary, nil) == errSecSuccess else {
                throw SessionStorageError.unavailable
            }
        } else if status != errSecSuccess {
            throw SessionStorageError.unavailable
        }
    }

    static func clear() throws {
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw SessionStorageError.unavailable
        }
    }
    #endif
}

enum SessionStorageError: LocalizedError {
    case unavailable
    var errorDescription: String? { "Couldn't access your saved sign-in. Please try again." }
}
