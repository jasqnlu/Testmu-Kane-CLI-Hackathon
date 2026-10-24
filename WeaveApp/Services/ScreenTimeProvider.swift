import Foundation

@MainActor
protocol ScreenTimeProvider: AnyObject {
    var isAtLimit: Bool { get }
    var extensionExpiry: Date? { get }
    func activateExtension(minutes: Int) async throws
    func endExtension()
}

enum ScreenTimeError: LocalizedError {
    case activationFailed
    case deviceIntegrationUnavailable

    var errorDescription: String? {
        switch self {
        case .activationFailed: "Couldn't start extension"
        case .deviceIntegrationUnavailable: "Screen Time integration is not available in this build."
        }
    }
}

/// Device integration stub. Real Screen Time enforcement requires a physical device.
@MainActor
final class RealScreenTimeProvider: ScreenTimeProvider {
    let isAtLimit = false
    private(set) var extensionExpiry: Date?

    func activateExtension(minutes: Int) async throws {
        throw ScreenTimeError.deviceIntegrationUnavailable
    }

    func endExtension() { extensionExpiry = nil }
}

#if DEBUG
/// Deterministic simulator provider. Debug controls will drive this in later milestones.
@MainActor
final class MockScreenTimeProvider: ScreenTimeProvider {
    var isAtLimit = false
    var failNextActivation = false
    private(set) var extensionExpiry: Date?

    func activateExtension(minutes: Int) async throws {
        if failNextActivation {
            failNextActivation = false
            throw ScreenTimeError.activationFailed
        }
        extensionExpiry = Date().addingTimeInterval(TimeInterval(minutes * 60))
    }

    func endExtension() { extensionExpiry = nil }

    func reset() {
        isAtLimit = false
        failNextActivation = false
        extensionExpiry = nil
    }
}
#endif
