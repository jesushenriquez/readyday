import Foundation

struct WhoopSleepDTO: Codable, Sendable {
    let id: String
    let userId: Int64
    let start: String
    let end: String
    let nap: Bool
    let scoreState: String
    let score: ScoreDTO?

    struct ScoreDTO: Codable, Sendable {
        let stageSummary: StageSummaryDTO?
        let sleepNeeded: SleepNeededDTO?
        let sleepEfficiency: Double?
        let sleepConsistency: Double?
        let respiratoryRate: Double?

        struct StageSummaryDTO: Codable, Sendable {
            let totalInBedTimeMilli: Int64?
            let totalAwakeTimeMilli: Int64?
            let totalNoDataTimeMilli: Int64?
            let totalLightSleepTimeMilli: Int64?
            let totalSlowWaveSleepTimeMilli: Int64?
            let totalRemSleepTimeMilli: Int64?
            let sleepCycleCount: Int?
            let disturbanceCount: Int?

            enum CodingKeys: String, CodingKey {
                case totalInBedTimeMilli = "total_in_bed_time_milli"
                case totalAwakeTimeMilli = "total_awake_time_milli"
                case totalNoDataTimeMilli = "total_no_data_time_milli"
                case totalLightSleepTimeMilli = "total_light_sleep_time_milli"
                case totalSlowWaveSleepTimeMilli = "total_slow_wave_sleep_time_milli"
                case totalRemSleepTimeMilli = "total_rem_sleep_time_milli"
                case sleepCycleCount = "sleep_cycle_count"
                case disturbanceCount = "disturbance_count"
            }
        }

        struct SleepNeededDTO: Codable, Sendable {
            let baselineMilli: Int64?
            let needFromSleepDebtMilli: Int64?
            let needFromRecentStrainMilli: Int64?
            let needFromRecentNapMilli: Int64?

            enum CodingKeys: String, CodingKey {
                case baselineMilli = "baseline_milli"
                case needFromSleepDebtMilli = "need_from_sleep_debt_milli"
                case needFromRecentStrainMilli = "need_from_recent_strain_milli"
                case needFromRecentNapMilli = "need_from_recent_nap_milli"
            }
        }

        enum CodingKeys: String, CodingKey {
            case stageSummary = "stage_summary"
            case sleepNeeded = "sleep_needed"
            case sleepEfficiency = "sleep_efficiency"
            case sleepConsistency = "sleep_consistency"
            case respiratoryRate = "respiratory_rate"
        }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case start, end, nap
        case scoreState = "score_state"
        case score
    }
}

extension WhoopSleepDTO {
    func toDomain() -> SleepData {
        let formatter = ISO8601DateFormatter()

        let stages: StageSummary? = score?.stageSummary.map { s in
            StageSummary(
                lightMillis: s.totalLightSleepTimeMilli ?? 0,
                deepMillis: s.totalSlowWaveSleepTimeMilli ?? 0,
                remMillis: s.totalRemSleepTimeMilli ?? 0,
                wakeMillis: s.totalAwakeTimeMilli ?? 0
            )
        }

        let sleepNeededMillis: Int64? = score?.sleepNeeded.map { needed in
            (needed.baselineMilli ?? 0)
            + (needed.needFromSleepDebtMilli ?? 0)
            + (needed.needFromRecentStrainMilli ?? 0)
            + (needed.needFromRecentNapMilli ?? 0)
        }

        return SleepData(
            sleepId: UUID(uuidString: id) ?? UUID(),
            startTime: formatter.date(from: start) ?? Date(),
            endTime: formatter.date(from: end) ?? Date(),
            isNap: nap,
            scoreState: ScoreState(rawValue: scoreState) ?? .unscorable,
            stageSummary: stages,
            sleepNeededMillis: sleepNeededMillis,
            sleepDebtMillis: score?.sleepNeeded?.needFromSleepDebtMilli,
            sleepEfficiency: score?.sleepEfficiency,
            sleepConsistency: score?.sleepConsistency,
            respiratoryRate: score?.respiratoryRate,
            recordedAt: formatter.date(from: start) ?? Date()
        )
    }
}
