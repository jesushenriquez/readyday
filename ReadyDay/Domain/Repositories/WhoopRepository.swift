import Foundation

protocol WhoopRepository: Sendable {
    func getLatestRecovery(userId: UUID) async throws -> RecoveryData
    func getRecoveryTrend(userId: UUID, days: Int) async throws -> [RecoveryData]
    func getLatestSleep(userId: UUID) async throws -> SleepData
    func getSleepTrend(userId: UUID, days: Int) async throws -> [SleepData]
    func getLatestWorkout(userId: UUID) async throws -> WorkoutData
    func getWorkouts(userId: UUID, days: Int) async throws -> [WorkoutData]
    func syncData(userId: UUID) async throws
}
