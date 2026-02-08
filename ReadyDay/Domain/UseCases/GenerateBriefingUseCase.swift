import Foundation

struct GenerateBriefingUseCase: Sendable {
    let whoopRepo: any WhoopRepository
    let calendarRepo: any CalendarRepository
    let classifyDemand: ClassifyEventDemandUseCase
    let findWorkoutWindow: FindWorkoutWindowUseCase

    func execute(for date: Date, userId: UUID) async throws -> DayBriefing {
        // TODO: Implement in Sprint 1
        fatalError("Not yet implemented")
    }
}
