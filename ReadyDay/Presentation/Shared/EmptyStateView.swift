import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: RDSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(Color.rdTextTertiary)
                .symbolRenderingMode(.hierarchical)

            Text(title)
                .font(.rdHeadingMedium)
                .foregroundStyle(Color.rdTextPrimary)

            Text(message)
                .font(.rdBodyMedium)
                .foregroundStyle(Color.rdTextSecondary)
                .multilineTextAlignment(.center)

            if let actionTitle, let action {
                Button(actionTitle) { action() }
                    .buttonStyle(.rdPrimary)
                    .frame(width: 200)
                    .padding(.top, RDSpacing.xxs)
            }
        }
        .padding(RDSpacing.xl)
        .frame(maxWidth: .infinity, minHeight: 250)
    }
}
