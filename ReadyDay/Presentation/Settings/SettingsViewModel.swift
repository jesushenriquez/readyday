import Foundation

@Observable
@MainActor
final class SettingsViewModel {

    // MARK: - State

    private(set) var isWhoopConnected = false
    private(set) var isCalendarGranted = false
    private(set) var morningBriefingEnabled = true
    private(set) var preMeetingAlertsEnabled = true
    private(set) var appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"

    // MARK: - Actions

    func loadSettings() async {
        // TODO: Implement in Sprint 2
    }

    func disconnectWhoop() async {
        // TODO: Implement in Sprint 1
    }

    func toggleMorningBriefing(_ enabled: Bool) {
        morningBriefingEnabled = enabled
        // TODO: Persist and update notification schedule
    }

    func togglePreMeetingAlerts(_ enabled: Bool) {
        preMeetingAlertsEnabled = enabled
        // TODO: Persist and update notification schedule
    }

    func deleteAccount() async {
        // TODO: Implement account deletion
    }
}
