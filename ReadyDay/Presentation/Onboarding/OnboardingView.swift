import SwiftUI

struct OnboardingView: View {
    let viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: RDSpacing.xl) {
            Spacer()

            Image(systemName: "sun.max.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.rdAccent)
                .symbolRenderingMode(.hierarchical)

            VStack(spacing: RDSpacing.xxs) {
                Text("ReadyDay")
                    .font(.rdDisplayLarge)
                    .foregroundStyle(Color.rdTextPrimary)

                Text("Optimiza tu dia segun tu cuerpo")
                    .font(.rdBodyLarge)
                    .foregroundStyle(Color.rdTextSecondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            Text("Cruza tus datos de Whoop con tu calendario para rendir al maximo.")
                .font(.rdBodyMedium)
                .foregroundStyle(Color.rdTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, RDSpacing.lg)

            Button("Continue with Apple") {
                Task { await viewModel.signInWithApple() }
            }
            .buttonStyle(.rdPrimary)
            .padding(.horizontal, RDSpacing.sm)

            Text("By continuing you agree to Terms & Privacy Policy")
                .font(.rdCaptionLarge)
                .foregroundStyle(Color.rdTextTertiary)

            Spacer()
        }
        .padding(RDSpacing.sm)
        .background(Color.rdBackground)
    }
}
