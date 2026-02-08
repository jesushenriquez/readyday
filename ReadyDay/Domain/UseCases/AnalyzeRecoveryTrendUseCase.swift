import Foundation

struct AnalyzeRecoveryTrendUseCase: Sendable {
    let whoopRepo: any WhoopRepository

    func execute(userId: UUID, days: Int = 7) async throws -> [RecoveryData] {
        // TODO: Implement trend analysis in Sprint 2
        try await whoopRepo.getRecoveryTrend(userId: userId, days: days)
    }
}
