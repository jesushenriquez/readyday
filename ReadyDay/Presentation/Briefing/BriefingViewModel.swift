import Foundation

@Observable
@MainActor
final class BriefingViewModel {

    // MARK: - Dependencies

    private let generateBriefingUseCase: GenerateBriefingUseCase
    private let syncWhoopDataUseCase: SyncWhoopDataUseCase
    private let userRepository: UserRepository

    // MARK: - State

    private(set) var briefing: DayBriefing?
    private(set) var isLoading = false
    private(set) var error: ReadyDayError?
    private var hasSynced = false

    var hasError: Bool { error != nil }
    var recoveryScore: Int { briefing?.recoveryScore ?? 0 }
    var zone: RecoveryZone { briefing?.recoveryZone ?? .unknown }
    var recommendations: [Recommendation] { briefing?.recommendations ?? [] }
    var sleepSummary: SleepSummary? { briefing?.sleepSummary }
    var workoutWindows: [TimeWindow] { briefing?.suggestedWorkoutWindows ?? [] }
    var events: [ClassifiedEvent] { briefing?.events ?? [] }
    var calendarLoadScore: Double { briefing?.calendarLoadScore ?? 0 }

    // MARK: - Initialization

    init(
        generateBriefingUseCase: GenerateBriefingUseCase,
        syncWhoopDataUseCase: SyncWhoopDataUseCase,
        userRepository: UserRepository
    ) {
        self.generateBriefingUseCase = generateBriefingUseCase
        self.syncWhoopDataUseCase = syncWhoopDataUseCase
        self.userRepository = userRepository
    }

    // MARK: - Actions

    func loadBriefing() async {
        guard !isLoading else { return }
        isLoading = true
        error = nil

        do {
            guard let userId = await userRepository.getCurrentUserId() else {
                throw ReadyDayError.authenticationFailed
            }

            do {
                briefing = try await generateBriefingUseCase.execute(for: Date(), userId: userId)
            } catch ReadyDayError.noRecoveryData, ReadyDayError.noSleepData {
                // No data yet — sync from Whoop API and retry once
                guard !hasSynced else { throw ReadyDayError.noRecoveryData }
                hasSynced = true
                try await syncWhoopDataUseCase.execute(userId: userId)
                briefing = try await generateBriefingUseCase.execute(for: Date(), userId: userId)
            }
        } catch let rdError as ReadyDayError {
            error = rdError
        } catch {
            self.error = .unknown(underlying: error.localizedDescription)
        }

        isLoading = false
    }

    func refresh() async {
        hasSynced = false
        await loadBriefing()
    }
}
