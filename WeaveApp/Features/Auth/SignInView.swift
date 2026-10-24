import SwiftUI

struct SignInView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject private var store: AppStore
    private let ink = Color(red: 0.14, green: 0.25, blue: 0.22)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                Image(systemName: "circle.hexagongrid.fill")
                    .font(.system(size: 42, weight: .regular))
                    .foregroundStyle(ink)
                    .accessibilityHidden(true)
                    .padding(.top, 44)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Weave")
                        .font(.system(size: 48, weight: .semibold, design: .rounded))
                        .accessibilityAddTraits(.isHeader)
                    Text("A little more time.\nA little more together.")
                        .font(.title2)
                    Text("Share a budget for extra screen time with the people who keep you grounded.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                VStack(alignment: .leading, spacing: 16) {
                    Text("Sign in")
                        .font(.title2.weight(.semibold))
                        .accessibilityAddTraits(.isHeader)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email").font(.subheadline.weight(.medium))
                        TextField("Email", text: $email)
                            .textContentType(.username)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .padding(14)
                            .background(.white, in: RoundedRectangle(cornerRadius: 12))
                            .accessibilityIdentifier("auth.email")
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password").font(.subheadline.weight(.medium))
                        SecureField("Password", text: $password)
                            .textContentType(.password)
                            .padding(14)
                            .background(.white, in: RoundedRectangle(cornerRadius: 12))
                            .accessibilityIdentifier("auth.password")
                    }
                    Button {
                        Task { await store.signIn(email: email, password: password) }
                    } label: {
                        HStack {
                            if store.isBusy { ProgressView().tint(.white) }
                            Text(store.isBusy ? "Signing in…" : "Sign in")
                        }
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .disabled(store.isBusy)
                    .buttonStyle(.plain)
                    .foregroundStyle(.white)
                    .background(ink, in: RoundedRectangle(cornerRadius: 14))
                    .accessibilityIdentifier("auth.signIn")
                    if let error = store.authError {
                        Text(error)
                            .font(.callout)
                            .foregroundStyle(.red)
                            .accessibilityIdentifier("auth.error")
                    }
                }
                Text("Your reasons are yours. Sharing is always your choice.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 32)
            .frame(maxWidth: 520)
            .frame(maxWidth: .infinity)
        }
        .background(Color(red: 0.95, green: 0.96, blue: 0.92))
        .foregroundStyle(ink)

    }
}
