import SwiftUI

/// The content of a confirmation sheet, such as "10 minutes · 10 credits".
///
/// The cost is shown as a large periwinkle block so it is the first thing a
/// person reads. Nothing happens until they tap the confirm button.
/// Present it with `.weaveSheetPresentation()`.
struct ConfirmSheetStyle: View {
    let title: String
    var message: String? = nil
    let summary: String
    let confirmTitle: String
    let cancelTitle: String
    var isConfirming = false
    var confirmingTitle: String? = nil
    var titleIdentifier: String? = nil
    var summaryIdentifier: String? = nil
    var confirmIdentifier: String? = nil
    var cancelIdentifier: String? = nil
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        // The text scrolls and the buttons stay pinned to the bottom, so
        // Confirm is always on screen, even at the medium detent with large text.
        ScrollView {
            content
                .padding(.horizontal, WeaveTheme.Spacing.lg)
                .padding(.top, WeaveTheme.Spacing.xl)
                .padding(.bottom, WeaveTheme.Spacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollBounceBehavior(.basedOnSize)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            buttons
                .padding(.horizontal, WeaveTheme.Spacing.lg)
                .padding(.top, WeaveTheme.Spacing.sm)
                .padding(.bottom, WeaveTheme.Spacing.md)
                .background(WeaveTheme.Colors.surface)
        }
        .foregroundStyle(WeaveTheme.Colors.ink)
        .background(WeaveTheme.Colors.surface)
        // Cancel is disabled while confirming; block swipe-to-dismiss too.
        .interactiveDismissDisabled(isConfirming)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: WeaveTheme.Spacing.md) {
            VStack(alignment: .leading, spacing: WeaveTheme.Spacing.xs) {
                Text(title)
                    .weaveFont(.display)
                    .accessibilityAddTraits(.isHeader)
                    .fixedSize(horizontal: false, vertical: true)
                    .weaveIdentifier(titleIdentifier)
                if let message {
                    Text(message)
                        .weaveFont(.body)
                        .foregroundStyle(WeaveTheme.Colors.inkSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Text(summary)
                .weaveFont(.title)
                .foregroundStyle(WeaveTheme.Colors.onPastel)
                .fixedSize(horizontal: false, vertical: true)
                .weaveTile(WeaveTheme.Pastel.periwinkle.color, padding: WeaveTheme.Spacing.lg)
                .weaveIdentifier(summaryIdentifier)
        }
    }

    private var buttons: some View {
        VStack(spacing: WeaveTheme.Spacing.tileGap) {
            PrimaryButton(
                confirmTitle,
                isLoading: isConfirming,
                loadingTitle: confirmingTitle,
                identifier: confirmIdentifier,
                action: onConfirm
            )
            SecondaryButton(cancelTitle, identifier: cancelIdentifier, action: onCancel)
                .disabled(isConfirming)
        }
    }
}

extension View {
    /// Medium sheet with 36pt corners, a grabber, and the surface background.
    /// Opens at the large detent at accessibility text sizes.
    func weaveSheetPresentation() -> some View {
        modifier(WeaveSheetPresentation())
    }
}

private struct WeaveSheetPresentation: ViewModifier {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    func body(content: Content) -> some View {
        content
            .presentationDetents(dynamicTypeSize.isAccessibilitySize ? [.large] : [.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(WeaveTheme.Radius.sheet)
            .presentationBackground(WeaveTheme.Colors.surface)
    }
}

// MARK: - Previews

#if DEBUG
private struct ConfirmSheetSample: View {
    var isConfirming = false
    @State private var isPresented = true

    var body: some View {
        WeaveTheme.Colors.background
            .ignoresSafeArea()
            .sheet(isPresented: $isPresented) {
                ConfirmSheetStyle(
                    title: "Take a little more time?",
                    message: "It comes from the group's shared balance.",
                    summary: "10 minutes · 10 credits",
                    confirmTitle: "Confirm",
                    cancelTitle: "Cancel",
                    isConfirming: isConfirming,
                    confirmingTitle: "Confirming…",
                    onConfirm: {},
                    onCancel: {}
                )
                .weaveSheetPresentation()
            }
    }
}

#Preview("ConfirmSheet · Light") {
    ConfirmSheetSample()
}

#Preview("ConfirmSheet · Dark") {
    ConfirmSheetSample().preferredColorScheme(.dark)
}

#Preview("ConfirmSheet · Confirming") {
    ConfirmSheetSample(isConfirming: true).preferredColorScheme(.dark)
}

#Preview("ConfirmSheet · Accessibility text") {
    ConfirmSheetSample().dynamicTypeSize(.accessibility3)
}
#endif
