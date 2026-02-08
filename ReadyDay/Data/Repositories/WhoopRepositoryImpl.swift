import Foundation

final class WhoopRepositoryImpl: WhoopRepository, @unchecked Sendable {
    private let apiClient: WhoopAPIClientProtocol
    private let supabaseManager: SupabaseManager

    init(apiClient: WhoopAPIClientProtocol, supabaseManager: SupabaseManager = .shared) {
        self.apiClient = apiClient
        self.supabaseManager = supabaseManager
    }

    func getLatestRecovery(userId: UUID) async throws -> RecoveryData {
        // TODO: Implement in Sprint 1 — fetch from Supabase cache, fallback to API
        throw ReadyDayError.noRecoveryData
    }

    func getRecoveryTrend(userId: UUID, days: Int) async throws -> [RecoveryData] {
        // TODO: Implement in Sprint 2
        []
    }

    func getLatestSleep(userId: UUID) async throws -> SleepData {
        // TODO: Implement in Sprint 1
        throw ReadyDayError.noSleepData
    }

    func getSleepTrend(userId: UUID, days: Int) async throws -> [SleepData] {
        // TODO: Implement in Sprint 2
        []
    }

    func getLatestWorkout(userId: UUID) async throws -> WorkoutData {
        // TODO: Implement in Sprint 1
        throw ReadyDayError.whoopDataUnavailable
    }

    func getWorkouts(userId: UUID, days: Int) async throws -> [WorkoutData] {
        // TODO: Implement in Sprint 2
        []
    }

    func syncData(userId: UUID) async throws {
        // TODO: Implement in Sprint 1
    }
}
