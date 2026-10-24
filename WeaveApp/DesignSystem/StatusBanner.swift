import SwiftUI

/// A short inline status line.
///
/// - `.active`: dark capsule with a mint dot, like a Live Activity.
///   For "Extension active, ends at HH:MM".
/// - `.info`, `.caution`, `.critical`: solid pastel blocks
///   (periwinkle, butter, coral), for messages such as
///   "Not enough group credits" or "Couldn't start extension".
struct StatusBanner: View {
    enum Kind {
        case active, info, caution, critical
    }

    let kind: Kind
    let title: String
    var detail: String? = nil
    /// A trailing chip, such as "10 min". Shown for `.active` only.
    var chip: String? = nil
    /// Set on the title text.
    var identifier: String? = nil
    var detailIdentifier: String? = nil

    var body: some View {
        Group {
            if kind == .active {
                activeBody
            } else {
                blockBody
            }
        }
        .accessibilityElement(children: .contain)
    }

    // MARK: Active

    private var activeBody: some View {
        HStack(spacing: WeaveTheme.Spacing.sm) {
            Circle()
                .fill(WeaveTheme.Pastel.mint.color)
                .frame(width: 10, height: 10)
                .background(
                    Circle()
                        .fill(WeaveTheme.Pastel.mint.color.opacity(0.22))
                        .frame(width: 20, height: 20)
                )
                .accessibilityHidden(true)
            texts(detailOpacity: 0.7)
            Spacer(minLength: 0)
            if let chip {
                WeaveChip(chip, style: .mint)
                    .frame(minHeight: 32)
            }
        }
        .foregroundStyle(.white)
        .padding(.leading, 18)
        .padding(.trailing, chip == nil ? 18 : 8)
        .padding(.vertical, 8)
        .frame(minHeight: 48)
        .background(
            WeaveTheme.Colors.liveCapsule,
            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
    }

    // MARK: Info, caution, critical

    private var blockBody: some View {
        HStack(spacing: WeaveTheme.Spacing.sm) {
            Image(systemName: glyph)
                .font(.system(size: 13, weight: .heavy))
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
                .background(Color(hex: 0x111111), in: Circle())
                .accessibilityHidden(true)
            texts(detailOpacity: 0.8)
            Spacer(minLength: 0)
        }
        .foregroundStyle(WeaveTheme.Colors.onPastel)
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(
            blockColor,
            in: RoundedRectangle(cornerRadius: WeaveTheme.Radius.banner, style: .continuous)
        )
    }

    // MARK: Shared

    private func texts(detailOpacity: Double) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .weaveFont(.headline)
                .fixedSize(horizontal: false, vertical: true)
                .weaveIdentifier(identifier)
            if let detail {
                Text(detail)
                    .weaveFont(.label)
                    .opacity(detailOpacity)
                    .fixedSize(horizontal: false, vertical: true)
                    .weaveIdentifier(detailIdentifier)
            }
        }
    }

    private var glyph: String {
        switch kind {
        case .active, .info: "info"
        case .caution: "exclamationmark"
        case .critical: "xmark"
        }
    }

    private var blockColor: Color {
        switch kind {
        case .active, .info: WeaveTheme.Pastel.periwinkle.color
        case .caution: WeaveTheme.Pastel.butter.color
        case .critical: WeaveTheme.Pastel.coral.color
        }
    }
}

// MARK: - Previews

#if DEBUG
private struct StatusBannerSample: View {
    var body: some View {
        WeavePreviewSurface {
            StatusBanner(kind: .active, title: "Extension active, ends at 14:30", chip: "10 min")
            StatusBanner(
                kind: .active,
                title: "Extension active, ends at 14:30",
                detail: "10 minutes from the group balance"
            )
            StatusBanner(kind: .info, title: "Your reason stays private.")
            StatusBanner(kind: .caution, title: "Not enough group credits")
            StatusBanner(kind: .critical, title: "Couldn't start extension", detail: "No credits were spent.")
        }
    }
}

#Preview("StatusBanner · Light") {
    StatusBannerSample()
}

#Preview("StatusBanner · Dark") {
    StatusBannerSample().preferredColorScheme(.dark)
}
#endif
