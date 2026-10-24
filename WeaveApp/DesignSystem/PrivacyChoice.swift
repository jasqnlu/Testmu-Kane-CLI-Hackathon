import SwiftUI

/// Keep Private vs Share with Group, drawn as two overlapping cards.
///
/// Keep Private is the mint card. It carries the default badge and should be
/// the initial selection. The selected card moves to the front.
struct PrivacyChoice: View {
    enum Option: Hashable {
        case keepPrivate
        case shareWithGroup
    }

    @Binding var selection: Option
    let privateTitle: String
    let privateDetail: String
    let shareTitle: String
    let shareDetail: String
    var defaultBadge: String? = nil
    var privateIdentifier: String? = nil
    var shareIdentifier: String? = nil

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// How far the lower card tucks under the upper one.
    private let overlap: CGFloat = 18

    var body: some View {
        VStack(spacing: -overlap) {
            card(
                option: .keepPrivate,
                title: privateTitle,
                detail: privateDetail,
                badge: defaultBadge,
                pastel: .mint,
                identifier: privateIdentifier
            )
            card(
                option: .shareWithGroup,
                title: shareTitle,
                detail: shareDetail,
                badge: nil,
                pastel: .periwinkle,
                identifier: shareIdentifier
            )
        }
    }

    private func card(
        option: Option,
        title: String,
        detail: String,
        badge: String?,
        pastel: WeaveTheme.Pastel,
        identifier: String?
    ) -> some View {
        let isSelected = selection == option
        // The card behind needs extra padding on the edge that is covered.
        let isTop = option == .keepPrivate
        let coveredTop = !isTop && !isSelected
        let coveredBottom = isTop && !isSelected

        return Button {
            withAnimation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.85)) {
                selection = option
            }
        } label: {
            HStack(alignment: .center, spacing: WeaveTheme.Spacing.sm) {
                VStack(alignment: .leading, spacing: WeaveTheme.Spacing.xs) {
                    HStack(spacing: WeaveTheme.Spacing.xs) {
                        Text(title)
                            .weaveFont(.title)
                            .multilineTextAlignment(.leading)
                        if let badge {
                            WeaveChip(badge, systemImage: "lock.fill", style: .dark)
                        }
                    }
                    Text(detail)
                        .weaveFont(.body)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
                knob(isSelected: isSelected)
            }
            .foregroundStyle(WeaveTheme.Colors.onPastel)
            .padding(.horizontal, WeaveTheme.Spacing.lg)
            .padding(.top, WeaveTheme.Spacing.lg + (coveredTop ? overlap : 0))
            .padding(.bottom, WeaveTheme.Spacing.lg + (coveredBottom ? overlap : 0))
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(pastel.color, in: RoundedRectangle(cornerRadius: WeaveTheme.Radius.tile, style: .continuous))
            .saturation(isSelected ? 1 : 0.6)
            .shadow(color: .black.opacity(isSelected ? 0.18 : 0), radius: 12, y: 8)
            .contentShape(RoundedRectangle(cornerRadius: WeaveTheme.Radius.tile, style: .continuous))
        }
        .buttonStyle(.plain)
        .zIndex(isSelected ? 1 : 0)
        // Keep the label exactly the title so tests can find "Keep Private".
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(detail)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
        .weaveIdentifier(identifier)
    }

    private func knob(isSelected: Bool) -> some View {
        ZStack {
            Circle()
                .fill(isSelected ? Color.white : Color.white.opacity(0.55))
            if isSelected {
                Image(systemName: "checkmark")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(WeaveTheme.Colors.onPastel)
            } else {
                Circle()
                    .strokeBorder(WeaveTheme.Colors.onPastel.opacity(0.4), lineWidth: 2)
                    .frame(width: 18, height: 18)
            }
        }
        .frame(width: 40, height: 40)
        .accessibilityHidden(true)
    }
}

// MARK: - Previews

#if DEBUG
private struct PrivacyChoiceSample: View {
    @State var selection: PrivacyChoice.Option = .keepPrivate

    var body: some View {
        WeavePreviewSurface {
            PrivacyChoice(
                selection: $selection,
                privateTitle: "Keep Private",
                privateDetail: "Your reason stays with you. Nothing is posted.",
                shareTitle: "Share with Group",
                shareDetail: "Review a short card before anything is posted.",
                defaultBadge: "Default"
            )
        }
    }
}

#Preview("PrivacyChoice · Light") {
    PrivacyChoiceSample()
}

#Preview("PrivacyChoice · Dark") {
    PrivacyChoiceSample().preferredColorScheme(.dark)
}

#Preview("PrivacyChoice · Share selected") {
    PrivacyChoiceSample(selection: .shareWithGroup).preferredColorScheme(.dark)
}
#endif
