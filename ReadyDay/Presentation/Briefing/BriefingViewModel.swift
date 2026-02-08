import Foundation

@Observable
@MainActor
final class BriefingViewModel {

    // MARK: - State

    private(set) var briefing: DayBriefing?
    private(set) var isLoading = false
    private(set) var error: ReadyDayError?

    var hasError: Bool { error != nil }
    var recoveryScore: Int { briefing?.recoveryScore ?? 0 }
    var zone: RecoveryZone { briefing?.recoveryZone ?? .unknown }
    var recommendations: [Recommendation] { briefing?.recommendations ?? [] }
    var sleepSummary: SleepSummary? { briefing?.sleepSummary }
    var workoutWindows: [TimeWindow] { briefing?.suggestedWorkoutWindows ?? [] }
    var events: [ClassifiedEvent] { briefing?.events ?? [] }
    var calendarLoadScore: Double { briefing?.calendarLoadScore ?? 0 }

    // MARK: - Actions

    func loadBriefing() async {
        guard !isLoading else { return }
        isLoading = true
        error = nil

        // TODO: Inject and call GenerateBriefingUseCase in Sprint 1
        // For now, show empty state

        isLoading = false
    }

    func refresh() async {
        await loadBriefing()
    }
}
