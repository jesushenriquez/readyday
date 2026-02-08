import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack(spacing: RDSpacing.sm) {
            ProgressView()
                .tint(.rdPrimary)

            Text("Loading...")
                .font(.rdBodyMedium)
                .foregroundStyle(Color.rdTextSecondary)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
    }
}
