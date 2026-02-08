import Foundation

struct FindWorkoutWindowUseCase: Sendable {
    let calendarRepo: any CalendarRepository

    func execute(
        date: Date,
        events: [CalendarEvent],
        recoveryZone: RecoveryZone
    ) async throws -> [TimeWindow] {
        // TODO: Implement in Sprint 1
        return []
    }
}
