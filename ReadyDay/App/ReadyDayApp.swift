import SwiftUI

@main
struct ReadyDayApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var container = DependencyContainer()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(container)
        }
    }
}

struct ContentView: View {
    @Environment(DependencyContainer.self) private var container
    @State private var selectedTab: Tab = .today
    @State private var showOnboarding: Bool

    enum Tab: String {
        case today
        case timeline
        case trends
    }

    init() {
        let completed = UserDefaults.standard.bool(forKey: UserDefaultsService.Key.onboardingCompleted)
        _showOnboarding = State(initialValue: !completed)
    }

    var body: some View {
        if showOnboarding {
            OnboardingView(viewModel: container.onboardingViewModel)
                .onReceive(NotificationCenter.default.publisher(for: .onboardingCompleted)) { _ in
                    showOnboarding = false
                }
        } else {
            mainTabView
                .onReceive(NotificationCenter.default.publisher(for: .userDidSignOut)) { _ in
                    showOnboarding = true
                }
                .onReceive(NotificationCenter.default.publisher(for: .navigateToBriefing)) { _ in
                    selectedTab = .today
                }
                .task {
                    await scheduleMorningBriefingIfEnabled()
                }
        }
    }

    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            Tab.today.tab {
                NavigationStack {
                    BriefingView(viewModel: container.briefingViewModel)
                        .navigationTitle("ReadyDay")
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                NavigationLink {
                                    SettingsView(viewModel: container.settingsViewModel)
                                } label: {
                                    Image(systemName: "gearshape")
                                        .foregroundStyle(Color.rdTextSecondary)
                                }
                            }
                        }
                }
            }

            Tab.timeline.tab {
                NavigationStack {
                    TimelineView(viewModel: container.timelineViewModel)
                        .navigationTitle("Timeline")
                }
            }

            Tab.trends.tab {
                NavigationStack {
                    DashboardView(viewModel: container.dashboardViewModel)
                        .navigationTitle("Trends")
                }
            }
        }
        .tint(.rdPrimary)
    }

    private func scheduleMorningBriefingIfEnabled() async {
        let userDefaults = container.userDefaultsService
        let enabled = userDefaults.bool(for: UserDefaultsService.Key.morningBriefingEnabled)
        guard enabled else { return }

        let hour = userDefaults.integer(for: UserDefaultsService.Key.morningBriefingHour)
        let minute = userDefaults.integer(for: UserDefaultsService.Key.morningBriefingMinute)
        let time = DateComponents(hour: hour, minute: minute)
        try? await container.notificationService.scheduleMorningBriefing(at: time)
    }
}

private extension ContentView.Tab {
    @ViewBuilder
    func tab<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .tabItem {
                Label(label, systemImage: iconName)
            }
            .tag(self)
    }

    var label: String {
        switch self {
        case .today: "Today"
        case .timeline: "Timeline"
        case .trends: "Trends"
        }
    }

    var iconName: String {
        switch self {
        case .today: "house.fill"
        case .timeline: "calendar.day.timeline.leading"
        case .trends: "chart.line.uptrend"
        }
    }
}
