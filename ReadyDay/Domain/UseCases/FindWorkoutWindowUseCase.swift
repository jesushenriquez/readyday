import Foundation

struct FindWorkoutWindowUseCase: Sendable {
    let calendarRepo: any CalendarRepository

    func execute(
        date: Date,
        events: [CalendarEvent],
        recoveryZone: RecoveryZone
    ) async throws -> [TimeWindow] {
        let (minDuration, maxWindows) = parameters(for: recoveryZone)
        let gaps = try await calendarRepo.findGaps(for: date, minDuration: minDuration)
        return Array(gaps.prefix(maxWindows))
    }

    private func parameters(for zone: RecoveryZone) -> (minDuration: TimeInterval, maxWindows: Int) {
        switch zone {
        case .green:
            (45 * 60, 3)
        case .yellow, .unknown:
            (30 * 60, 2)
        case .red:
            (20 * 60, 1)
        }
    }
}
