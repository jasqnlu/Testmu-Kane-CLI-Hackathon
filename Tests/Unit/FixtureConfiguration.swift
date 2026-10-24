enum LocalConfiguration {
    static let url = "https://unit-test.invalid"
    static let anonKey = "fixture"
    struct TestAccount { let email: String; let password: String }
    static let testAccounts: [String: TestAccount] = [:]
}
