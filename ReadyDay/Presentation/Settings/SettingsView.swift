import SwiftUI

struct SettingsView: View {
    @Bindable var viewModel: SettingsViewModel

    var body: some View {
        List {
            Section("Connections") {
                HStack {
                    Image(systemName: "link.circle.fill")
                        .foregroundStyle(Color.rdPrimary)
                    Text("Whoop")
                    Spacer()
                    if viewModel.isWhoopConnected {
                        Button("Disconnect") {
                            Task { await viewModel.disconnectWhoop() }
                        }
                        .font(.rdCaptionLarge)
                        .foregroundStyle(Color.rdRecoveryRed)
                    } else {
                        Text("Not connected")
                            .font(.rdCaptionLarge)
                            .foregroundStyle(Color.rdTextSecondary)
                    }
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

                if viewModel.morningBriefingEnabled {
                    DatePicker(
                        "Briefing Time",
                        selection: $viewModel.morningBriefingDate,
                        displayedComponents: .hourAndMinute
                    )
                    .tint(.rdPrimary)
                }

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
                Button("Sign Out") {
                    viewModel.showSignOutConfirmation = true
                }
                .foregroundStyle(Color.rdPrimary)
            }

            Section {
                Button("Delete Account") {
                    viewModel.showDeleteConfirmation = true
                }
                .foregroundStyle(Color.rdRecoveryRed)
            }
        }
        .navigationTitle("Settings")
        .task { await viewModel.loadSettings() }
        .alert("Sign Out", isPresented: $viewModel.showSignOutConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out", role: .destructive) {
                Task { await viewModel.signOut() }
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .alert("Delete Account", isPresented: $viewModel.showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task { await viewModel.deleteAccount() }
            }
        } message: {
            Text("This will permanently delete your account and all data. This action cannot be undone.")
        }
    }
}
