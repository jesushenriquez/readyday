import Foundation

final class BriefingRepositoryImpl: BriefingRepository, @unchecked Sendable {
    private let supabaseManager: SupabaseManager

    init(supabaseManager: SupabaseManager = .shared) {
        self.supabaseManager = supabaseManager
    }

    func getCachedBriefing(userId: UUID, date: Date) async throws -> DayBriefing? {
        // TODO: Implement in Sprint 1 — fetch from Supabase daily_briefings table
        nil
    }

    func saveBriefing(_ briefing: DayBriefing, userId: UUID) async throws {
        // TODO: Implement in Sprint 1 — upsert to Supabase
    }
}
