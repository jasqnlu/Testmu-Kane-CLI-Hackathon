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
                            VStack(alignment: .leading, spacing: 12) {
                                Label("Extension active, ends at \(expiryTime(active.expiryDate))",
                                      systemImage: "hourglass")
                                    .font(.callout.weight(.semibold))
                                    .accessibilityIdentifier("extension.active")
                                Button("Choose how to share") { store.beginSharingChoice() }
                                    .accessibilityIdentifier("privacy.chooseSharing")
                            }
                        }
                        if let completed = group.completedExtension {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Your completed extension").font(.headline)
                                Text("10 minutes").accessibilityIdentifier("extension.completed")
                                Text("Private reason saved").font(.subheadline).foregroundStyle(.secondary)
                            }
                            .padding(18)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.white, in: RoundedRectangle(cornerRadius: 20))
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
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Group activity").font(.title2.weight(.semibold))
                                .accessibilityIdentifier("feed.heading")
                            if store.feed.isEmpty {
                                Text("No shared activity yet.")
                                    .foregroundStyle(.secondary)
                                    .accessibilityIdentifier("feed.empty")
                            } else {
                                ForEach(store.feed) { card in
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(card.userName).font(.headline)
                                        Text(card.body).accessibilityIdentifier("feed.card.body")
                                    }
                                    .accessibilityElement(children: .contain)
                                    .accessibilityIdentifier("feed.card")
                                    .padding(16)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(.white, in: RoundedRectangle(cornerRadius: 18))
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
            .sheet(isPresented: $store.isShowingSharingChoice) {
                VStack(spacing: 18) {
                    Text("Your reason stays private").font(.title2.weight(.semibold))
                    TextField("What brought you to your phone?", text: $store.privateReasonDraft, axis: .vertical)
                        .lineLimit(2...4)
                        .textFieldStyle(.roundedBorder)
                        .accessibilityIdentifier("privacy.reason")
                    Text("Choose whether your group sees an activity card.")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    if let error = store.shareError {
                        Text(error).foregroundStyle(.red).accessibilityIdentifier("privacy.error")
                    }
                    Button("Keep Private") { Task { await store.keepExtensionPrivate() } }
                        .buttonStyle(.bordered)
                        .accessibilityIdentifier("privacy.keepPrivate")
                    Button("Share with Group") { store.openShareEditor() }
                        .buttonStyle(.borderedProminent)
                        .accessibilityIdentifier("privacy.shareGroup")
                }
                .padding(28)
                .presentationDetents([.medium])
            }
            .sheet(isPresented: $store.isShowingShareEditor) {
                VStack(spacing: 16) {
                    Text("Review your group card").font(.title2.weight(.semibold))
                    TextEditor(text: $store.shareDraft)
                        .frame(minHeight: 120)
                        .accessibilityIdentifier("share.draft")
                    if let error = store.shareError {
                        Text(error).foregroundStyle(.red).accessibilityIdentifier("share.error")
                    }
                    Button("Post") { Task { await store.postSharedExtension() } }
                        .buttonStyle(.borderedProminent)
                        .accessibilityIdentifier("share.post")
                    Button("Cancel", role: .cancel) { store.cancelShareEditor() }
                        .accessibilityIdentifier("share.cancel")
                }
                .padding(24)
                .presentationDetents([.medium, .large])
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
