import SwiftUI

extension Color {

    // MARK: - Brand

    static let rdPrimary = Color("Primary")
    static let rdPrimaryLight = Color("PrimaryLight")
    static let rdAccent = Color("Accent")

    // MARK: - Recovery Zones

    static let rdRecoveryGreen = Color("RecoveryGreen")
    static let rdRecoveryYellow = Color("RecoveryYellow")
    static let rdRecoveryRed = Color("RecoveryRed")
    static let rdRecoveryGreenBg = Color("RecoveryGreenBg")
    static let rdRecoveryYellowBg = Color("RecoveryYellowBg")
    static let rdRecoveryRedBg = Color("RecoveryRedBg")

    // MARK: - Surfaces

    static let rdBackground = Color("Background")
    static let rdSurface = Color("Surface")
    static let rdSurfaceElevated = Color("SurfaceElevated")

    // MARK: - Text

    static let rdTextPrimary = Color("TextPrimary")
    static let rdTextSecondary = Color("TextSecondary")
    static let rdTextTertiary = Color("TextTertiary")

    // MARK: - Utility

    static let rdBorder = Color("Border")
    static let rdShadow = Color.black.opacity(0.08)
}
