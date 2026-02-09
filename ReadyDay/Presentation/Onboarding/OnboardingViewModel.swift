import Foundation

// MARK: - Notification

extension Notification.Name {
    static let onboardingCompleted = Notification.Name("com.readyday.onboardingCompleted")
    static let userDidSignOut = Notification.Name("com.readyday.userDidSignOut")
    static let navigateToBriefing = Notification.Name("com.readyday.navigateToBriefing")
}

// MARK: - ViewModel

@Observable
@MainActor
final class OnboardingViewModel {

    // MARK: - Dependencies

    private let authManager: AuthManager
    private let whoopOAuthManager: WhoopOAuthManager
    private let calendarService: CalendarServiceProtocol
    private let userRepository: UserRepository
    private let whoopRepository: WhoopRepository

    // MARK: - State

    private(set) var currentStep: OnboardingStep = .welcome
    private(set) var isLoading = false
    private(set) var error: ReadyDayError?
    private(set) var isWhoopConnected = false
    private(set) var isCalendarGranted = false

    enum OnboardingStep: Int, CaseIterable {
        case welcome
        case connectWhoop
        case calendarAccess
        case ready
    }

    // MARK: - Initialization

    init(
        authManager: AuthManager,
        whoopOAuthManager: WhoopOAuthManager,
        calendarService: CalendarServiceProtocol,
        userRepository: UserRepository,
        whoopRepository: WhoopRepository
    ) {
        self.authManager = authManager
        self.whoopOAuthManager = whoopOAuthManager
        self.calendarService = calendarService
        self.userRepository = userRepository
        self.whoopRepository = whoopRepository
    }

    // MARK: - Actions

    func signInWithApple() async {
        isLoading = true
        error = nil

        do {
            try await authManager.signInWithApple()

            // Returning user: Whoop already connected from a previous install
            if await whoopOAuthManager.isConnected() {
                isWhoopConnected = true
                await completeOnboarding()
                return
            }

            advance()
        } catch {
            print("[Onboarding] Apple Sign In error: \(error)")
            self.error = error as? ReadyDayError ?? .appleSignInFailed
        }

        isLoading = false
    }

    #if DEBUG
    func devBypassSignIn() {
        advance()
    }
    #endif

    func connectWhoop() async {
        isLoading = true
        error = nil

        do {
            try await whoopOAuthManager.startOAuthFlow()
            isWhoopConnected = true
            advance()
        } catch {
            self.error = error as? ReadyDayError ?? .whoopOAuthFailed(underlying: error.localizedDescription)
        }

        isLoading = false
    }

    func skipWhoop() {
        isWhoopConnected = false
        advance()
    }

    func requestCalendarAccess() async {
        isLoading = true
        error = nil

        do {
            let granted = try await calendarService.requestAccess()
            isCalendarGranted = granted

            if granted {
                advance()
            } else {
                self.error = .calendarAccessDenied
            }
        } catch {
            self.error = .calendarAccessDenied
        }

        isLoading = false
    }

    func skipCalendar() {
        isCalendarGranted = false
        advance()
    }

    func completeOnboarding() async {
        isLoading = true

        do {
            // Mark onboarding as completed
            try await userRepository.setOnboardingCompleted()

            // If Whoop is connected, trigger initial data sync
            if isWhoopConnected, let userId = await userRepository.getCurrentUserId() {
                Task {
                    try? await whoopRepository.syncData(userId: userId)
                }
            }

            // Notify ContentView to transition
            NotificationCenter.default.post(name: .onboardingCompleted, object: nil)
        } catch {
            self.error = .unknown(underlying: error.localizedDescription)
        }

        isLoading = false
    }

    func advance() {
        guard let nextStep = OnboardingStep(rawValue: currentStep.rawValue + 1) else { return }
        currentStep = nextStep
    }
}
