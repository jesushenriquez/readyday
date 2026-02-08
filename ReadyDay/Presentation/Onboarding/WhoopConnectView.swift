import SwiftUI

struct WhoopConnectView: View {
    let viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: RDSpacing.xl) {
            Spacer()

            Image(systemName: "link.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.rdPrimary)
                .symbolRenderingMode(.hierarchical)

            VStack(spacing: RDSpacing.xxs) {
                Text("Conecta tu Whoop")
                    .font(.rdDisplayMedium)
                    .foregroundStyle(Color.rdTextPrimary)

                Text("Necesitamos acceso a tu recovery, sueno y strain para generar tu briefing diario.")
                    .font(.rdBodyMedium)
                    .foregroundStyle(Color.rdTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, RDSpacing.lg)
            }

            Spacer()

            VStack(spacing: RDSpacing.sm) {
                Button("Conectar Whoop") {
                    Task { await viewModel.connectWhoop() }
                }
                .buttonStyle(.rdPrimary)

                Button("Omitir por ahora") {
                    viewModel.skipWhoop()
                }
                .buttonStyle(.rdTertiary)
            }
            .padding(.horizontal, RDSpacing.sm)

            Spacer()
        }
        .padding(RDSpacing.sm)
        .background(Color.rdBackground)
    }
}
