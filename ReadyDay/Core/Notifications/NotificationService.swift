import UserNotifications
import Foundation

protocol NotificationServiceProtocol: Sendable {
    func requestAuthorization() async throws -> Bool
    func scheduleMorningBriefing(at time: DateComponents) async throws
    func cancelMorningBriefing() async
    func cancelAllNotifications() async
}

final class NotificationService: NotificationServiceProtocol, @unchecked Sendable {
    private let center = UNUserNotificationCenter.current()

    static let morningBriefingIdentifier = "com.readyday.morningBriefing"

    func requestAuthorization() async throws -> Bool {
        try await center.requestAuthorization(options: [.alert, .badge, .sound])
    }

    func scheduleMorningBriefing(at time: DateComponents) async throws {
        // Cancel any existing morning briefing first
        await cancelMorningBriefing()

        let content = UNMutableNotificationContent()
        content.title = "ReadyDay"
        content.body = "Tu briefing del d\u{00ED}a est\u{00E1} listo"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = time.hour
        dateComponents.minute = time.minute

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: Self.morningBriefingIdentifier,
            content: content,
            trigger: trigger
        )

        try await center.add(request)
    }

    func cancelMorningBriefing() async {
        center.removePendingNotificationRequests(
            withIdentifiers: [Self.morningBriefingIdentifier]
        )
    }

    func cancelAllNotifications() async {
        center.removeAllPendingNotificationRequests()
    }
}
