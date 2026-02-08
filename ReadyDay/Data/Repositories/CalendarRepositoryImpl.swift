import Foundation

final class CalendarRepositoryImpl: CalendarRepository, @unchecked Sendable {
    private let calendarService: CalendarServiceProtocol

    init(calendarService: CalendarServiceProtocol) {
        self.calendarService = calendarService
    }

    func getEvents(for date: Date) async throws -> [CalendarEvent] {
        // TODO: Implement in Sprint 1 — map EKEvent to CalendarEvent
        []
    }

    func getAvailableCalendars() async -> [(id: String, name: String)] {
        // TODO: Implement in Sprint 1
        []
    }

    func findGaps(for date: Date, minDuration: TimeInterval) async throws -> [TimeWindow] {
        // TODO: Implement in Sprint 1
        []
    }

    func requestAccess() async throws -> Bool {
        try await calendarService.requestAccess()
    }
}
