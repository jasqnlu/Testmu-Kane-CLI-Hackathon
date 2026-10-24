import SwiftUI

/// The group's shared credits, with the number as the main element.
///
/// `amount` is one string such as "40 credits". It is drawn as a large "40"
/// and a smaller " credits" joined into a single `Text`, so VoiceOver and Kane
/// still read exactly "40 credits".
struct BalanceCard: View {
    enum Style {
        /// White tile in light mode, charcoal in dark mode.
        case standard
        /// Weave deep green with white text.
        case brand
    }

    let label: String
    let amount: String
    var caption: String? = nil
    /// Share of the budget left, 0...1. Shown as five segments. Nil hides it.
    var fraction: Double? = nil
    var memberNames: [String] = []
    var style: Style = .standard
    var amountIdentifier: String? = nil
    /// Set on the card container.
    var identifier: String? = nil

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private static let segmentCount = 5

    var body: some View {
        VStack(alignment: .leading, spacing: WeaveTheme.Spacing.xxs) {
            Text(label)
                .weaveFont(.label)
                .foregroundStyle(secondaryColor)

            amountText
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .padding(.top, WeaveTheme.Spacing.xxs)
                .weaveIdentifier(amountIdentifier)

            if let caption {
                Text(caption)
                    .weaveFont(.body)
                    .foregroundStyle(secondaryColor)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let fraction {
                meter(fraction: fraction)
                    .padding(.top, WeaveTheme.Spacing.sm)
            }

            if !memberNames.isEmpty {
                faces
                    .padding(.top, WeaveTheme.Spacing.sm)
            }
        }
        .foregroundStyle(primaryColor)
        .weaveTile(fill)
        .accessibilityElement(children: .contain)
        .weaveIdentifier(identifier)
    }

    // MARK: Parts

    /// Splits at the first space, only for display.
    private var amountText: Text {
        let parts = amount.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: false)
        let number = Text(parts.first.map(String.init) ?? amount)
            .font(WeaveTheme.TextStyle.hero.font(for: dynamicTypeSize))
            .tracking(WeaveTheme.TextStyle.hero.tracking)
        guard parts.count == 2 else { return number }
        let unit = Text(" " + parts[1])
            .font(WeaveTheme.TextStyle.title.font(for: dynamicTypeSize))
            .tracking(-0.4)
        return number + unit
    }

    private func meter(fraction: Double) -> some View {
        let clamped = min(max(fraction, 0), 1)
        let filled = Int((clamped * Double(Self.segmentCount)).rounded())
        return HStack(spacing: WeaveTheme.Spacing.xxs) {
            ForEach(0..<Self.segmentCount, id: \.self) { index in
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(index < filled ? meterOn : meterOff)
                    .frame(height: 26)
            }
        }
        .accessibilityHidden(true)
    }

    private var faces: some View {
        HStack(spacing: -8) {
            ForEach(Array(memberNames.enumerated()), id: \.offset) { _, name in
                Text(WeaveInitials.from(name))
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(WeaveTheme.Colors.onPastel)
                    .frame(width: 30, height: 30)
                    .background(WeaveTheme.Pastel.forMember(name).color, in: Circle())
                    .overlay(Circle().strokeBorder(fill, lineWidth: 2))
            }
        }
        .accessibilityHidden(true)
    }

    // MARK: Colors

    private var fill: Color {
        style == .brand ? WeaveTheme.Colors.brand : WeaveTheme.Colors.surface
    }

    private var primaryColor: Color {
        style == .brand ? WeaveTheme.Colors.onBrand : WeaveTheme.Colors.ink
    }

    private var secondaryColor: Color {
        style == .brand ? WeaveTheme.Colors.onBrand.opacity(0.8) : WeaveTheme.Colors.inkSecondary
    }

    private var meterOn: Color {
        style == .brand ? WeaveTheme.Colors.onBrand : WeaveTheme.Colors.ink
    }

    private var meterOff: Color {
        style == .brand ? WeaveTheme.Colors.onBrand.opacity(0.25) : WeaveTheme.Colors.surfaceMuted
    }
}

// MARK: - Previews

#if DEBUG
private struct BalanceCardSample: View {
    var body: some View {
        WeavePreviewSurface {
            BalanceCard(
                label: "Group balance",
                amount: "40 credits",
                caption: "Shared by Study Group",
                fraction: 0.8,
                memberNames: ["Alice", "Bob", "Charlie"],
                amountIdentifier: "group.balance"
            )
            HStack(alignment: .top, spacing: WeaveTheme.Spacing.tileGap) {
                BalanceCard(label: "After this", amount: "30 credits", fraction: 0.6)
                BalanceCard(label: "Your extension", amount: "10 min", style: .brand)
            }
            BalanceCard(
                label: "Group balance",
                amount: "5 credits",
                caption: "Extra time comes from the same shared pool.",
                fraction: 0.1
            )
        }
    }
}

#Preview("BalanceCard · Light") {
    BalanceCardSample()
}

#Preview("BalanceCard · Dark") {
    BalanceCardSample().preferredColorScheme(.dark)
}
#endif
