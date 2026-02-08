import SwiftUI
import Charts

struct TrendChartView: View {
    let data: [RecoveryData]

    var body: some View {
        VStack(alignment: .leading, spacing: RDSpacing.sm) {
            Text("Recovery")
                .font(.rdHeadingMedium)
                .foregroundStyle(Color.rdTextPrimary)

            Chart {
                ForEach(Array(data.enumerated()), id: \.offset) { index, recovery in
                    if let score = recovery.recoveryScore {
                        LineMark(
                            x: .value("Day", recovery.recordedAt, unit: .day),
                            y: .value("Score", score)
                        )
                        .foregroundStyle(Color.rdPrimary)
                        .lineStyle(StrokeStyle(lineWidth: 2.5))

                        PointMark(
                            x: .value("Day", recovery.recordedAt, unit: .day),
                            y: .value("Score", score)
                        )
                        .foregroundStyle(Color.rdPrimary)
                        .symbolSize(36)
                    }
                }

                // Zone bands
                RectangleMark(yStart: .value("", 0), yEnd: .value("", 33))
                    .foregroundStyle(Color.rdRecoveryRedBg.opacity(0.3))
                RectangleMark(yStart: .value("", 34), yEnd: .value("", 66))
                    .foregroundStyle(Color.rdRecoveryYellowBg.opacity(0.3))
                RectangleMark(yStart: .value("", 67), yEnd: .value("", 100))
                    .foregroundStyle(Color.rdRecoveryGreenBg.opacity(0.3))
            }
            .chartYScale(domain: 0...100)
            .chartYAxis {
                AxisMarks(position: .trailing)
            }
            .frame(height: 200)
        }
        .padding(RDSpacing.md)
        .background(Color.rdSurface)
        .clipShape(RoundedRectangle(cornerRadius: RDRadius.xl))
    }
}
