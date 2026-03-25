import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
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

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
