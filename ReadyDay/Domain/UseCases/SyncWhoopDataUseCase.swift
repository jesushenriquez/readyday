import Foundation

struct SyncWhoopDataUseCase: Sendable {
    let whoopRepo: any WhoopRepository

    func execute(userId: UUID) async throws {
        // TODO: Implement in Sprint 1
        try await whoopRepo.syncData(userId: userId)
    }
}
