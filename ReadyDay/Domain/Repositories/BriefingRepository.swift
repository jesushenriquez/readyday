import Foundation

protocol BriefingRepository: Sendable {
    func getCachedBriefing(userId: UUID, date: Date) async throws -> DayBriefing?
    func saveBriefing(_ briefing: DayBriefing, userId: UUID) async throws
}
