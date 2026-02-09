import SwiftUI

struct TimelineView: View {
    let viewModel: TimelineViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: RDSpacing.sm) {
                // Calendar load bar
                VStack(alignment: .leading, spacing: RDSpacing.xxxs) {
                    HStack {
                        Text("Day Load")
                            .font(.rdCaptionLarge)
                            .foregroundStyle(Color.rdTextSecondary)
                        Spacer()
                        Text("\(Int(viewModel.calendarLoadScore))/100")
                            .font(.rdDataSmall)
                            .foregroundStyle(Color.rdTextSecondary)
                    }

                    ProgressView(value: viewModel.calendarLoadScore, total: 100)
                        .tint(.rdPrimary)

                    Text("\(viewModel.events.count) events · \(viewModel.highDemandCount) high demand")
                        .font(.rdCaptionLarge)
                        .foregroundStyle(Color.rdTextTertiary)
                }
                .padding(RDSpacing.sm)
                .background(Color.rdSurface)
                .clipShape(RoundedRectangle(cornerRadius: RDRadius.md))

                if viewModel.isLoading {
                    LoadingView()
                } else if viewModel.events.isEmpty {
                    EmptyStateView(
                        icon: "calendar",
                        title: "No events today",
                        message: "Your calendar is clear. Great day for deep work!"
                    )
                } else {
                    ForEach(viewModel.events) { event in
                        TimelineEventBlock(event: event)
                    }
                }
            }
            .padding(RDSpacing.sm)
        }
        .background(Color.rdBackground)
        .refreshable { await viewModel.loadTimeline() }
        .task { await viewModel.loadTimeline() }
    }
}
