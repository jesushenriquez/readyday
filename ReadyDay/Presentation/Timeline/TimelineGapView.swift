import SwiftUI

struct TimelineGapView: View {
    let window: TimeWindow
    let suggestion: String?

    var body: some View {
        HStack(spacing: RDSpacing.xs) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 16))
                .foregroundStyle(Color.rdPrimary)

            VStack(alignment: .leading, spacing: RDSpacing.xxxs) {
                Text("Free: \(window.durationMinutes) min")
                    .font(.rdBodySmall)
                    .foregroundStyle(Color.rdPrimary)

                if let suggestion {
                    Text(suggestion)
                        .font(.rdCaptionLarge)
                        .foregroundStyle(Color.rdTextSecondary)
                }
            }

            Spacer()
        }
        .padding(RDSpacing.xs)
        .background(Color.rdPrimaryLight)
        .clipShape(RoundedRectangle(cornerRadius: RDRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: RDRadius.md)
                .strokeBorder(Color.rdPrimary.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [4]))
        )
    }
}
