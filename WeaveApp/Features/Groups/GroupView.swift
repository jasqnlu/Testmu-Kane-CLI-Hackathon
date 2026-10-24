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
                        #if DEBUG
                        if store.screenTime.isAtLimit {
                            Label("Personal limit reached", systemImage: "hourglass")
                                .font(.callout)
                                .accessibilityIdentifier("usage.atLimit")
                        }
                        #endif
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
                        .disabled(store.isBusy || store.isGroupLoading)
                        .accessibilityIdentifier("auth.signOut")
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
}
