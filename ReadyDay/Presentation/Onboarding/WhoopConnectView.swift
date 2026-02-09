import SwiftUI

struct WhoopConnectView: View {
    let viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: RDSpacing.xl) {
            Spacer()

            Image(systemName: "heart.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.rdAccent)
                .symbolRenderingMode(.hierarchical)

            VStack(spacing: RDSpacing.xxs) {
                Text("Connect Whoop")
                    .font(.rdDisplayLarge)
                    .foregroundStyle(Color.rdTextPrimary)

                Text("Get personalized insights based on your recovery")
                    .font(.rdBodyLarge)
                    .foregroundStyle(Color.rdTextSecondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            VStack(spacing: RDSpacing.sm) {
                FeatureRow(
                    icon: "heart.fill",
                    title: "Recovery Tracking",
                    description: "See how your body is recovering each day"
                )

                FeatureRow(
                    icon: "moon.fill",
                    title: "Sleep Analysis",
                    description: "Understand your sleep quality and patterns"
                )

                FeatureRow(
                    icon: "figure.run",
                    title: "Workout Insights",
                    description: "Optimize when and how hard to train"
                )
            }
            .padding(.horizontal, RDSpacing.lg)

            Spacer()

            VStack(spacing: RDSpacing.sm) {
                Button("Connect Whoop") {
                    Task { await viewModel.connectWhoop() }
                }
                .buttonStyle(.rdPrimary)
                .disabled(viewModel.isLoading)

                Button("Skip for now") {
                    viewModel.skipWhoop()
                }
                .buttonStyle(.rdSecondary)
            }
            .padding(.horizontal, RDSpacing.sm)

            if let error = viewModel.error {
                Text(error.errorDescription ?? "An error occurred")
                    .font(.rdCaptionLarge)
                    .foregroundStyle(Color.rdError)
                    .padding(.top, RDSpacing.xs)
            }

            Spacer()
        }
        .padding(RDSpacing.sm)
    }
}

// MARK: - Feature Row

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: RDSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(Color.rdAccent)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: RDSpacing.xxxs) {
                Text(title)
                    .font(.rdBodyMedium)
                    .foregroundStyle(Color.rdTextPrimary)

                Text(description)
                    .font(.rdBodySmall)
                    .foregroundStyle(Color.rdTextSecondary)
            }

            Spacer()
        }
    }
}
