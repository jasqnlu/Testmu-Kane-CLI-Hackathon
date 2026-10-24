import SwiftUI

/// One posted activity card in the group feed.
///
/// The tile color and avatar initials are derived from `memberName`, so the
/// same member always gets the same color. No likes or reaction counts.
struct FeedCard: View {
    let memberName: String
    let text: String
    var timestamp: String? = nil
    var tags: [String] = []
    /// Set on the card container.
    var identifier: String? = nil
    /// Set on the body text, for checking the posted text exactly.
    var textIdentifier: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: WeaveTheme.Spacing.sm) {
            HStack(spacing: WeaveTheme.Spacing.sm) {
                Text(WeaveInitials.from(memberName))
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundStyle(.white)
                    .frame(width: 38, height: 38)
                    .background(Color(hex: 0x111111), in: Circle())
                    .accessibilityHidden(true)
                Text(memberName)
                    .weaveFont(.title)
                    .lineLimit(1)
                Spacer(minLength: WeaveTheme.Spacing.xs)
                if let timestamp {
                    Text(timestamp)
                        .weaveFont(.label)
                        .opacity(0.7)
                }
            }

            Text(text)
                .weaveFont(.body)
                .fixedSize(horizontal: false, vertical: true)
                .weaveIdentifier(textIdentifier)

            if !tags.isEmpty {
                HStack(spacing: 6) {
                    ForEach(Array(tags.enumerated()), id: \.offset) { index, tag in
                        WeaveChip(tag, style: index == 0 ? .dark : .light)
                    }
                }
            }
        }
        .foregroundStyle(WeaveTheme.Colors.onPastel)
        .weaveTile(WeaveTheme.Pastel.forMember(memberName).color, padding: 18)
        .accessibilityElement(children: .contain)
        .weaveIdentifier(identifier)
    }
}

// MARK: - Previews

#if DEBUG
private struct FeedCardSample: View {
    var body: some View {
        WeavePreviewSurface {
            FeedCard(
                memberName: "Alice",
                text: "Took 10 extra minutes to wrap up flashcards, then back to the problem set.",
                timestamp: "2:15 PM",
                tags: ["10 min", "Evening"]
            )
            FeedCard(
                memberName: "Bob",
                text: "Needed a short reset after a long reading block.",
                timestamp: "1:40 PM",
                tags: ["10 min"]
            )
            FeedCard(
                memberName: "Charlie",
                text: "Used a little extra time to finish a group call.",
                timestamp: "Yesterday"
            )
        }
    }
}

#Preview("FeedCard · Light") {
    FeedCardSample()
}

#Preview("FeedCard · Dark") {
    FeedCardSample().preferredColorScheme(.dark)
}
#endif
