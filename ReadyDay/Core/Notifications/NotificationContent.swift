import UserNotifications
import Foundation

enum NotificationContent {

    static func morningBriefing(recoveryScore: Int, zone: RecoveryZone, topRecommendation: String) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Buenos dias — Recovery \(recoveryScore)%"
        content.body = topRecommendation
        content.sound = .default
        content.categoryIdentifier = "MORNING_BRIEFING"
        return content
    }

    static func preMeetingAlert(eventTitle: String, demand: EnergyDemand) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Proxima reunion: \(eventTitle)"
        content.body = demand == .high
            ? "Reunion de alta demanda. Toma un momento para prepararte."
            : "Reunion en 15 minutos."
        content.sound = .default
        content.categoryIdentifier = "PRE_MEETING"
        return content
    }
}
