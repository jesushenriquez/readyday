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
    let whoopSleepId: UUID
    let startTime: Date
    let endTime: Date
    let isNap: Bool
    let scoreState: String
    let stageSummary: StageSummaryJSON?
    let sleepNeededMs: Int64?
    let sleepDebtMs: Int64?
    let sleepEfficiency: Double?
    let sleepConsistency: Double?
    let respiratoryRate: Double?
    let recordedAt: Date

    struct StageSummaryJSON: Codable, Sendable {
        let lightMs: Int64?
        let deepMs: Int64?
        let remMs: Int64?
        let wakeMs: Int64?

        enum CodingKeys: String, CodingKey {
            case lightMs = "light_ms"
            case deepMs = "deep_ms"
            case remMs = "rem_ms"
            case wakeMs = "wake_ms"
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
}
