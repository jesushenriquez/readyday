import SwiftUI

struct TimelineEventBlock: View {
    let event: ClassifiedEvent

    var body: some View {
        HStack(spacing: RDSpacing.xs) {
            // Demand accent bar
            RoundedRectangle(cornerRadius: 2)
                .fill(event.demand.color)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: RDSpacing.xxxs) {
                HStack(spacing: RDSpacing.xxxs) {
                    Circle()
                        .fill(event.demand.color)
                        .frame(width: 8, height: 8)

                    Text(event.title)
                        .font(.rdHeadingSmall)
                        .foregroundStyle(Color.rdTextPrimary)
                        .lineLimit(1)
                }

                Text("\(event.startDate.hourAndMinute) - \(event.endDate.hourAndMinute)")
                    .font(.rdCaptionLarge)
                    .foregroundStyle(Color.rdTextSecondary)
            }

            Spacer()

            Text(event.demand.label)
                .font(.rdCaptionSmall)
                .foregroundStyle(event.demand.color)
                .padding(.horizontal, RDSpacing.xxs)
                .padding(.vertical, RDSpacing.xxxs)
                .background(event.demand.color.opacity(0.1))
                .clipShape(Capsule())
        }
        .padding(RDSpacing.sm)
        .background(Color.rdSurface)
        .clipShape(RoundedRectangle(cornerRadius: RDRadius.md))
    }
}
