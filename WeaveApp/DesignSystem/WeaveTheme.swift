import SwiftUI
import UIKit

/// Design tokens for Weave: colors, type, spacing, and corner radius.
///
/// Components in this folder never contain user-visible text. Feature screens
/// pass every string in, so Kane tests keep matching the exact copy.
enum WeaveTheme {

    // MARK: - Colors

    enum Colors {
        /// Screen background. Warm off-white / near-black.
        static let background = Color(light: 0xF1F0EC, dark: 0x0B0B0C)
        /// Tiles and sheets.
        static let surface = Color(light: 0xFFFFFF, dark: 0x1C1C1E)
        /// Quiet fills: secondary buttons, empty meter segments.
        static let surfaceMuted = Color(light: 0xE6E5E0, dark: 0x2A2A2D)
        /// Primary text and the primary button fill.
        static let ink = Color(light: 0x111111, dark: 0xF5F5F5)
        static let inkSecondary = Color(light: 0x6B6B6B, dark: 0x9A9A9F)
        /// Text drawn on top of `ink`.
        static let inkInverse = Color(light: 0xFFFFFF, dark: 0x111111)
        static let separator = Color(light: 0xE2E1DC, dark: 0x2E2E31)
        /// Weave deep green.
        static let brand = Color(light: 0x2D6A4F, dark: 0x2F7354)
        static let onBrand = Color.white
        /// The live-activity style capsule for an active extension.
        static let liveCapsule = Color(light: 0x111111, dark: 0x1C1C1E)
        /// Text on any pastel. Pastels stay light in both modes.
        static let onPastel = Color(hex: 0x111111)
    }

    /// Solid tile colors. Identical in light and dark mode, always with
    /// `Colors.onPastel` text. Each one has a single job.
    enum Pastel: CaseIterable {
        case mint        // private, active
        case periwinkle  // share, confirm
        case peach       // feed
        case pink        // feed
        case lime        // feed
        case butter      // caution
        case coral       // critical

        var color: Color {
            switch self {
            case .mint: Color(hex: 0x8EDCBC)
            case .periwinkle: Color(hex: 0xA3ADFF)
            case .peach: Color(hex: 0xFFC98F)
            case .pink: Color(hex: 0xF7A1CB)
            case .lime: Color(hex: 0xDDF59A)
            case .butter: Color(hex: 0xF5D565)
            case .coral: Color(hex: 0xF26B4F)
            }
        }

        /// Feed colors, picked per member.
        static let feed: [Pastel] = [.lime, .peach, .pink]

        /// A stable color for a member name. Uses a plain sum of Unicode
        /// scalars because Swift's `hashValue` changes on every launch.
        static func forMember(_ name: String) -> Pastel {
            let sum = name.unicodeScalars.reduce(0) { $0 &+ Int($1.value) }
            return feed[sum % feed.count]
        }
    }

    // MARK: - Spacing and radius

    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let tileGap: CGFloat = 10
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 28
        static let xxl: CGFloat = 44
    }

    enum Radius {
        static let field: CGFloat = 16
        static let banner: CGFloat = 22
        static let tile: CGFloat = 28
        static let sheet: CGFloat = 36
    }

    // MARK: - Typography

    /// Heavy SF Pro with tight tracking. Each style scales with Dynamic Type
    /// relative to a system text style.
    enum TextStyle {
        case hero, display, title, headline, body, label, chip

        var size: CGFloat {
            switch self {
            case .hero: 64
            case .display: 34
            case .title: 24
            case .headline: 17
            case .body: 16
            case .label: 13
            case .chip: 12
            }
        }

        var weight: UIFont.Weight {
            switch self {
            case .hero, .display, .title: .heavy
            case .headline, .label, .chip: .semibold
            case .body: .medium
            }
        }

        /// Letter spacing in points.
        var tracking: CGFloat {
            switch self {
            case .hero: -1.6
            case .display: -1.0
            case .title: -0.7
            case .headline: -0.2
            case .body, .label, .chip: 0
            }
        }

        var relativeTo: UIFont.TextStyle {
            switch self {
            case .hero, .display: .largeTitle
            case .title: .title2
            case .headline: .headline
            case .body: .callout
            case .label: .footnote
            case .chip: .caption1
            }
        }

        /// The scaled font for a given Dynamic Type size. Tabular figures keep
        /// numbers like "40" and "30" the same width.
        func font(for dynamicTypeSize: DynamicTypeSize) -> Font {
            let base = UIFont.systemFont(ofSize: size, weight: weight)
            let tabular = base.fontDescriptor.addingAttributes([
                .featureSettings: [[
                    UIFontDescriptor.FeatureKey.type: kNumberSpacingType,
                    UIFontDescriptor.FeatureKey.selector: kMonospacedNumbersSelector,
                ]],
            ])
            let traits = UITraitCollection(preferredContentSizeCategory: UIContentSizeCategory(dynamicTypeSize))
            let scaled = UIFontMetrics(forTextStyle: relativeTo)
                .scaledFont(for: UIFont(descriptor: tabular, size: size), compatibleWith: traits)
            return Font(scaled)
        }
    }
}

// MARK: - Text style modifier

private struct WeaveFontModifier: ViewModifier {
    let style: WeaveTheme.TextStyle
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    func body(content: Content) -> some View {
        content
            .font(style.font(for: dynamicTypeSize))
            .tracking(style.tracking)
    }
}

extension View {
    /// Applies a Weave text style that follows Dynamic Type.
    func weaveFont(_ style: WeaveTheme.TextStyle) -> some View {
        modifier(WeaveFontModifier(style: style))
    }

    /// Sets an accessibility identifier only when one is given.
    @ViewBuilder
    func weaveIdentifier(_ identifier: String?) -> some View {
        if let identifier {
            accessibilityIdentifier(identifier)
        } else {
            self
        }
    }

    /// A rounded tile with the standard padding and continuous corners.
    func weaveTile(_ fill: Color = WeaveTheme.Colors.surface, padding: CGFloat = WeaveTheme.Spacing.lg) -> some View {
        self
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(fill, in: RoundedRectangle(cornerRadius: WeaveTheme.Radius.tile, style: .continuous))
    }
}

// MARK: - Chip

/// A small capsule tag, such as "10 min" or "Default".
struct WeaveChip: View {
    enum Style {
        /// Black capsule, white text. Same in both modes.
        case dark
        /// Translucent white capsule for use on pastels.
        case light
        /// Muted surface capsule that follows the color scheme.
        case muted
        /// Mint capsule with dark text.
        case mint
    }

    let text: String
    var systemImage: String? = nil
    var style: Style = .dark
    var identifier: String? = nil

    init(_ text: String, systemImage: String? = nil, style: Style = .dark, identifier: String? = nil) {
        self.text = text
        self.systemImage = systemImage
        self.style = style
        self.identifier = identifier
    }

    var body: some View {
        HStack(spacing: 5) {
            if let systemImage {
                Image(systemName: systemImage)
                    .imageScale(.small)
                    .accessibilityHidden(true)
            }
            Text(text)
                .weaveIdentifier(identifier)
        }
        .weaveFont(.chip)
        .lineLimit(1)
        .padding(.horizontal, 11)
        .frame(minHeight: 26)
        .foregroundStyle(foreground)
        .background(background, in: Capsule())
    }

    private var foreground: Color {
        switch style {
        case .dark: .white
        case .light, .mint: WeaveTheme.Colors.onPastel
        case .muted: WeaveTheme.Colors.ink
        }
    }

    private var background: Color {
        switch style {
        case .dark: Color(hex: 0x111111)
        case .light: .white.opacity(0.7)
        case .muted: WeaveTheme.Colors.surfaceMuted
        case .mint: WeaveTheme.Pastel.mint.color
        }
    }
}

// MARK: - Color helpers

extension Color {
    /// A color from a 0xRRGGBB value.
    init(hex: UInt32) {
        self.init(uiColor: UIColor(hex: hex))
    }

    /// A color that switches with the system appearance.
    init(light: UInt32, dark: UInt32) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(hex: dark) : UIColor(hex: light)
        })
    }
}

private extension UIColor {
    convenience init(hex: UInt32) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}

// MARK: - Member initials

enum WeaveInitials {
    /// Up to two initials from a name: "Alice" → "A", "Mary Clark" → "MC".
    static func from(_ name: String) -> String {
        let letters = name.split(separator: " ").prefix(2).compactMap(\.first)
        return String(letters).uppercased()
    }
}

// MARK: - Previews

#if DEBUG
/// A padded background for component previews.
struct WeavePreviewSurface<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: WeaveTheme.Spacing.tileGap) {
                content
            }
            .padding(WeaveTheme.Spacing.md)
        }
        .background(WeaveTheme.Colors.background)
    }
}

private struct ThemeSampler: View {
    var body: some View {
        WeavePreviewSurface {
            Text("Study Group").weaveFont(.display)
            Text("Keep Private").weaveFont(.title)
            Text("Request 10 minutes").weaveFont(.headline)
            Text("Took 10 extra minutes to wrap up flashcards.").weaveFont(.body)
            Text("Group balance").weaveFont(.label).foregroundStyle(WeaveTheme.Colors.inkSecondary)
            HStack {
                WeaveChip("10 min")
                WeaveChip("Evening", style: .muted)
                WeaveChip("Default", systemImage: "lock.fill", style: .mint)
            }
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: 8)], spacing: 8) {
                ForEach(WeaveTheme.Pastel.allCases, id: \.self) { pastel in
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(pastel.color)
                        .frame(height: 60)
                        .overlay(alignment: .bottomLeading) {
                            Text(String(describing: pastel))
                                .weaveFont(.label)
                                .foregroundStyle(WeaveTheme.Colors.onPastel)
                                .padding(10)
                        }
                }
            }
            Text("Shared by Study Group")
                .weaveFont(.body)
                .foregroundStyle(WeaveTheme.Colors.onBrand)
                .weaveTile(WeaveTheme.Colors.brand)
        }
        .foregroundStyle(WeaveTheme.Colors.ink)
    }
}

#Preview("Theme · Light") {
    ThemeSampler()
}

#Preview("Theme · Dark") {
    ThemeSampler().preferredColorScheme(.dark)
}
#endif
