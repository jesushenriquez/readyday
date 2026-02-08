import SwiftUI

struct SettingsView: View {
    let viewModel: SettingsViewModel

    var body: some View {
        List {
            Section("Connections") {
                HStack {
                    Image(systemName: "link.circle.fill")
                        .foregroundStyle(Color.rdPrimary)
                    Text("Whoop")
                    Spacer()
                    Text(viewModel.isWhoopConnected ? "Connected" : "Not connected")
                        .font(.rdCaptionLarge)
                        .foregroundStyle(Color.rdTextSecondary)
                }

                HStack {
                    Image(systemName: "calendar")
                        .foregroundStyle(Color.rdPrimary)
                    Text("Calendar")
                    Spacer()
                    Text(viewModel.isCalendarGranted ? "Granted" : "Not granted")
                        .font(.rdCaptionLarge)
                        .foregroundStyle(Color.rdTextSecondary)
                }
            }

            Section("Notifications") {
                Toggle("Morning Briefing", isOn: Binding(
                    get: { viewModel.morningBriefingEnabled },
                    set: { viewModel.toggleMorningBriefing($0) }
                ))
                .tint(.rdPrimary)

                Toggle("Pre-meeting Alerts", isOn: Binding(
                    get: { viewModel.preMeetingAlertsEnabled },
                    set: { viewModel.togglePreMeetingAlerts($0) }
                ))
                .tint(.rdPrimary)
            }

            Section("About") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(viewModel.appVersion)
                        .foregroundStyle(Color.rdTextSecondary)
                }
            }

            Section {
                Button("Delete Account") {
                    Task { await viewModel.deleteAccount() }
                }
                .foregroundStyle(Color.rdRecoveryRed)
            }
        }
        .navigationTitle("Settings")
        .task { await viewModel.loadSettings() }
    }
}
