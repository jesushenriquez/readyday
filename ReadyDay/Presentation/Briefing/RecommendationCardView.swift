import SwiftUI

struct RecommendationCardView: View {
    let recommendation: Recommendation

    var body: some View {
        HStack(alignment: .top, spacing: RDSpacing.xs) {
            // Priority accent bar
            if recommendation.priority == .high {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.rdRecoveryRed)
                    .frame(width: 3)
            } else if recommendation.priority == .medium {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.rdRecoveryYellow)
                    .frame(width: 3)
            }

            Image(systemName: recommendation.type.iconName)
                .font(.system(size: 20))
                .foregroundStyle(iconColor)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: RDSpacing.xxxs) {
                Text(recommendation.title)
                    .font(.rdHeadingSmall)
                    .foregroundStyle(Color.rdTextPrimary)

                Text(recommendation.body)
                    .font(.rdBodyMedium)
                    .foregroundStyle(Color.rdTextSecondary)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(RDSpacing.sm)
        .background(Color.rdSurface)
        .clipShape(RoundedRectangle(cornerRadius: RDRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: RDRadius.md)
                .stroke(Color.rdBorder, lineWidth: 1)
        )
    }

    private var iconColor: Color {
        switch recommendation.type {
        case .warning: .rdRecoveryRed
        case .positive: .rdRecoveryGreen
        case .workout: .rdPrimary
        case .sleep: .rdPrimary
        case .calendar: .rdAccent
        case .info: .rdAccent
        }
    }
}
