import EventKit
import Foundation

enum CalendarPermissionStatus: Sendable {
    case notDetermined
    case authorized
    case denied
    case restricted

    static var current: CalendarPermissionStatus {
        switch EKEventStore.authorizationStatus(for: .event) {
        case .notDetermined:
            return .notDetermined
        case .fullAccess, .writeOnly:
            return .authorized
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        @unknown default:
            return .notDetermined
        }
    }

    var isGranted: Bool {
        self == .authorized
    }
}
