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

    enum Tab: String {
        case today
        case timeline
        case trends
    }

    var body: some View {
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
