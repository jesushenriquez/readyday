import SwiftUI

@main
struct ReadyDayApp: App {
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
        // Check if onboarding is completed
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
        }
    }

    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            Tab.today.tab {
                NavigationStack {
                    BriefingView(viewModel: container.briefingViewModel)
                        .navigationTitle("ReadyDay")
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
