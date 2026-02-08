import SwiftUI

struct SleepSummaryView: View {
    let summary: SleepSummary

    var body: some View {
        VStack(alignment: .leading, spacing: RDSpacing.sm) {
            Text("Sueno anoche")
                .font(.rdHeadingMedium)
                .foregroundStyle(Color.rdTextPrimary)

            HStack {
                Text(summary.formattedDuration)
                    .font(.rdDataMedium)
                    .foregroundStyle(Color.rdTextPrimary)

                Spacer()

                if let efficiency = summary.efficiency {
                    HStack(spacing: RDSpacing.xxs) {
                        ProgressView(value: efficiency)
                            .tint(.rdPrimary)
                            .frame(width: 80)

                        Text("\(Int(efficiency * 100))%")
                            .font(.rdDataSmall)
                            .foregroundStyle(Color.rdTextSecondary)
                    }
                }
            }

            if let stages = summary.stages {
                HStack(spacing: RDSpacing.sm) {
                    stagePill(label: "Deep", value: formatHours(stages.deepHours), color: .rdPrimary)
                    stagePill(label: "REM", value: formatHours(stages.remHours), color: .rdPrimary.opacity(0.7))
                    stagePill(label: "Light", value: formatHours(stages.lightHours), color: .rdPrimary.opacity(0.4))
                    stagePill(label: "Awake", value: formatHours(stages.wakeHours), color: .rdTextTertiary)
                }
            }
        }
        .padding(RDSpacing.md)
        .background(Color.rdSurface)
        .clipShape(RoundedRectangle(cornerRadius: RDRadius.xl))
    }

    private func stagePill(label: String, value: String, color: Color) -> some View {
        VStack(spacing: RDSpacing.xxxs) {
            Text(label)
                .font(.rdCaptionLarge)
                .foregroundStyle(Color.rdTextTertiary)
            Text(value)
                .font(.rdBodyMedium)
                .fontWeight(.semibold)
                .foregroundStyle(Color.rdTextPrimary)
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(height: 4)
        }
        .frame(maxWidth: .infinity)
    }

    private func formatHours(_ hours: Double) -> String {
        let h = Int(hours)
        let m = Int((hours - Double(h)) * 60)
        return h > 0 ? "\(h)h\(m)m" : "\(m)m"
    }
}
