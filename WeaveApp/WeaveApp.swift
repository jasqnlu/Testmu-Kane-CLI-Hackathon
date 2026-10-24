import SwiftUI

@main
struct WeaveApp: App {
    @StateObject private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .task { await store.restoreSession() }
                .tint(WeaveStyle.ink)
        }
    }
}

struct RootView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        #if DEBUG
        TabView(selection: $store.selectedTab) {
            mainContent
                .tabItem { Label(store.session == nil ? "Sign in" : "Group", systemImage: "person.2") }
                .tag(0)
            DebugView()
                .tabItem { Label("Debug", systemImage: "wrench.and.screwdriver") }
                .tag(1)
        }
        #else
        mainContent
        #endif
    }

    @ViewBuilder private var mainContent: some View {
        if store.isRestoring {
            ProgressView("Restoring sign-in…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(WeaveStyle.cream)
        } else if store.session != nil {
            GroupView()
        } else {
            SignInView()
        }
    }
}

enum WeaveStyle {
    static let ink = Color(red: 0.14, green: 0.25, blue: 0.22)
    static let cream = Color(red: 0.95, green: 0.96, blue: 0.92)
}
