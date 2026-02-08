import SwiftUI

struct CalendarPermissionView: View {
    let viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: RDSpacing.xl) {
            Spacer()

            Image(systemName: "calendar.badge.checkmark")
                .font(.system(size: 64))
                .foregroundStyle(Color.rdPrimary)
                .symbolRenderingMode(.hierarchical)

            VStack(spacing: RDSpacing.xxs) {
                Text("Accede a tu calendario")
                    .font(.rdDisplayMedium)
                    .foregroundStyle(Color.rdTextPrimary)

                Text("Leemos tu agenda para entender la demanda de tu dia y darte recomendaciones inteligentes.")
                    .font(.rdBodyMedium)
                    .foregroundStyle(Color.rdTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, RDSpacing.lg)

                Text("Solo lectura. Nunca modificamos tu calendario.")
                    .font(.rdCaptionLarge)
                    .foregroundStyle(Color.rdTextTertiary)
                    .padding(.top, RDSpacing.xxs)
            }

            Spacer()

            Button("Permitir acceso") {
                Task { await viewModel.requestCalendarAccess() }
            }
            .buttonStyle(.rdPrimary)
            .padding(.horizontal, RDSpacing.sm)

            Spacer()
        }
        .padding(RDSpacing.sm)
        .background(Color.rdBackground)
    }
}
