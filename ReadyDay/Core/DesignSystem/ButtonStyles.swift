import SwiftUI

struct RDPrimaryButtonStyle: ButtonStyle {
    @MainActor
    func makeBody(configuration: ButtonStyleConfiguration) -> some View {
        configuration.label
            .font(.rdHeadingSmall)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(Color.rdPrimary)
            .clipShape(RoundedRectangle(cornerRadius: RDRadius.md))
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.rdSnap, value: configuration.isPressed)
    }
}

struct RDSecondaryButtonStyle: ButtonStyle {
    @MainActor
    func makeBody(configuration: ButtonStyleConfiguration) -> some View {
        configuration.label
            .font(.rdHeadingSmall)
            .foregroundStyle(Color.rdPrimary)
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(Color.rdPrimaryLight)
            .clipShape(RoundedRectangle(cornerRadius: RDRadius.md))
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.rdSnap, value: configuration.isPressed)
    }
}

struct RDTertiaryButtonStyle: ButtonStyle {
    @MainActor
    func makeBody(configuration: ButtonStyleConfiguration) -> some View {
        configuration.label
            .font(.rdBodyMedium)
            .foregroundStyle(Color.rdPrimary)
            .opacity(configuration.isPressed ? 0.6 : 1.0)
            .animation(.rdSnap, value: configuration.isPressed)
    }
}

struct RDDestructiveButtonStyle: ButtonStyle {
    @MainActor
    func makeBody(configuration: ButtonStyleConfiguration) -> some View {
        configuration.label
            .font(.rdHeadingSmall)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(Color.rdRecoveryRed)
            .clipShape(RoundedRectangle(cornerRadius: RDRadius.md))
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.rdSnap, value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == RDPrimaryButtonStyle {
    static var rdPrimary: RDPrimaryButtonStyle { RDPrimaryButtonStyle() }
}

extension ButtonStyle where Self == RDSecondaryButtonStyle {
    static var rdSecondary: RDSecondaryButtonStyle { RDSecondaryButtonStyle() }
}

extension ButtonStyle where Self == RDTertiaryButtonStyle {
    static var rdTertiary: RDTertiaryButtonStyle { RDTertiaryButtonStyle() }
}

extension ButtonStyle where Self == RDDestructiveButtonStyle {
    static var rdDestructive: RDDestructiveButtonStyle { RDDestructiveButtonStyle() }
}
