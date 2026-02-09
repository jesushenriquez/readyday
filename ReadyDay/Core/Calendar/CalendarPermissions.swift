import EventKit
import Foundation

enum CalendarPermissionStatus: Sendable {
    case notDetermined
    case fullAccess
    case writeOnly
    case denied
    case restricted

    static var current: CalendarPermissionStatus {
        switch EKEventStore.authorizationStatus(for: .event) {
        case .notDetermined:
            return .notDetermined
        case .fullAccess:
            return .fullAccess
        case .writeOnly:
            return .writeOnly
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        @unknown default:
            return .notDetermined
        }
    }

    var canReadEvents: Bool {
        self == .fullAccess
    }

    var isGranted: Bool {
        self == .fullAccess || self == .writeOnly
    }
}
