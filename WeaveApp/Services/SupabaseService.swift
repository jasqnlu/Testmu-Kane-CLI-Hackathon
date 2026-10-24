import Foundation

protocol BackendServing {
    func signIn(email: String, password: String) async throws -> AuthSession
    func refresh(_ session: AuthSession) async throws -> AuthSession
    func signOut(_ session: AuthSession) async throws
    func groupSnapshot(_ session: AuthSession) async throws -> GroupSnapshot
    #if DEBUG
    func resetNormal(_ session: AuthSession) async throws -> GroupSnapshot
    #endif
}

struct SupabaseService: BackendServing {
    private let decoder: JSONDecoder = {
        let value = JSONDecoder()
        value.keyDecodingStrategy = .convertFromSnakeCase
        return value
    }()

    func signIn(email: String, password: String) async throws -> AuthSession {
        let data = try await request("auth/v1/token", query: [URLQueryItem(name: "grant_type", value: "password")],
                                     body: ["email": email, "password": password])
        return try decoder.decode(AuthSession.self, from: data)
    }

    func refresh(_ session: AuthSession) async throws -> AuthSession {
        let data = try await request("auth/v1/token", query: [URLQueryItem(name: "grant_type", value: "refresh_token")],
                                     body: ["refresh_token": session.refreshToken])
        return try decoder.decode(AuthSession.self, from: data)
    }

    func signOut(_ session: AuthSession) async throws {
        _ = try await request("auth/v1/logout", query: [URLQueryItem(name: "scope", value: "local")],
                              token: session.accessToken)
    }

    func groupSnapshot(_ session: AuthSession) async throws -> GroupSnapshot {
        let data = try await request("rest/v1/rpc/group_snapshot", token: session.accessToken)
        return try decoder.decode(GroupSnapshot.self, from: data)
    }

    #if DEBUG
    func resetNormal(_ session: AuthSession) async throws -> GroupSnapshot {
        let data = try await request("rest/v1/rpc/debug_reset_normal", token: session.accessToken)
        return try decoder.decode(GroupSnapshot.self, from: data)
    }
    #endif

    private func request(_ path: String, query: [URLQueryItem] = [], token: String? = nil,
                         body: [String: String] = [:]) async throws -> Data {
        guard let base = URL(string: LocalConfiguration.url), base.scheme == "https",
              !LocalConfiguration.anonKey.isEmpty,
              var components = URLComponents(url: base.appendingPathComponent(path), resolvingAgainstBaseURL: false) else {
            throw BackendError.configuration
        }
        if !query.isEmpty { components.queryItems = query }
        guard let url = components.url else { throw BackendError.configuration }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 15
        request.setValue(LocalConfiguration.anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(token ?? LocalConfiguration.anonKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw BackendError.unavailable }
        guard (200..<300).contains(http.statusCode) else {
            if http.statusCode == 401 { throw BackendError.unauthorized }
            let message = (try? JSONDecoder().decode(ServiceMessage.self, from: data))?.message
            if path.contains("auth/v1/token"), http.statusCode == 400 {
                throw BackendError.signInRejected
            }
            throw BackendError.rejected(message ?? "The request could not be completed. Please try again.")
        }
        return data
    }
}

private struct ServiceMessage: Decodable { let message: String? }

enum BackendError: LocalizedError {
    case configuration, unavailable, unauthorized, signInRejected
    case rejected(String)

    var errorDescription: String? {
        switch self {
        case .configuration: "Weave isn't connected yet. Please finish setup before signing in."
        case .unavailable: "Couldn't connect. Please try again."
        case .unauthorized: "Your sign-in expired. Please sign in again."
        case .signInRejected: "Email or password wasn't accepted. Please try again."
        case .rejected: "Couldn't complete the request. Please try again."
        }
    }
}
