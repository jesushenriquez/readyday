import Foundation

@Observable
@MainActor
final class WorkoutFinderViewModel {

    // MARK: - State

    private(set) var workoutWindows: [TimeWindow] = []
    private(set) var selectedDate: Date = .now
    private(set) var isLoading = false
    private(set) var error: ReadyDayError?

    var hasError: Bool { error != nil }

    // MARK: - Actions

    func findWindows() async {
        guard !isLoading else { return }
        isLoading = true
        error = nil

        // TODO: Implement in Sprint 1

        isLoading = false
    }
}
