import UserNotifications
import Foundation

protocol NotificationServiceProtocol: Sendable {
    func requestAuthorization() async throws -> Bool
    func scheduleMorningBriefing(at time: DateComponents) async throws
    func cancelAllNotifications() async
}

final class NotificationService: NotificationServiceProtocol, @unchecked Sendable {
    private let center = UNUserNotificationCenter.current()

    func requestAuthorization() async throws -> Bool {
        // TODO: Implement in Sprint 2
        try await center.requestAuthorization(options: [.alert, .badge, .sound])
    }

    func scheduleMorningBriefing(at time: DateComponents) async throws {
        // TODO: Implement in Sprint 2
    }

    func cancelAllNotifications() async {
        center.removeAllPendingNotificationRequests()
    }
}
