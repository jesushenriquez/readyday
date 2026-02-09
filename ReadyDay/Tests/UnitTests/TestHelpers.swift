import Foundation
@testable import ReadyDay

// MARK: - Mock CalendarRepository

final class MockCalendarRepository: CalendarRepository, @unchecked Sendable {
    var mockEvents: [CalendarEvent] = []
    var mockCalendars: [(id: String, name: String)] = []
    var mockGaps: [TimeWindow] = []
    var shouldGrantAccess = true

    func getEvents(for date: Date) async throws -> [CalendarEvent] {
        return mockEvents
    }

    func getAvailableCalendars() async -> [(id: String, name: String)] {
        return mockCalendars
    }

    func findGaps(for date: Date, minDuration: TimeInterval) async throws -> [TimeWindow] {
        return mockGaps
    }

    func requestAccess() async throws -> Bool {
        return shouldGrantAccess
    }
}

// MARK: - Mock WhoopRepository

final class MockWhoopRepository: WhoopRepository, @unchecked Sendable {
    var mockRecovery: RecoveryData?
    var mockRecoveryTrend: [RecoveryData] = []
    var mockSleep: SleepData?
    var mockSleepTrend: [SleepData] = []
    var mockWorkout: WorkoutData?
    var mockWorkouts: [WorkoutData] = []

    func syncData(userId: UUID) async throws {
        // No-op for tests
    }

    func getLatestRecovery(userId: UUID) async throws -> RecoveryData {
        guard let recovery = mockRecovery else {
            throw ReadyDayError.noRecoveryData
        }
        return recovery
    }

    func getRecoveryTrend(userId: UUID, days: Int) async throws -> [RecoveryData] {
        return mockRecoveryTrend
    }

    func getLatestSleep(userId: UUID) async throws -> SleepData {
        guard let sleep = mockSleep else {
            throw ReadyDayError.noSleepData
        }
        return sleep
    }

    func getSleepTrend(userId: UUID, days: Int) async throws -> [SleepData] {
        return mockSleepTrend
    }

    func getLatestWorkout(userId: UUID) async throws -> WorkoutData {
        guard let workout = mockWorkout else {
            throw ReadyDayError.whoopDataUnavailable
        }
        return workout
    }

    func getWorkouts(userId: UUID, days: Int) async throws -> [WorkoutData] {
        return mockWorkouts
    }
}
