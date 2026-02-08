import SwiftUI

struct RecoveryColorView: View {
    let zone: RecoveryZone
    let size: CGFloat

    init(zone: RecoveryZone, size: CGFloat = 8) {
        self.zone = zone
        self.size = size
    }

    var body: some View {
        HStack(spacing: RDSpacing.xxxs) {
            Circle()
                .fill(zone.color)
                .frame(width: size, height: size)

            Text(zone.label)
                .font(.rdCaptionLarge)
                .foregroundStyle(zone.color)
        }
        .accessibilityLabel("Recovery zone: \(zone.label)")
    }
}
