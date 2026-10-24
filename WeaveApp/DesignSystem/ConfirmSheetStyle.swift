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
        .foregroundStyle(WeaveTheme.Colors.ink)
        .padding(.horizontal, WeaveTheme.Spacing.lg)
        .padding(.top, WeaveTheme.Spacing.xl)
        .padding(.bottom, WeaveTheme.Spacing.md)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(WeaveTheme.Colors.surface)
    }
}

extension View {
    /// Medium sheet with 36pt corners, a grabber, and the surface background.
    func weaveSheetPresentation() -> some View {
        self
            .presentationDetents([.medium, .large])
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
#endif
