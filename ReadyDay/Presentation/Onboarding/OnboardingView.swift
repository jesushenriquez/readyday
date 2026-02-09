import SwiftUI

struct OnboardingView: View {
    @Bindable var viewModel: OnboardingViewModel

    var body: some View {
        ZStack {
            Color.rdBackground.ignoresSafeArea()

            switch viewModel.currentStep {
            case .welcome:
                WelcomeView(viewModel: viewModel)
            case .connectWhoop:
                WhoopConnectView(viewModel: viewModel)
            case .calendarAccess:
                CalendarPermissionView(viewModel: viewModel)
            case .ready:
                OnboardingCompleteView(viewModel: viewModel)
            }
        }
    }
}

// MARK: - Welcome View

struct WelcomeView: View {
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
            .disabled(viewModel.isLoading)

            if let error = viewModel.error {
                Text(error.errorDescription ?? "An error occurred")
                    .font(.rdCaptionLarge)
                    .foregroundStyle(Color.rdError)
            }

            #if DEBUG
            Button("Dev Sign In (Simulator)") {
                viewModel.devBypassSignIn()
            }
            .font(.rdCaptionLarge)
            .foregroundStyle(Color.rdTextTertiary)
            #endif

            Text("By continuing you agree to Terms & Privacy Policy")
                .font(.rdCaptionLarge)
                .foregroundStyle(Color.rdTextTertiary)

            Spacer()
        }
        .padding(RDSpacing.sm)
    }
}

// MARK: - Onboarding Complete View

struct OnboardingCompleteView: View {
    let viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: RDSpacing.xl) {
            Spacer()

            // Success animation
            ZStack {
                Circle()
                    .fill(Color.rdAccent.opacity(0.2))
                    .frame(width: 120, height: 120)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(Color.rdAccent)
                    .symbolRenderingMode(.hierarchical)
            }

            VStack(spacing: RDSpacing.xxs) {
                Text("You're All Set!")
                    .font(.rdDisplayLarge)
                    .foregroundStyle(Color.rdTextPrimary)

                Text("Your ReadyDay journey begins now")
                    .font(.rdBodyLarge)
                    .foregroundStyle(Color.rdTextSecondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            VStack(spacing: RDSpacing.md) {
                if viewModel.isWhoopConnected {
                    StatusRow(
                        icon: "checkmark.circle.fill",
                        title: "Whoop Connected",
                        color: .rdSuccess
                    )
                } else {
                    StatusRow(
                        icon: "xmark.circle.fill",
                        title: "Whoop Not Connected",
                        color: .rdTextTertiary
                    )
                }

                if viewModel.isCalendarGranted {
                    StatusRow(
                        icon: "checkmark.circle.fill",
                        title: "Calendar Access Granted",
                        color: .rdSuccess
                    )
                } else {
                    StatusRow(
                        icon: "xmark.circle.fill",
                        title: "Calendar Access Denied",
                        color: .rdTextTertiary
                    )
                }
            }
            .padding(.horizontal, RDSpacing.lg)

            Spacer()

            Button("Get Started") {
                Task { await viewModel.completeOnboarding() }
            }
            .buttonStyle(.rdPrimary)
            .padding(.horizontal, RDSpacing.sm)
            .disabled(viewModel.isLoading)

            Spacer()
        }
        .padding(RDSpacing.sm)
    }
}

// MARK: - Status Row

struct StatusRow: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        HStack(spacing: RDSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(color)

            Text(title)
                .font(.rdBodyMedium)
                .foregroundStyle(Color.rdTextPrimary)

            Spacer()
        }
    }
}
