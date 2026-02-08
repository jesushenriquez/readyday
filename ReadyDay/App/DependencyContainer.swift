import SwiftUI

@Observable
@MainActor
final class DependencyContainer {

    // MARK: - ViewModels

    let briefingViewModel: BriefingViewModel
    let timelineViewModel: TimelineViewModel
    let dashboardViewModel: DashboardViewModel
    let onboardingViewModel: OnboardingViewModel
    let settingsViewModel: SettingsViewModel
    let workoutFinderViewModel: WorkoutFinderViewModel

    // MARK: - Services

    // TODO: Wire up real implementations in Sprint 1
    // let whoopRepo: any WhoopRepository
    // let calendarRepo: any CalendarRepository
    // let briefingRepo: any BriefingRepository
    // let userRepo: any UserRepository
    // let keychainService: KeychainService
    // let notificationService: NotificationService

    init() {
        // TODO: Initialize services and inject into ViewModels
        self.briefingViewModel = BriefingViewModel()
        self.timelineViewModel = TimelineViewModel()
        self.dashboardViewModel = DashboardViewModel()
        self.onboardingViewModel = OnboardingViewModel()
        self.settingsViewModel = SettingsViewModel()
        self.workoutFinderViewModel = WorkoutFinderViewModel()
    }
}
