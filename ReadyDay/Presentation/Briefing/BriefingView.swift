import SwiftUI

struct BriefingView: View {
    let viewModel: BriefingViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: RDSpacing.lg) {
                if viewModel.isLoading {
                    LoadingView()
                } else if viewModel.hasError {
                    ErrorView(
                        message: viewModel.error?.errorDescription ?? "Something went wrong",
                        retryAction: { Task { await viewModel.refresh() } }
                    )
                } else if viewModel.briefing != nil {
                    briefingContent
                } else {
                    EmptyStateView(
                        icon: "sun.max.fill",
                        title: "No briefing yet",
                        message: "Connect your Whoop and calendar to get your daily briefing."
                    )
                }
            }
            .padding(RDSpacing.sm)
        }
        .background(Color.rdBackground)
        .refreshable { await viewModel.refresh() }
        .task { await viewModel.loadBriefing() }
    }

    @ViewBuilder
    private var briefingContent: some View {
        RecoveryScoreView(
            score: viewModel.recoveryScore,
            zone: viewModel.zone
        )

        if let sleep = viewModel.sleepSummary {
            SleepSummaryView(summary: sleep)
        }

        if !viewModel.recommendations.isEmpty {
            VStack(alignment: .leading, spacing: RDSpacing.xs) {
                Text("Recommendations")
                    .font(.rdHeadingLarge)
                    .foregroundStyle(Color.rdTextPrimary)

                ForEach(viewModel.recommendations) { rec in
                    RecommendationCardView(recommendation: rec)
                }
            }
        }
    }
}
