import Combine
import Foundation

@MainActor
final class AppStore: ObservableObject {
    @Published private(set) var session: AuthSession?
    @Published private(set) var group: GroupSnapshot?
    @Published private(set) var isBusy = false
    @Published private(set) var isGroupLoading = false
    @Published private(set) var isRestoring = true
    @Published var authError: String?
    @Published var groupError: String?
    @Published private(set) var extensionQuote: ExtensionQuote?
    @Published var extensionError: String?
    @Published private(set) var isExtensionBusy = false
    @Published var isShowingExtensionQuote = false
    @Published var selectedTab = 0
    @Published private(set) var feed: [FeedCard] = []
    @Published var shareDraft = ""
    @Published var privateReasonDraft = ""
    @Published var shareError: String?
    @Published private(set) var isDraftLoading = false
    @Published private(set) var draftSource = ""
    @Published var isShowingSharingChoice = false
    @Published var isShowingShareEditor = false
    private var sharingExtensionID: UUID?
    private let backend: BackendServing
    private let sessionStorage: SessionStoring
    private var sessionGeneration = 0
    private var groupRequestID: UUID?
    private var didRestore = false
    let screenTime: ScreenTimeProvider

    #if DEBUG
    @Published var debugNotice: String?
    private var failNextSignIn = false
    private var failNextGroupFetch = false
    #endif

    init(backend: BackendServing = SupabaseService(), sessionStorage: SessionStoring? = nil) {
        self.backend = backend
        self.sessionStorage = sessionStorage ?? KeychainSessionStore()
        #if DEBUG
        screenTime = MockScreenTimeProvider()
        #else
        screenTime = RealScreenTimeProvider()
        #endif
    }

    /// Invalidates in-flight work when identity changes. Requests may finish, but cannot publish stale results.
    @discardableResult
    private func invalidateSessionWork() -> Int {
        sessionGeneration += 1
        groupRequestID = nil
        isBusy = false
        isGroupLoading = false
        isRestoring = false
        isExtensionBusy = false
        isDraftLoading = false
        draftSource = ""
        extensionQuote = nil
        isShowingExtensionQuote = false
        return sessionGeneration
    }

    func restoreSession() async {
        guard !didRestore else { return }
        didRestore = true
        let generation = sessionGeneration
        defer { if generation == sessionGeneration { isRestoring = false } }
        do {
            guard let saved = try sessionStorage.load() else { return }
            let current = saved.needsRefresh ? try await backend.refresh(saved) : saved
            guard generation == sessionGeneration else { return }
            try sessionStorage.save(current)
            session = current
            await loadGroup()
        } catch {
            guard generation == sessionGeneration else { return }
            try? sessionStorage.clear()
            session = nil
            group = nil
            feed = []
            authError = "Your saved sign-in couldn't be restored. Please sign in again."
        }
    }

    func signIn(email: String, password: String) async {
        guard !isBusy else { return }
        authError = nil
        groupError = nil
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, !password.isEmpty else {
            authError = "Enter your email and password."
            return
        }
        let generation = invalidateSessionWork()
        isBusy = true
        session = nil
        group = nil
        defer { if generation == sessionGeneration { isBusy = false } }
        do {
            try sessionStorage.clear()
            #if DEBUG
            if failNextSignIn {
                failNextSignIn = false
                throw URLError(.notConnectedToInternet)
            }
            #endif
            let result = try await backend.signIn(email: email.trimmingCharacters(in: .whitespacesAndNewlines), password: password)
            guard generation == sessionGeneration else { return }
            try sessionStorage.save(result)
            session = result
            selectedTab = 0
            await loadGroup()
        } catch {
            guard generation == sessionGeneration else { return }
            session = nil
            group = nil
            feed = []
            authError = userMessage(error, fallback: "Couldn't sign in. Check your connection and try again.")
        }
    }

    func loadGroup() async {
        guard let signedIn = session, !isGroupLoading else { return }
        let generation = sessionGeneration
        let requestID = UUID()
        groupRequestID = requestID
        isGroupLoading = true
        defer {
            // An old request must not clear the newer identity's loading indicator.
            if groupRequestID == requestID {
                groupRequestID = nil
                isGroupLoading = false
            }
        }
        groupError = nil
        group = nil
        do {
            #if DEBUG
            if failNextGroupFetch {
                failNextGroupFetch = false
                throw URLError(.notConnectedToInternet)
            }
            #endif
            let current: AuthSession
            if signedIn.needsRefresh {
                current = try await backend.refresh(signedIn)
                guard generation == sessionGeneration, groupRequestID == requestID else { return }
                try sessionStorage.save(current)
                session = current
            } else { current = signedIn }
            let result = try await backend.groupSnapshot(current)
            guard generation == sessionGeneration, groupRequestID == requestID else { return }
            group = result
            await loadFeed(for: current, generation: generation)
        } catch BackendError.unauthorized {
            guard generation == sessionGeneration, groupRequestID == requestID else { return }
            invalidateSessionWork()
            try? sessionStorage.clear()
            session = nil
            authError = "Your sign-in expired. Please sign in again."
        } catch {
            guard generation == sessionGeneration, groupRequestID == requestID else { return }
            groupError = userMessage(error, fallback: "Couldn't load your group. Check your connection and try again.")
        }
    }

    func requestExtension(minutes: Int = 10) async -> Bool {
        guard let signedIn = session, group != nil, !isExtensionBusy else { return false }
        let generation = sessionGeneration
        isExtensionBusy = true
        extensionError = nil
        defer { if generation == sessionGeneration { isExtensionBusy = false } }
        do {
            let quote = try await backend.extensionQuote(signedIn, minutes: minutes)
            guard generation == sessionGeneration else { return false }
            extensionQuote = quote
            return true
        } catch {
            guard generation == sessionGeneration else { return false }
            extensionQuote = nil
            extensionError = userMessage(error, fallback: "Couldn't check your group balance. Please try again.")
            return false
        }
    }

    func confirmExtension() async {
        guard let signedIn = session, let quote = extensionQuote, !isExtensionBusy else { return }
        let generation = sessionGeneration
        isExtensionBusy = true
        extensionError = nil
        defer { if generation == sessionGeneration { isExtensionBusy = false } }
        do {
            let updated = try await backend.confirmExtension(signedIn, minutes: quote.minutes)
            guard generation == sessionGeneration else { return }
            group = updated
            extensionQuote = nil
            isShowingExtensionQuote = false
            do {
                try await screenTime.activateExtension(minutes: quote.minutes)
            } catch {
                guard generation == sessionGeneration else { return }
                if let extensionID = updated.activeExtension?.id {
                    do {
                        let reconciled = try await backend.releaseReservation(signedIn, extensionID: extensionID)
                        guard generation == sessionGeneration else { return }
                        group = reconciled
                    } catch {
                        guard generation == sessionGeneration else { return }
                        if let refreshed = try? await backend.groupSnapshot(signedIn) {
                            group = refreshed
                        }
                    }
                }
                extensionError = "Couldn't start extension"
            }
        } catch {
            guard generation == sessionGeneration else { return }
            extensionError = userMessage(error, fallback: "Couldn't start your extension. Please try again.")
        }
    }

    func dismissExtensionQuote() {
        extensionQuote = nil
        isShowingExtensionQuote = false
    }

    func loadFeed() async {
        guard let signedIn = session else { return }
        await loadFeed(for: signedIn, generation: sessionGeneration)
    }

    private func loadFeed(for signedIn: AuthSession, generation: Int) async {
        do {
            let value = try await backend.groupFeed(signedIn)
            guard generation == sessionGeneration else { return }
            feed = value
        } catch {
            guard generation == sessionGeneration else { return }
            feed = []
        }
    }

    func beginSharingChoice() {
        guard let group else { return }
        sharingExtensionID = group.completedExtension?.id ?? group.activeExtension?.id
        guard sharingExtensionID != nil else { return }
        privateReasonDraft = group.completedExtension?.reason ?? ""
        shareError = nil
        isDraftLoading = false
        isShowingSharingChoice = true
    }

    func keepExtensionPrivate() async {
        guard let signedIn = session, let extensionID = sharingExtensionID,
              !privateReasonDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        do {
            let updated = try await backend.chooseExtensionSharing(signedIn, extensionID: extensionID,
                                                                    reason: privateReasonDraft, share: false, body: nil)
            group = updated
            await loadFeed()
            isShowingSharingChoice = false
            sharingExtensionID = nil
            shareError = nil
        } catch {
            shareError = userMessage(error, fallback: "Couldn't keep this reason private. Try again.")
        }
    }

    func openShareEditor() async {
        guard let signedIn = session, let group, let extensionID = sharingExtensionID else { return }
        let generation = sessionGeneration
        shareDraft = ""
        shareError = nil
        draftSource = ""
        isDraftLoading = true
        defer { if generation == sessionGeneration { isDraftLoading = false } }
        let hour = Calendar.current.component(.hour, from: Date())
        let timeOfDay = hour < 12 ? "morning" : (hour < 17 ? "afternoon" : "evening")
        do {
            try await backend.storePrivateExtensionReason(signedIn, extensionID: extensionID, reason: privateReasonDraft)
            guard generation == sessionGeneration else { return }
            let result = try await backend.draftCard(signedIn, extensionID: extensionID,
                                                     minutes: 10, timeOfDay: timeOfDay,
                                                     achievement: "completed a group extension")
            guard generation == sessionGeneration else { return }
            shareDraft = result.draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? "\(group.userName) used 10 group minutes." : result.draft
            draftSource = result.source
        } catch {
            guard generation == sessionGeneration else { return }
            shareDraft = "\(group.userName) used 10 group minutes."
            draftSource = "fallback"
        }
        guard generation == sessionGeneration else { return }
        isShowingSharingChoice = false
        isShowingShareEditor = true
    }

    func cancelShareEditor() {
        isShowingShareEditor = false
        shareDraft = ""
    }

    func postSharedExtension() async {
        guard let signedIn = session, let extensionID = sharingExtensionID else { return }
        do {
            let updated = try await backend.chooseExtensionSharing(signedIn, extensionID: extensionID,
                                                                    reason: privateReasonDraft, share: true, body: shareDraft)
            group = updated
            await loadFeed()
            isShowingShareEditor = false
            sharingExtensionID = nil
            shareError = nil
        } catch {
            shareError = userMessage(error, fallback: "Couldn't post this card. Try again.")
        }
    }

    func signOut() async {
        guard !isBusy, !isExtensionBusy else { return }
        let saved = session
        let generation = invalidateSessionWork()
        isBusy = true
        defer { if generation == sessionGeneration { isBusy = false } }
        do {
            // Clear persisted credentials first, including when the network is unavailable.
            try sessionStorage.clear()
            session = nil
            group = nil
            feed = []
            groupError = nil
            extensionQuote = nil
            extensionError = nil
            authError = nil
            selectedTab = 0
            if let saved { try await backend.signOut(saved) }
        } catch {
            guard generation == sessionGeneration else { return }
            authError = userMessage(error, fallback: "Signed out on this device. Couldn't reach the server to end the session.")
        }
    }

    private func userMessage(_ error: Error, fallback: String) -> String {
        if error is BackendError || error is SessionStorageError { return error.localizedDescription }
        return fallback
    }

    #if DEBUG
    func debugReset() {
        guard !isBusy, !isExtensionBusy else { return }
        invalidateSessionWork()
        do {
            try sessionStorage.clear()
            session = nil
            group = nil
            authError = nil
            groupError = nil
            extensionQuote = nil
            extensionError = nil
            failNextSignIn = false
            failNextGroupFetch = false
            (screenTime as? MockScreenTimeProvider)?.reset()
            selectedTab = 0
            debugNotice = "Reset complete. Signed out; mock usage cleared. Server data unchanged."
        } catch { debugNotice = error.localizedDescription }
    }

    func debugSignIn(_ name: String) async {
        guard let account = LocalConfiguration.testAccounts[name] else {
            debugNotice = "Test account configuration is missing. Rebuild after seeding test accounts."
            return
        }
        await signIn(email: account.email, password: account.password)
        if let authError { debugNotice = authError }
    }

    func debugSeedNormal() async {
        guard !isBusy, !isExtensionBusy else { return }
        guard let saved = session else {
            debugNotice = "Sign in as a test user before seeding the group."
            return
        }
        let generation = sessionGeneration
        isBusy = true
        defer { if generation == sessionGeneration { isBusy = false } }
        do {
            let current = saved.needsRefresh ? try await backend.refresh(saved) : saved
            guard generation == sessionGeneration else { return }
            try sessionStorage.save(current)
            session = current
            let result = try await backend.resetNormal(current)
            guard generation == sessionGeneration else { return }
            group = result
            groupError = nil
            debugNotice = "Seed: normal complete. Group restored to 40 credits."
        } catch {
            guard generation == sessionGeneration else { return }
            debugNotice = userMessage(error, fallback: "Couldn't seed the group. Try again.")
        }
    }

    func debugSeedLowBalance() async {
        guard !isBusy, !isExtensionBusy else { return }
        guard let saved = session else {
            debugNotice = "Sign in as a test user before seeding the group."
            return
        }
        let generation = sessionGeneration
        isBusy = true
        defer { if generation == sessionGeneration { isBusy = false } }
        do {
            let current = saved.needsRefresh ? try await backend.refresh(saved) : saved
            guard generation == sessionGeneration else { return }
            try sessionStorage.save(current)
            session = current
            let result = try await backend.seedLowBalance(current)
            guard generation == sessionGeneration else { return }
            group = result
            groupError = nil
            extensionQuote = nil
            extensionError = nil
            debugNotice = "Seed: low-balance complete. Group set to 5 credits."
        } catch {
            guard generation == sessionGeneration else { return }
            debugNotice = userMessage(error, fallback: "Couldn't seed the group. Try again.")
        }
    }

    func debugSeedPrivateReason() async {
        guard !isBusy, !isExtensionBusy, let saved = session else {
            debugNotice = "Sign in as a test user before seeding a private reason."
            return
        }
        let generation = sessionGeneration
        isBusy = true
        defer { if generation == sessionGeneration { isBusy = false } }
        do {
            let result = try await backend.seedPrivateReason(saved)
            guard generation == sessionGeneration else { return }
            group = result
            sharingExtensionID = result.completedExtension?.id
            privateReasonDraft = result.completedExtension?.reason ?? ""
            await loadFeed(for: saved, generation: generation)
            debugNotice = "Private-reason fixture ready. The stored reason is chemistry test anxiety."
            isShowingSharingChoice = true
            selectedTab = 0
        } catch {
            guard generation == sessionGeneration else { return }
            debugNotice = userMessage(error, fallback: "Couldn't seed the private-reason fixture.")
        }
    }

    func debugSetAtLimit() {
        (screenTime as? MockScreenTimeProvider)?.isAtLimit = true
        debugNotice = "Mock usage is at the personal limit."
    }

    func debugFailActivation() {
        (screenTime as? MockScreenTimeProvider)?.failNextActivation = true
        debugNotice = "Next mock activation will fail."
    }

    func debugFailSignIn() {
        guard !isBusy else { return }
        debugReset()
        failNextSignIn = true
        selectedTab = 1
        debugNotice = "Next sign-in will simulate an unavailable network."
    }

    func debugFailGroupFetch() {
        guard !isBusy else { return }
        failNextGroupFetch = true
        group = nil
        groupError = nil
        debugNotice = "Next group fetch will simulate an unavailable network. Return to Group to retry."
    }
    #endif
}
