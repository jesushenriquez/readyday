import Foundation

@Observable
@MainActor
final class TimelineViewModel {

    // MARK: - Dependencies

    private let calendarRepository: CalendarRepository
    private let classifyEventDemandUseCase: ClassifyEventDemandUseCase

    // MARK: - State

    private(set) var events: [ClassifiedEvent] = []
    private(set) var gaps: [TimeWindow] = []
    private(set) var calendarLoadScore: Double = 0
    private(set) var selectedDate: Date = .now
    private(set) var isLoading = false
    private(set) var error: ReadyDayError?

    var hasError: Bool { error != nil }
    var highDemandCount: Int { events.filter { $0.demand == .high }.count }

    // MARK: - Initialization

    init(
        calendarRepository: CalendarRepository,
        classifyEventDemandUseCase: ClassifyEventDemandUseCase
    ) {
        self.calendarRepository = calendarRepository
        self.classifyEventDemandUseCase = classifyEventDemandUseCase
    }

    // MARK: - Actions

    func loadTimeline() async {
        guard !isLoading else { return }
        isLoading = true
        error = nil

        // TODO: Implement in Sprint 1

        isLoading = false
    }

    func selectDate(_ date: Date) {
        selectedDate = date
        Task { await loadTimeline() }
    }

    func goToNextDay() {
        selectDate(selectedDate.adding(days: 1))
    }

    func goToPreviousDay() {
        selectDate(selectedDate.adding(days: -1))
    }
}
