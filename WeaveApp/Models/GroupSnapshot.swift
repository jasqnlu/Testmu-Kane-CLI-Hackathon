import Foundation

struct GroupSnapshot: Decodable {
    let userName: String
    let groupId: UUID
    let groupName: String
    let balance: Int
    let members: [GroupMember]
    var activeExtension: ActiveExtension? = nil
}

struct ExtensionQuote: Decodable, Identifiable {
    let minutes: Int
    let cost: Int
    let balance: Int
    var id: Int { minutes }
}

struct ActiveExtension: Decodable {
    let id: UUID
    let minutes: Int
    let expiresAt: TimeInterval

    var expiryDate: Date { Date(timeIntervalSince1970: expiresAt) }
}

struct GroupMember: Decodable, Identifiable {
    let id: UUID
    let name: String
}

struct AuthSession: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: TimeInterval?
    let expiresIn: TimeInterval?

    var needsRefresh: Bool {
        guard let expiresAt else { return true }
        return expiresAt <= Date().timeIntervalSince1970 + 60
    }
}
