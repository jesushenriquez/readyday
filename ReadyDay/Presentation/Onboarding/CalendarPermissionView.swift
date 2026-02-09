import SwiftUI

struct CalendarPermissionView: View {
    let viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: RDSpacing.xl) {
            Spacer()

            Image(systemName: "calendar.badge.checkmark")
                .font(.system(size: 64))
                .foregroundStyle(Color.rdAccent)
                .symbolRenderingMode(.hierarchical)

            VStack(spacing: RDSpacing.xxs) {
                Text("Calendar Access")
                    .font(.rdDisplayLarge)
                    .foregroundStyle(Color.rdTextPrimary)

                Text("We analyze your schedule to give you smart recommendations")
                    .font(.rdBodyLarge)
                    .foregroundStyle(Color.rdTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, RDSpacing.lg)

                Text("Read-only. We never modify your calendar.")
                    .font(.rdCaptionLarge)
                    .foregroundStyle(Color.rdTextTertiary)
                    .padding(.top, RDSpacing.xxs)
            }

            Spacer()

            VStack(spacing: RDSpacing.sm) {
                BenefitRow(
                    icon: "sparkles",
                    title: "Smart Scheduling",
                    description: "Find the best times for workouts and recovery"
                )

                BenefitRow(
                    icon: "clock.fill",
                    title: "Time Management",
                    description: "Identify gaps and optimize your day"
                )

                BenefitRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Load Analysis",
                    description: "Understand how your schedule affects recovery"
                )
            }
            .padding(.horizontal, RDSpacing.lg)

            Spacer()

            VStack(spacing: RDSpacing.sm) {
                Button("Grant Access") {
                    Task { await viewModel.requestCalendarAccess() }
                }
                .buttonStyle(.rdPrimary)
                .disabled(viewModel.isLoading)

                Button("Skip for now") {
                    viewModel.skipCalendar()
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

// MARK: - Benefit Row

struct BenefitRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: RDSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(Color.rdAccent)
                .frame(width: 28)

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
