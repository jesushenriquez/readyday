import Foundation
import Supabase

final class WhoopRepositoryImpl: WhoopRepository, @unchecked Sendable {
    private let apiClient: WhoopAPIClientProtocol
    private let supabaseManager: SupabaseManager
    private let lastSyncKey = "com.readyday.whoop.lastSync"

    init(apiClient: WhoopAPIClientProtocol, supabaseManager: SupabaseManager = .shared) {
        self.apiClient = apiClient
        self.supabaseManager = supabaseManager
    }

    // MARK: - Sync

    func syncData(userId: UUID) async throws {
        // Calculate date range (last 30 days)
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -30, to: endDate)!

        // Fetch data from Whoop API in parallel
        async let recoveries = apiClient.getRecoveries(start: startDate, end: endDate, limit: 100)
        async let sleeps = apiClient.getSleeps(start: startDate, end: endDate, limit: 100)
        async let workouts = apiClient.getWorkouts(start: startDate, end: endDate, limit: 100)

        let (recoveryDTOs, sleepDTOs, workoutDTOs) = try await (recoveries, sleeps, workouts)

        // Transform DTOs to Row models
        let recoveryRows = recoveryDTOs.map { dto -> RecoveryRow in
            RecoveryRow(
                id: UUID(),
                userId: userId,
                whoopCycleId: dto.cycleId,
                whoopSleepId: dto.sleepId.flatMap { UUID(uuidString: $0) },
                scoreState: dto.scoreState,
                recoveryScore: dto.score?.recoveryScore,
                restingHeartRate: dto.score?.restingHeartRate,
                hrvRmssdMilli: dto.score?.hrvRmssdMilli,
                spo2Percentage: dto.score?.spo2Percentage,
                skinTempCelsius: dto.score?.skinTempCelsius,
                userCalibrating: dto.score?.userCalibrating,
                recordedAt: ISO8601DateFormatter().date(from: dto.createdAt) ?? Date(),
                createdAt: Date()
            )
        }

        let formatter = ISO8601DateFormatter()
        let sleepRows = sleepDTOs.map { dto -> SleepRow in
            let stageSummary: SleepRow.StageSummaryJSON?
            if let score = dto.score, let stages = score.stageSummary {
                stageSummary = SleepRow.StageSummaryJSON(
                    totalInBedMs: stages.totalInBedTimeMilli,
                    totalAwakeMs: stages.totalAwakeTimeMilli,
                    totalLightMs: stages.totalLightSleepTimeMilli,
                    totalSlowWaveMs: stages.totalSlowWaveSleepTimeMilli,
                    totalRemMs: stages.totalRemSleepTimeMilli
                )
            } else {
                stageSummary = nil
            }

            let sleepNeeded: Int64?
            if let needed = dto.score?.sleepNeeded {
                sleepNeeded = (needed.baselineMilli ?? 0)
                    + (needed.needFromSleepDebtMilli ?? 0)
                    + (needed.needFromRecentStrainMilli ?? 0)
                    + (needed.needFromRecentNapMilli ?? 0)
            } else {
                sleepNeeded = nil
            }

            let sleepConsistency = dto.score?.sleepConsistency.map { Int($0) }

            return SleepRow(
                id: UUID(),
                userId: userId,
                whoopSleepId: Int64(dto.id) ?? 0,
                startTime: formatter.date(from: dto.start) ?? Date(),
                endTime: formatter.date(from: dto.end) ?? Date(),
                isNap: dto.nap,
                scoreState: dto.scoreState,
                stageSummary: stageSummary,
                sleepNeededMs: sleepNeeded,
                sleepDebtMs: dto.score?.sleepNeeded?.needFromSleepDebtMilli,
                sleepEfficiency: dto.score?.sleepEfficiency,
                sleepConsistency: sleepConsistency,
                respiratoryRate: dto.score?.respiratoryRate,
                recordedAt: formatter.date(from: dto.start) ?? Date()
            )
        }

        let workoutRows = workoutDTOs.map { dto -> WorkoutRow in
            let zoneDurations = dto.score.flatMap { score -> WorkoutRow.ZoneDurationsJSON? in
                guard let zones = score.zoneDuration else { return nil }
                return WorkoutRow.ZoneDurationsJSON(
                    zoneZeroMs: zones.zoneZeroMilli,
                    zoneOneMs: zones.zoneOneMilli,
                    zoneTwoMs: zones.zoneTwoMilli,
                    zoneThreeMs: zones.zoneThreeMilli,
                    zoneFourMs: zones.zoneFourMilli,
                    zoneFiveMs: zones.zoneFiveMilli
                )
            }

            // Map sport ID to name (can be extended later)
            let sportName = dto.sportId.map { "Sport \($0)" } ?? "Unknown"

            return WorkoutRow(
                id: UUID(),
                userId: userId,
                whoopWorkoutId: Int64(dto.id) ?? 0,
                sportName: sportName,
                startTime: ISO8601DateFormatter().date(from: dto.start) ?? Date(),
                endTime: ISO8601DateFormatter().date(from: dto.end) ?? Date(),
                scoreState: dto.scoreState,
                strain: dto.score?.strain,
                averageHeartRate: dto.score?.averageHeartRate,
                maxHeartRate: dto.score?.maxHeartRate,
                kilojoule: dto.score?.kilojoule,
                distanceMeter: dto.score?.distanceMeter,
                zoneDurations: zoneDurations,
                recordedAt: ISO8601DateFormatter().date(from: dto.start) ?? Date()
            )
        }

        // Upsert to Supabase (using conflict resolution on unique constraints)
        if !recoveryRows.isEmpty {
            try await supabaseManager.client
                .from("recovery_data")
                .upsert(recoveryRows)
                .execute()
        }

        if !sleepRows.isEmpty {
            try await supabaseManager.client
                .from("sleep_data")
                .upsert(sleepRows)
                .execute()
        }

        if !workoutRows.isEmpty {
            try await supabaseManager.client
                .from("workout_data")
                .upsert(workoutRows)
                .execute()
        }

        // Save last sync timestamp
        UserDefaults.standard.set(Date(), forKey: lastSyncKey)
    }

    // MARK: - Queries

    func getLatestRecovery(userId: UUID) async throws -> RecoveryData {
        let response = try await supabaseManager.client
            .from("recovery_data")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("recorded_at", ascending: false)
            .limit(1)
            .execute()

        let data = response.data

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601

        let rows = try decoder.decode([RecoveryRow].self, from: data)
        guard let row = rows.first else {
            throw ReadyDayError.noRecoveryData
        }

        return row.toDomain()
    }

    func getRecoveryTrend(userId: UUID, days: Int) async throws -> [RecoveryData] {
        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: Date())!

        let response = try await supabaseManager.client
            .from("recovery_data")
            .select()
            .eq("user_id", value: userId.uuidString)
            .gte("recorded_at", value: startDate.ISO8601Format())
            .order("recorded_at", ascending: false)
            .execute()

        let data = response.data

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601

        let rows = try decoder.decode([RecoveryRow].self, from: data)
        return rows.map { $0.toDomain() }
    }

    func getLatestSleep(userId: UUID) async throws -> SleepData {
        let response = try await supabaseManager.client
            .from("sleep_data")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("recorded_at", ascending: false)
            .limit(1)
            .execute()

        let data = response.data

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601

        let rows = try decoder.decode([SleepRow].self, from: data)
        guard let row = rows.first else {
            throw ReadyDayError.noSleepData
        }

        return row.toDomain()
    }

    func getSleepTrend(userId: UUID, days: Int) async throws -> [SleepData] {
        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: Date())!

        let response = try await supabaseManager.client
            .from("sleep_data")
            .select()
            .eq("user_id", value: userId.uuidString)
            .gte("recorded_at", value: startDate.ISO8601Format())
            .order("recorded_at", ascending: false)
            .execute()

        let data = response.data

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601

        let rows = try decoder.decode([SleepRow].self, from: data)
        return rows.map { $0.toDomain() }
    }

    func getLatestWorkout(userId: UUID) async throws -> WorkoutData {
        let response = try await supabaseManager.client
            .from("workout_data")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("recorded_at", ascending: false)
            .limit(1)
            .execute()

        let data = response.data

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601

        let rows = try decoder.decode([WorkoutRow].self, from: data)
        guard let row = rows.first else {
            throw ReadyDayError.whoopDataUnavailable
        }

        return row.toDomain()
    }

    func getWorkouts(userId: UUID, days: Int) async throws -> [WorkoutData] {
        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: Date())!

        let response = try await supabaseManager.client
            .from("workout_data")
            .select()
            .eq("user_id", value: userId.uuidString)
            .gte("recorded_at", value: startDate.ISO8601Format())
            .order("recorded_at", ascending: false)
            .execute()

        let data = response.data

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601

        let rows = try decoder.decode([WorkoutRow].self, from: data)
        return rows.map { $0.toDomain() }
    }
}
