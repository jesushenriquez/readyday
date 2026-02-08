import Foundation

protocol CalendarRepository: Sendable {
    func getEvents(for date: Date) async throws -> [CalendarEvent]
    func getAvailableCalendars() async -> [(id: String, name: String)]
    func findGaps(for date: Date, minDuration: TimeInterval) async throws -> [TimeWindow]
    func requestAccess() async throws -> Bool
}
