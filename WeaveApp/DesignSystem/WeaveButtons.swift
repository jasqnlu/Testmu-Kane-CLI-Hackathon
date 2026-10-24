import SwiftUI

// MARK: - Button styles

/// Solid ink capsule: black in light mode, white in dark mode.
struct WeavePrimaryButtonStyle: ButtonStyle {
    /// Use a tight trailing inset when the label ends in a round accessory.
    var hasTrailingAccessory = false

    func makeBody(configuration: Configuration) -> some View {
        WeaveCapsuleLabel(
            configuration: configuration,
            fill: WeaveTheme.Colors.ink,
            foreground: WeaveTheme.Colors.inkInverse,
            trailingInset: hasTrailingAccessory ? 8 : 24
        )
    }
}

/// Quiet grey capsule for the alternative action.
struct WeaveSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        WeaveCapsuleLabel(
            configuration: configuration,
            fill: WeaveTheme.Colors.surfaceMuted,
            foreground: WeaveTheme.Colors.ink,
            trailingInset: 24
        )
    }
}

extension ButtonStyle where Self == WeavePrimaryButtonStyle {
    static var weavePrimary: WeavePrimaryButtonStyle { WeavePrimaryButtonStyle() }
}

extension ButtonStyle where Self == WeaveSecondaryButtonStyle {
    static var weaveSecondary: WeaveSecondaryButtonStyle { WeaveSecondaryButtonStyle() }
}

/// Shared capsule body. A separate view so it can read `isEnabled`.
private struct WeaveCapsuleLabel: View {
    let configuration: ButtonStyleConfiguration
    let fill: Color
    let foreground: Color
    let trailingInset: CGFloat

    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        configuration.label
            .weaveFont(.headline)
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity, minHeight: 58)
            .padding(.leading, 24)
            .padding(.trailing, trailingInset)
            .background(fill, in: Capsule())
            .contentShape(Capsule())
            .opacity(isEnabled ? 1 : 0.5)
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Components

/// The main action on a screen. While `isLoading` is true the button keeps its
/// size, shows a spinner, and ignores taps.
struct PrimaryButton: View {
    let title: String
    var isLoading = false
    var loadingTitle: String? = nil
    var showsArrow = false
    var identifier: String? = nil
    let action: () -> Void

    init(
        _ title: String,
        isLoading: Bool = false,
        loadingTitle: String? = nil,
        showsArrow: Bool = false,
        identifier: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isLoading = isLoading
        self.loadingTitle = loadingTitle
        self.showsArrow = showsArrow
        self.identifier = identifier
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: WeaveTheme.Spacing.xs) {
                if isLoading {
                    ProgressView()
                        .tint(WeaveTheme.Colors.inkInverse)
                }
                Text(isLoading ? (loadingTitle ?? title) : title)
                    .lineLimit(2)
                    .multilineTextAlignment(showsArrow ? .leading : .center)
                if showsArrow {
                    Spacer(minLength: WeaveTheme.Spacing.xs)
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(WeaveTheme.Colors.ink)
                        .frame(width: 42, height: 42)
                        .background(WeaveTheme.Colors.inkInverse, in: Circle())
                        .accessibilityHidden(true)
                }
            }
        }
        .buttonStyle(WeavePrimaryButtonStyle(hasTrailingAccessory: showsArrow))
        .disabled(isLoading)
        .weaveIdentifier(identifier)
    }
}

/// The alternative action, such as Cancel or Not now.
struct SecondaryButton: View {
    let title: String
    var identifier: String? = nil
    let action: () -> Void

    init(_ title: String, identifier: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.identifier = identifier
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .buttonStyle(.weaveSecondary)
        .weaveIdentifier(identifier)
    }
}

// MARK: - Previews

#if DEBUG
private struct ButtonsSample: View {
    var body: some View {
        WeavePreviewSurface {
            PrimaryButton("Request 10 minutes", showsArrow: true) {}
            HStack(spacing: WeaveTheme.Spacing.tileGap) {
                SecondaryButton("Not now") {}
                PrimaryButton("Confirm", isLoading: true, loadingTitle: "Confirming…") {}
            }
            PrimaryButton("Post") {}
            Button("Retry") {}.buttonStyle(.weavePrimary)
            Button("Sign out") {}.buttonStyle(.weaveSecondary).disabled(true)
        }
    }
}

#Preview("Buttons · Light") {
    ButtonsSample()
}

#Preview("Buttons · Dark") {
    ButtonsSample().preferredColorScheme(.dark)
}
#endif
