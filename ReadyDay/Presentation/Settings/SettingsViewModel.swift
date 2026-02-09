import Foundation

@Observable
@MainActor
final class SettingsViewModel {

    // MARK: - Dependencies

    private let notificationService: NotificationServiceProtocol
    private let userDefaults: UserDefaultsServiceProtocol
    private let whoopOAuthManager: WhoopOAuthManager
    private let calendarService: CalendarServiceProtocol
    private let authManager: AuthManager
    private let userRepository: UserRepository

    // MARK: - State

    private(set) var isWhoopConnected = false
    private(set) var isCalendarGranted = false
    private(set) var morningBriefingEnabled = true
    private(set) var preMeetingAlertsEnabled = true
    private(set) var appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"

    var morningBriefingTime = DateComponents(hour: 7, minute: 30)
    var showDeleteConfirmation = false
    var showSignOutConfirmation = false

    var morningBriefingDate: Date {
        get {
            Calendar.current.date(
                from: DateComponents(
                    hour: morningBriefingTime.hour ?? 7,
                    minute: morningBriefingTime.minute ?? 30
                )
            ) ?? Date()
        }
        set {
            let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
            morningBriefingTime = components
            updateMorningBriefingTime(components)
        }
    }

    // MARK: - Initialization

    init(
        notificationService: NotificationServiceProtocol,
        userDefaults: UserDefaultsServiceProtocol,
        whoopOAuthManager: WhoopOAuthManager,
        calendarService: CalendarServiceProtocol,
        authManager: AuthManager,
        userRepository: UserRepository
    ) {
        self.notificationService = notificationService
        self.userDefaults = userDefaults
        self.whoopOAuthManager = whoopOAuthManager
        self.calendarService = calendarService
        self.authManager = authManager
        self.userRepository = userRepository
    }

    // MARK: - Actions

    func loadSettings() async {
        morningBriefingEnabled = userDefaults.bool(for: UserDefaultsService.Key.morningBriefingEnabled)
        preMeetingAlertsEnabled = userDefaults.bool(for: UserDefaultsService.Key.preMeetingAlertsEnabled)

        let hour = userDefaults.integer(for: UserDefaultsService.Key.morningBriefingHour)
        let minute = userDefaults.integer(for: UserDefaultsService.Key.morningBriefingMinute)
        morningBriefingTime = DateComponents(hour: hour, minute: minute)

        isWhoopConnected = await whoopOAuthManager.isConnected()
        isCalendarGranted = CalendarPermissionStatus.current == .fullAccess
    }

    func toggleMorningBriefing(_ enabled: Bool) {
        morningBriefingEnabled = enabled
        userDefaults.set(enabled, for: UserDefaultsService.Key.morningBriefingEnabled)
        Task {
            if enabled {
                try? await notificationService.scheduleMorningBriefing(at: morningBriefingTime)
            } else {
                await notificationService.cancelMorningBriefing()
            }
        }
    }

    func togglePreMeetingAlerts(_ enabled: Bool) {
        preMeetingAlertsEnabled = enabled
        userDefaults.set(enabled, for: UserDefaultsService.Key.preMeetingAlertsEnabled)
    }

    func updateMorningBriefingTime(_ time: DateComponents) {
        userDefaults.set(time.hour ?? 7, for: UserDefaultsService.Key.morningBriefingHour)
        userDefaults.set(time.minute ?? 30, for: UserDefaultsService.Key.morningBriefingMinute)
        if morningBriefingEnabled {
            Task {
                try? await notificationService.scheduleMorningBriefing(at: time)
            }
        }
    }

    func disconnectWhoop() async {
        do {
            try await whoopOAuthManager.disconnect()
            isWhoopConnected = false
        } catch {
            print("[Settings] Failed to disconnect Whoop: \(error.localizedDescription)")
        }
    }

    func signOut() async {
        do {
            try await authManager.signOut()
            userDefaults.set(false, for: UserDefaultsService.Key.onboardingCompleted)
            NotificationCenter.default.post(name: .userDidSignOut, object: nil)
        } catch {
            print("[Settings] Failed to sign out: \(error.localizedDescription)")
        }
    }

    func deleteAccount() async {
        // TODO: Server-side deletion via Supabase Edge Function
        await notificationService.cancelAllNotifications()
        userDefaults.removeAll()
        await signOut()
    }
}
