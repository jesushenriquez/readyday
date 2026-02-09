import Foundation

// MARK: - Supabase Row Models (match DB schema snake_case)

struct RecoveryRow: Codable, Sendable {
    let id: UUID
    let userId: UUID
    let whoopCycleId: Int64
    let whoopSleepId: UUID?
    let scoreState: String
    let recoveryScore: Int?
    let restingHeartRate: Double?
    let hrvRmssdMilli: Double?
    let spo2Percentage: Double?
    let skinTempCelsius: Double?
    let userCalibrating: Bool?
    let recordedAt: Date
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case whoopCycleId = "whoop_cycle_id"
        case whoopSleepId = "whoop_sleep_id"
        case scoreState = "score_state"
        case recoveryScore = "recovery_score"
        case restingHeartRate = "resting_heart_rate"
        case hrvRmssdMilli = "hrv_rmssd_milli"
        case spo2Percentage = "spo2_percentage"
        case skinTempCelsius = "skin_temp_celsius"
        case userCalibrating = "user_calibrating"
        case recordedAt = "recorded_at"
        case createdAt = "created_at"
    }

    func toDomain() -> RecoveryData {
        RecoveryData(
            cycleId: whoopCycleId,
            sleepId: whoopSleepId,
            scoreState: ScoreState(rawValue: scoreState) ?? .unscorable,
            recoveryScore: recoveryScore,
            restingHeartRate: restingHeartRate,
            hrvRmssdMilli: hrvRmssdMilli,
            spo2Percentage: spo2Percentage,
            skinTempCelsius: skinTempCelsius,
            isCalibrating: userCalibrating ?? false,
            recordedAt: recordedAt
        )
    }
}

struct SleepRow: Codable, Sendable {
    let id: UUID
    let userId: UUID
    let whoopSleepId: Int64
    let startTime: Date
    let endTime: Date
    let isNap: Bool
    let scoreState: String
    let stageSummary: StageSummaryJSON?
    let sleepNeededMs: Int64?
    let sleepDebtMs: Int64?
    let sleepEfficiency: Double?
    let sleepConsistency: Int?
    let respiratoryRate: Double?
    let recordedAt: Date

    struct StageSummaryJSON: Codable, Sendable {
        let totalInBedMs: Int64?
        let totalAwakeMs: Int64?
        let totalLightMs: Int64?
        let totalSlowWaveMs: Int64?
        let totalRemMs: Int64?

        enum CodingKeys: String, CodingKey {
            case totalInBedMs = "total_in_bed_ms"
            case totalAwakeMs = "total_awake_ms"
            case totalLightMs = "total_light_ms"
            case totalSlowWaveMs = "total_slow_wave_ms"
            case totalRemMs = "total_rem_ms"
        }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case whoopSleepId = "whoop_sleep_id"
        case startTime = "start_time"
        case endTime = "end_time"
        case isNap = "is_nap"
        case scoreState = "score_state"
        case stageSummary = "stage_summary"
        case sleepNeededMs = "sleep_needed_ms"
        case sleepDebtMs = "sleep_debt_ms"
        case sleepEfficiency = "sleep_efficiency"
        case sleepConsistency = "sleep_consistency"
        case respiratoryRate = "respiratory_rate"
        case recordedAt = "recorded_at"
    }

    func toDomain() -> SleepData {
        let stageSummaryDomain: StageSummary? = {
            guard let summary = stageSummary,
                  let light = summary.totalLightMs,
                  let deep = summary.totalSlowWaveMs,
                  let rem = summary.totalRemMs,
                  let wake = summary.totalAwakeMs else {
                return nil
            }
            return StageSummary(
                lightMillis: light,
                deepMillis: deep,
                remMillis: rem,
                wakeMillis: wake
            )
        }()

        return SleepData(
            sleepId: UUID(uuidString: String(whoopSleepId)) ?? UUID(),
            startTime: startTime,
            endTime: endTime,
            isNap: isNap,
            scoreState: ScoreState(rawValue: scoreState) ?? .unscorable,
            stageSummary: stageSummaryDomain,
            sleepNeededMillis: sleepNeededMs,
            sleepDebtMillis: sleepDebtMs,
            sleepEfficiency: sleepEfficiency,
            sleepConsistency: sleepConsistency.map { Double($0) },
            respiratoryRate: respiratoryRate,
            recordedAt: recordedAt
        )
    }
}

struct WorkoutRow: Codable, Sendable {
    let id: UUID
    let userId: UUID
    let whoopWorkoutId: Int64
    let sportName: String
    let startTime: Date
    let endTime: Date
    let scoreState: String
    let strain: Double?
    let averageHeartRate: Int?
    let maxHeartRate: Int?
    let kilojoule: Double?
    let distanceMeter: Double?
    let zoneDurations: ZoneDurationsJSON?
    let recordedAt: Date

    struct ZoneDurationsJSON: Codable, Sendable {
        let zoneZeroMs: Int64?
        let zoneOneMs: Int64?
        let zoneTwoMs: Int64?
        let zoneThreeMs: Int64?
        let zoneFourMs: Int64?
        let zoneFiveMs: Int64?

        enum CodingKeys: String, CodingKey {
            case zoneZeroMs = "zone_zero_ms"
            case zoneOneMs = "zone_one_ms"
            case zoneTwoMs = "zone_two_ms"
            case zoneThreeMs = "zone_three_ms"
            case zoneFourMs = "zone_four_ms"
            case zoneFiveMs = "zone_five_ms"
        }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case whoopWorkoutId = "whoop_workout_id"
        case sportName = "sport_name"
        case startTime = "start_time"
        case endTime = "end_time"
        case scoreState = "score_state"
        case strain
        case averageHeartRate = "average_heart_rate"
        case maxHeartRate = "max_heart_rate"
        case kilojoule
        case distanceMeter = "distance_meter"
        case zoneDurations = "zone_durations"
        case recordedAt = "recorded_at"
    }

    func toDomain() -> WorkoutData {
        let zoneDurationsDomain: ZoneDurations? = {
            guard let zones = zoneDurations else { return nil }
            return ZoneDurations(
                zone0Millis: zones.zoneZeroMs ?? 0,
                zone1Millis: zones.zoneOneMs ?? 0,
                zone2Millis: zones.zoneTwoMs ?? 0,
                zone3Millis: zones.zoneThreeMs ?? 0,
                zone4Millis: zones.zoneFourMs ?? 0,
                zone5Millis: zones.zoneFiveMs ?? 0
            )
        }()

        return WorkoutData(
            workoutId: UUID(uuidString: String(whoopWorkoutId)) ?? UUID(),
            sportName: sportName,
            startTime: startTime,
            endTime: endTime,
            scoreState: ScoreState(rawValue: scoreState) ?? .unscorable,
            strain: strain,
            averageHeartRate: averageHeartRate,
            maxHeartRate: maxHeartRate,
            kilojoule: kilojoule,
            distanceMeter: distanceMeter,
            zoneDurations: zoneDurationsDomain,
            recordedAt: recordedAt
        )
    }
}

struct UserRow: Codable, Sendable {
    let id: UUID
    let supabaseAuthId: UUID
    let whoopUserId: Int64?
    let email: String?
    let displayName: String?
    let timezone: String
    let onboardingCompleted: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case supabaseAuthId = "supabase_auth_id"
        case whoopUserId = "whoop_user_id"
        case email
        case displayName = "display_name"
        case timezone
        case onboardingCompleted = "onboarding_completed"
    }
}

struct WhoopTokenRow: Codable, Sendable {
    let id: UUID
    let userId: UUID
    let accessToken: String
    let refreshToken: String
    let tokenExpiresAt: Date
    let scopes: String

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case tokenExpiresAt = "token_expires_at"
        case scopes
    }
}

struct DailyBriefingRow: Codable, Sendable {
    let id: UUID
    let userId: UUID
    let briefingDate: Date
    let recoveryZone: String
    let recoveryScore: Int?
    let recommendations: [RecommendationJSON]
    let calendarLoadScore: Int?
    let eventCount: Int
    let highDemandEventCount: Int

    struct RecommendationJSON: Codable, Sendable {
        let type: String
        let title: String
        let description: String
        let priority: String
    }

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case briefingDate = "briefing_date"
        case recoveryZone = "recovery_zone"
        case recoveryScore = "recovery_score"
        case recommendations
        case calendarLoadScore = "calendar_load_score"
        case eventCount = "event_count"
        case highDemandEventCount = "high_demand_event_count"
    }
}

struct UserPreferencesRow: Codable, Sendable {
    let id: UUID
    let userId: UUID
    let enableMorningBriefing: Bool
    let enableRecoveryAlerts: Bool
    let enableWorkoutSuggestions: Bool
    let enableCalendarConflicts: Bool
    let selectedCalendarIds: [String]?
    let workoutPrepTimeMinutes: Int
    let preferredWorkoutTimes: [TimeWindowJSON]?
    let language: String

    struct TimeWindowJSON: Codable, Sendable {
        let startHour: Int
        let startMinute: Int
        let endHour: Int
        let endMinute: Int
    }

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case enableMorningBriefing = "enable_morning_briefing"
        case enableRecoveryAlerts = "enable_recovery_alerts"
        case enableWorkoutSuggestions = "enable_workout_suggestions"
        case enableCalendarConflicts = "enable_calendar_conflicts"
        case selectedCalendarIds = "selected_calendar_ids"
        case workoutPrepTimeMinutes = "workout_prep_time_minutes"
        case preferredWorkoutTimes = "preferred_workout_times"
        case language
    }
}
