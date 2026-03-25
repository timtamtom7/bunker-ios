import SwiftUI

@MainActor struct ContentView: View {
    @State private var selectedTab = 0
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        Group {
            if horizontalSizeClass == .regular {
                // iPad: Use NavigationSplitView for larger screens
                iPadLayout
            } else {
                // iPhone: Standard TabView
                TabView(selection: $selectedTab) {
                    DecisionListView()
                        .tabItem {
                            Label("Decisions", systemImage: "rectangle.stack.fill")
                        }
                        .tag(0)

                    OutcomeHistoryView()
                        .tabItem {
                            Label("Outcomes", systemImage: "chart.bar.fill")
                        }
                        .tag(1)

                    SettingsView()
                        .tabItem {
                            Label("Settings", systemImage: "gearshape.fill")
                        }
                        .tag(2)
                }
                .tint(Color.bunkerPrimary)
            }
        }
    }

    // MARK: - iPad Layout

    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var selectedDecision: Decision?
    @State private var selectedOutcome: Outcome?

    private var iPadLayout: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // Sidebar
            List {
                Section("Workspace") {
                    Button {
                        selectedTab = 0
                    } label: {
                        Label("Decisions", systemImage: "rectangle.stack.fill")
                    }
                    .listRowBackground(selectedTab == 0 ? Color.bunkerPrimary.opacity(0.2) : Color.clear)

                    Button {
                        selectedTab = 1
                    } label: {
                        Label("Outcomes", systemImage: "chart.bar.fill")
                    }
                    .listRowBackground(selectedTab == 1 ? Color.bunkerPrimary.opacity(0.2) : Color.clear)

                    Button {
                        selectedTab = 2
                    } label: {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                    .listRowBackground(selectedTab == 2 ? Color.bunkerPrimary.opacity(0.2) : Color.clear)
                }

                Section("Quick Access") {
                    NavigationLink(destination: DecisionStatsView()) {
                        Label("Statistics", systemImage: "chart.pie.fill")
                    }
                    NavigationLink(destination: TemplatesView()) {
                        Label("Templates", systemImage: "doc.on-doc.fill")
                    }
                    NavigationLink(destination: GroupsView()) {
                        Label("Groups", systemImage: "folder.fill")
                    }
                    NavigationLink(destination: AchievementsView()) {
                        Label("Achievements", systemImage: "medal.fill")
                    }
                }

                Section("Tools") {
                    NavigationLink(destination: AnalyticsDashboardView()) {
                        Label("Analytics", systemImage: "chart.bar.xaxis")
                    }
                    NavigationLink(destination: OnboardingView()) {
                        Label("Onboarding", systemImage: "questionmark.circle")
                    }
                }
            }
            .navigationTitle("Bunker")
        } detail: {
            // Detail view based on selected tab
            switch selectedTab {
            case 0:
                DecisionListView()
            case 1:
                OutcomeHistoryView()
            case 2:
                SettingsView()
            default:
                DecisionListView()
            }
        }
        .tint(Color.bunkerPrimary)
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
