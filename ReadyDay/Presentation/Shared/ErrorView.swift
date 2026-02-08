import SwiftUI

struct ErrorView: View {
    let message: String
    var retryAction: (() -> Void)?

    var body: some View {
        VStack(spacing: RDSpacing.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundStyle(Color.rdRecoveryYellow)

            Text("Oops")
                .font(.rdHeadingMedium)
                .foregroundStyle(Color.rdTextPrimary)

            Text(message)
                .font(.rdBodyMedium)
                .foregroundStyle(Color.rdTextSecondary)
                .multilineTextAlignment(.center)

            if let retryAction {
                Button("Try Again") {
                    retryAction()
                }
                .buttonStyle(.rdSecondary)
                .frame(width: 160)
            }
        }
        .padding(RDSpacing.xl)
        .frame(maxWidth: .infinity, minHeight: 200)
    }
}
