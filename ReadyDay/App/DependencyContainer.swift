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

        // ViewModels
        briefingViewModel = BriefingViewModel(
            whoopRepository: whoopRepository,
            calendarRepository: calendarRepository,
            classifyEventDemandUseCase: classifyEventDemandUseCase
        )
        timelineViewModel = TimelineViewModel(
            calendarRepository: calendarRepository,
            classifyEventDemandUseCase: classifyEventDemandUseCase
        )
        dashboardViewModel = DashboardViewModel()
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
