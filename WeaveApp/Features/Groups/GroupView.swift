import SwiftUI

struct GroupView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    if let group = store.group {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Hi, \(group.userName)")
                                .font(.title2)
                                .accessibilityIdentifier("group.userName")
                            Text(group.groupName)
                                .font(.system(size: 40, weight: .semibold, design: .rounded))
                                .accessibilityAddTraits(.isHeader)
                                .accessibilityIdentifier("group.name")
                            Text("A shared budget. A little room to breathe.")
                                .foregroundStyle(.secondary)
                        }
                        VStack(alignment: .leading, spacing: 10) {
                            Text("GROUP BALANCE").font(.caption.weight(.semibold))
                            Text("\(group.balance) credits")
                                .font(.system(size: 40, weight: .semibold, design: .rounded))
                                .accessibilityIdentifier("group.balance")
                            Text("Extra time comes from the same shared pool.")
                                .font(.subheadline)
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.white, in: RoundedRectangle(cornerRadius: 24))
                        if let active = group.activeExtension {
                            Label("Extension active, ends at \(expiryTime(active.expiryDate))",
                                  systemImage: "hourglass")
                                .font(.callout.weight(.semibold))
                                .accessibilityIdentifier("extension.active")
                        }
                        if let error = store.extensionError {
                            Text(error)
                                .font(.callout)
                                .foregroundStyle(.red)
                                .accessibilityIdentifier("extension.error")
                        }
                        #if DEBUG
                        if store.screenTime.isAtLimit && group.activeExtension == nil {
                            VStack(alignment: .leading, spacing: 12) {
                                Label("Personal limit reached", systemImage: "hourglass")
                                    .font(.callout.weight(.semibold))
                                    .accessibilityIdentifier("usage.atLimit")
                                Button("Request 10 minutes") {
                                    Task {
                                        if await store.requestExtension() { store.isShowingExtensionQuote = true }
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                                .disabled(store.isExtensionBusy)
                                .accessibilityIdentifier("extension.request")
                            }
                            .padding(20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.white, in: RoundedRectangle(cornerRadius: 24))
                        }
                        #endif
                        VStack(alignment: .leading, spacing: 18) {
                            Text("Your people").font(.title2.weight(.semibold))
                            ForEach(group.members) { member in
                                HStack(spacing: 14) {
                                    Image(systemName: "person.crop.circle.fill")
                                        .font(.title)
                                        .accessibilityHidden(true)
                                    Text(member.name).font(.headline)
                                    Spacer()
                                    if member.name == group.userName {
                                        Text("You").font(.subheadline).foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    } else if let error = store.groupError {
                        ContentUnavailableView {
                            Label("Couldn't load your group", systemImage: "wifi.exclamationmark")
                        } description: {
                            Text(error).accessibilityIdentifier("group.error")
                        } actions: {
                            Button("Retry") { Task { await store.loadGroup() } }
                                .buttonStyle(.borderedProminent)
                                .disabled(store.isGroupLoading)
                                .accessibilityIdentifier("group.retry")
                        }
                    } else {
                        ProgressView("Loading your group…")
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(28)
            }
            .foregroundStyle(WeaveStyle.ink)
            .background(WeaveStyle.cream)
            .navigationTitle("Weave")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Sign out") { Task { await store.signOut() } }
                        .disabled(store.isBusy || store.isGroupLoading || store.isExtensionBusy)
                        .accessibilityIdentifier("auth.signOut")
                }
            }
            .sheet(isPresented: $store.isShowingExtensionQuote, onDismiss: store.dismissExtensionQuote) {
                if let quote = store.extensionQuote {
                    VStack(spacing: 22) {
                        Text("A little more time")
                            .font(.title2.weight(.semibold))
                        Text("\(quote.minutes) minutes · \(quote.cost) credits")
                            .font(.title3)
                            .accessibilityIdentifier("extension.quote")
                        Text("This comes from your group's shared time budget.")
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        if let error = store.extensionError {
                            Text(error)
                                .foregroundStyle(.red)
                                .accessibilityIdentifier("extension.error")
                        }
                        Button("Confirm") {
                            Task {
                                await store.confirmExtension()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(store.isExtensionBusy)
                        .accessibilityIdentifier("extension.confirm")
                        Button("Cancel", role: .cancel) { store.isShowingExtensionQuote = false }
                            .disabled(store.isExtensionBusy)
                            .accessibilityIdentifier("extension.cancel")
                    }
                    .padding(28)
                    .foregroundStyle(WeaveStyle.ink)
                    .presentationDetents([.medium])
                }
            }
            .refreshable { await store.loadGroup() }
            .onAppear {
                if store.group == nil && store.groupError == nil && !store.isBusy {
                    Task { await store.loadGroup() }
                }
            }
        }
    }

    private func expiryTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_GB")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
