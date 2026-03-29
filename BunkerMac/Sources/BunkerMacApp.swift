import SwiftUI

@main
struct BunkerMacApp: App {
    var body: some Scene {
        WindowGroup {
            MacContentView()
                .preferredColorScheme(.dark)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Decision") {
                    NotificationCenter.default.post(name: .newDecision, object: nil)
                }
                .keyboardShortcut("n", modifiers: .command)
            }
        }
    }
}

extension Notification.Name {
    static let newDecision = Notification.Name("newDecision")
}
