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

        do {
            let rawEvents = try await calendarRepository.getEvents(for: selectedDate)
            let classified = classifyEventDemandUseCase.classifyAll(events: rawEvents)
            let foundGaps = try await calendarRepository.findGaps(for: selectedDate, minDuration: 30 * 60)

            events = classified
            gaps = foundGaps
            calendarLoadScore = calculateCalendarLoad(events: classified)
        } catch let rdError as ReadyDayError {
            error = rdError
        } catch {
            self.error = .unknown(underlying: error.localizedDescription)
        }

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

    // MARK: - Private

    private func calculateCalendarLoad(events: [ClassifiedEvent]) -> Double {
        let countComponent = min(Double(events.count) * 8, 60)
        let demandWeighted = events.reduce(0.0) { total, event in
            switch event.demand {
            case .high: total + 3
            case .medium: total + 2
            case .low: total + 1
            }
        }
        let demandComponent = min(demandWeighted / 30 * 40, 40)
        return min(countComponent + demandComponent, 100)
    }
}
