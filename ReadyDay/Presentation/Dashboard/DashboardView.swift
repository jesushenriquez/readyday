import SwiftUI

struct DashboardView: View {
    let viewModel: DashboardViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: RDSpacing.lg) {
                // Period picker
                Picker("Period", selection: Binding(
                    get: { viewModel.selectedPeriod },
                    set: { viewModel.selectPeriod($0) }
                )) {
                    ForEach(DashboardViewModel.Period.allCases, id: \.self) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(.segmented)

                if viewModel.isLoading {
                    LoadingView()
                } else if viewModel.hasError {
                    ErrorView(
                        message: viewModel.error?.errorDescription ?? "Something went wrong",
                        retryAction: { Task { await viewModel.loadDashboard() } }
                    )
                } else if viewModel.recoveryTrend.isEmpty {
                    EmptyStateView(
                        icon: "chart.line.uptrend",
                        title: "No trend data yet",
                        message: "Connect your Whoop to see recovery trends over time."
                    )
                } else {
                    TrendChartView(data: viewModel.recoveryTrend)
                }
            }
            .padding(RDSpacing.sm)
        }
        .background(Color.rdBackground)
        .refreshable { await viewModel.loadDashboard() }
        .task { await viewModel.loadDashboard() }
    }
}
