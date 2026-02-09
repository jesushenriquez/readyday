import SwiftUI

@Observable
@MainActor
final class DependencyContainer {

    // MARK: - Core Services

    let keychainService: KeychainService
    let supabaseManager: SupabaseManager
    let calendarService: CalendarService

    // MARK: - Network Services

    let whoopOAuthManager: WhoopOAuthManager
    let authManager: AuthManager
    let whoopAPIClient: WhoopAPIClient

    // MARK: - Repositories

    let userRepository: UserRepository
    let whoopRepository: WhoopRepository
    let calendarRepository: CalendarRepository

    // MARK: - Use Cases

    let classifyEventDemandUseCase: ClassifyEventDemandUseCase
    let findWorkoutWindowUseCase: FindWorkoutWindowUseCase
    let generateBriefingUseCase: GenerateBriefingUseCase
    let syncWhoopDataUseCase: SyncWhoopDataUseCase

    // MARK: - ViewModels

    let briefingViewModel: BriefingViewModel
    let timelineViewModel: TimelineViewModel
    let dashboardViewModel: DashboardViewModel
    let onboardingViewModel: OnboardingViewModel
    let settingsViewModel: SettingsViewModel
    let workoutFinderViewModel: WorkoutFinderViewModel

    init() {
        // Core Services
        keychainService = KeychainService()
        supabaseManager = SupabaseManager.shared
        calendarService = CalendarService()

        // Network Services
        whoopOAuthManager = WhoopOAuthManager(keychainService: keychainService)
        whoopAPIClient = WhoopAPIClient(oauthManager: whoopOAuthManager)
        authManager = AuthManager(
            supabaseManager: supabaseManager,
            whoopOAuthManager: whoopOAuthManager
        )

        // Repositories
        userRepository = UserRepositoryImpl(
            supabaseManager: supabaseManager,
            userDefaults: UserDefaultsService()
        )
        whoopRepository = WhoopRepositoryImpl(
            apiClient: whoopAPIClient,
            supabaseManager: supabaseManager
        )
        calendarRepository = CalendarRepositoryImpl(
            calendarService: calendarService
        )

        // Use Cases
        classifyEventDemandUseCase = ClassifyEventDemandUseCase()
        findWorkoutWindowUseCase = FindWorkoutWindowUseCase(calendarRepo: calendarRepository)
        generateBriefingUseCase = GenerateBriefingUseCase(
            whoopRepo: whoopRepository,
            calendarRepo: calendarRepository,
            classifyDemand: classifyEventDemandUseCase,
            findWorkoutWindow: findWorkoutWindowUseCase
        )
        syncWhoopDataUseCase = SyncWhoopDataUseCase(whoopRepo: whoopRepository)

        // ViewModels
        briefingViewModel = BriefingViewModel(
            generateBriefingUseCase: generateBriefingUseCase,
            syncWhoopDataUseCase: syncWhoopDataUseCase,
            userRepository: userRepository
        )
        timelineViewModel = TimelineViewModel(
            calendarRepository: calendarRepository,
            classifyEventDemandUseCase: classifyEventDemandUseCase
        )
        dashboardViewModel = DashboardViewModel(
            whoopRepository: whoopRepository,
            userRepository: userRepository
        )
        onboardingViewModel = OnboardingViewModel(
            authManager: authManager,
            whoopOAuthManager: whoopOAuthManager,
            calendarService: calendarService,
            userRepository: userRepository,
            whoopRepository: whoopRepository
        )
        settingsViewModel = SettingsViewModel()
        workoutFinderViewModel = WorkoutFinderViewModel()
    }
}
