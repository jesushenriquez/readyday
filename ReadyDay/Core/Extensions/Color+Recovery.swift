import SwiftUI

extension RecoveryZone {

    var color: Color {
        switch self {
        case .green: .rdRecoveryGreen
        case .yellow: .rdRecoveryYellow
        case .red: .rdRecoveryRed
        case .unknown: .rdTextTertiary
        }
    }

    var backgroundColor: Color {
        switch self {
        case .green: .rdRecoveryGreenBg
        case .yellow: .rdRecoveryYellowBg
        case .red: .rdRecoveryRedBg
        case .unknown: .rdSurface
        }
    }

    var iconName: String {
        switch self {
        case .green: "checkmark.seal.fill"
        case .yellow: "exclamationmark.circle.fill"
        case .red: "exclamationmark.triangle.fill"
        case .unknown: "questionmark.circle.fill"
        }
    }
}

extension EnergyDemand {

    var color: Color {
        switch self {
        case .high: .rdRecoveryRed
        case .medium: .rdRecoveryYellow
        case .low: .rdRecoveryGreen
        }
    }

    var label: String {
        switch self {
        case .high: "High"
        case .medium: "Medium"
        case .low: "Low"
        }
    }
}
