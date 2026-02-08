import Foundation

@Observable
@MainActor
final class DashboardViewModel {

    // MARK: - State

    private(set) var recoveryTrend: [RecoveryData] = []
    private(set) var sleepTrend: [SleepData] = []
    private(set) var selectedPeriod: Period = .sevenDays
    private(set) var isLoading = false
    private(set) var error: ReadyDayError?

    var hasError: Bool { error != nil }

    enum Period: String, CaseIterable {
        case sevenDays = "7d"
        case thirtyDays = "30d"

        var days: Int {
            switch self {
            case .sevenDays: 7
            case .thirtyDays: 30
            }
        }
    }

    var averageRecovery: Int {
        let scored = recoveryTrend.compactMap(\.recoveryScore)
        guard !scored.isEmpty else { return 0 }
        return scored.reduce(0, +) / scored.count
    }

    // MARK: - Actions

    func loadDashboard() async {
        guard !isLoading else { return }
        isLoading = true
        error = nil

        // TODO: Implement in Sprint 2

        isLoading = false
    }

    func selectPeriod(_ period: Period) {
        selectedPeriod = period
        Task { await loadDashboard() }
    }
}
