import Foundation
import EventKit

final class CalendarRepositoryImpl: CalendarRepository, @unchecked Sendable {
    private let calendarService: CalendarServiceProtocol

    init(calendarService: CalendarServiceProtocol) {
        self.calendarService = calendarService
    }

    func getEvents(for date: Date) async throws -> [CalendarEvent] {
        let ekEvents = try await calendarService.getEvents(for: date, calendarIDs: nil)
        return ekEvents.map { mapToCalendarEvent($0) }
    }

    func getAvailableCalendars() async -> [(id: String, name: String)] {
        let calendars = calendarService.getCalendars()
        return calendars.map { (id: $0.calendarIdentifier, name: $0.title) }
    }

    func findGaps(for date: Date, minDuration: TimeInterval) async throws -> [TimeWindow] {
        try await calendarService.findGaps(for: date, minDuration: minDuration)
    }

    func requestAccess() async throws -> Bool {
        try await calendarService.requestAccess()
    }

    // MARK: - Private Helpers

    private func mapToCalendarEvent(_ ekEvent: EKEvent) -> CalendarEvent {
        CalendarEvent(
            id: ekEvent.eventIdentifier,
            title: ekEvent.title ?? "Untitled",
            startDate: ekEvent.startDate,
            endDate: ekEvent.endDate,
            location: ekEvent.location,
            attendeeCount: ekEvent.attendees?.count ?? 0,
            calendarName: ekEvent.calendar?.title,
            isAllDay: ekEvent.isAllDay
        )
    }
}
