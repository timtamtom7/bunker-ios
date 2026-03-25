import SwiftUI

@MainActor
struct SettingsView: View {
    @AppStorage("colorScheme") private var colorScheme: String = "dark"

    var body: some View {
        NavigationStack {
            List {
                Section("Appearance") {
                    Picker("Theme", selection: $colorScheme) {
                        Text("Dark").tag("dark")
                        Text("Light").tag("light")
                        Text("System").tag("system")
                    }
                    .pickerStyle(.menu)
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(Color.bunkerTextTertiary)
                    }

                    HStack {
                        Text("Build")
                        Spacer()
                        Text("R4")
                            .foregroundStyle(Color.bunkerTextTertiary)
                    }
                }

                Section {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Bunker")
                            .font(.bunkerHeading3)
                            .foregroundStyle(Color.bunkerTextPrimary)

                        Text("AI-powered decision workspace.\nMap decisions, weigh criteria, simulate outcomes.")
                            .font(.bunkerCaption)
                            .foregroundStyle(Color.bunkerTextSecondary)
                    }
                    .padding(.vertical, Spacing.xs)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
        .preferredColorScheme(.dark)
}
