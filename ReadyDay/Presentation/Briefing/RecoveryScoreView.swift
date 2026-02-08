import SwiftUI

struct RecoveryScoreView: View {
    let score: Int
    let zone: RecoveryZone

    var body: some View {
        HStack(spacing: RDSpacing.lg) {
            // Recovery ring
            ZStack {
                Circle()
                    .stroke(zone.color.opacity(0.2), lineWidth: 8)

                Circle()
                    .trim(from: 0, to: CGFloat(score) / 100)
                    .stroke(zone.color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                Text("\(score)")
                    .font(.rdDataLarge)
                    .foregroundStyle(zone.color)
            }
            .frame(width: 96, height: 96)

            VStack(alignment: .leading, spacing: RDSpacing.xxs) {
                Text(Date.now.greeting)
                    .font(.rdHeadingMedium)
                    .foregroundStyle(Color.rdTextPrimary)

                Text("Tu recovery es \(zone.label)")
                    .font(.rdBodyMedium)
                    .foregroundStyle(Color.rdTextSecondary)

                HStack(spacing: RDSpacing.xxs) {
                    Image(systemName: zone.iconName)
                        .foregroundStyle(zone.color)
                    Text(zone.label)
                        .font(.rdCaptionLarge)
                        .foregroundStyle(zone.color)
                }
            }
        }
        .padding(RDSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(zone.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: RDRadius.xl))
    }
}
