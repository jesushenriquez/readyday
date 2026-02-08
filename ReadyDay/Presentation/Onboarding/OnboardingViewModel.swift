import Foundation

@Observable
@MainActor
final class OnboardingViewModel {

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

    // MARK: - Actions

    func signInWithApple() async {
        // TODO: Implement Apple Sign In in Sprint 1
    }

    func connectWhoop() async {
        // TODO: Implement Whoop OAuth in Sprint 1
    }

    func skipWhoop() {
        currentStep = .calendarAccess
    }

    func requestCalendarAccess() async {
        // TODO: Implement calendar permission request in Sprint 1
    }

    func completeOnboarding() async {
        // TODO: Mark onboarding as completed
    }

    func advance() {
        guard let nextStep = OnboardingStep(rawValue: currentStep.rawValue + 1) else { return }
        currentStep = nextStep
    }
}
