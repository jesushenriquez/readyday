import SwiftUI

struct WorkoutFinderView: View {
    let viewModel: WorkoutFinderViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: RDSpacing.sm) {
                if viewModel.isLoading {
                    LoadingView()
                } else if viewModel.workoutWindows.isEmpty {
                    EmptyStateView(
                        icon: "figure.run",
                        title: "No workout windows",
                        message: "Your schedule is fully booked today. Try another day."
                    )
                } else {
                    ForEach(Array(viewModel.workoutWindows.enumerated()), id: \.offset) { _, window in
                        HStack {
                            Image(systemName: "figure.run")
                                .font(.system(size: 20))
                                .foregroundStyle(Color.rdPrimary)

                            VStack(alignment: .leading, spacing: RDSpacing.xxxs) {
                                Text("\(window.start.hourAndMinute) - \(window.end.hourAndMinute)")
                                    .font(.rdHeadingSmall)
                                    .foregroundStyle(Color.rdTextPrimary)

                                Text("\(window.durationMinutes) minutes available")
                                    .font(.rdCaptionLarge)
                                    .foregroundStyle(Color.rdTextSecondary)
                            }

                            Spacer()
                        }
                        .padding(RDSpacing.sm)
                        .background(Color.rdSurface)
                        .clipShape(RoundedRectangle(cornerRadius: RDRadius.md))
                    }
                }
            }
            .padding(RDSpacing.sm)
        }
        .background(Color.rdBackground)
        .navigationTitle("Workout Finder")
        .task { await viewModel.findWindows() }
    }
}
