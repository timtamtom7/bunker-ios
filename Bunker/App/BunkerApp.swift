import SwiftUI
import UserNotifications

@main
struct BunkerApp: App {
    init() {
        requestNotificationPermission()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
}

// MARK: - Color Extensions
extension Color {
    // Primary palette
    static let bunkerPrimary = Color(hex: "4A90D9")
    static let bunkerSecondary = Color(hex: "2D3748")
    static let bunkerAccent = Color(hex: "38B2AC")

    // Backgrounds
    static let bunkerBackground = Color(hex: "1E2530")
    static let bunkerSurface = Color(hex: "283040")
    static let bunkerSurfaceCard = Color(hex: "2F3B4A")

    // Text
    static let bunkerTextPrimary = Color(hex: "F0F4F8")
    static let bunkerTextSecondary = Color(hex: "A0AEC0")
    static let bunkerTextTertiary = Color(hex: "718096")

    // Semantic
    static let bunkerError = Color(hex: "FC8181")
    static let bunkerSuccess = Color(hex: "68D391")
    static let bunkerWarning = Color(hex: "F6AD55")
    static let bunkerDivider = Color(hex: "3D4A5C")

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Font Extensions
extension Font {
    static let bunkerDisplay = Font.system(size: 34, weight: .bold, design: .default)
    static let bunkerHeading1 = Font.system(size: 28, weight: .semibold, design: .default)
    static let bunkerHeading2 = Font.system(size: 22, weight: .medium, design: .default)
    static let bunkerHeading3 = Font.system(size: 18, weight: .semibold, design: .default)
    static let bunkerBody = Font.system(size: 17, weight: .regular, design: .default)
    static let bunkerBodySmall = Font.system(size: 15, weight: .regular, design: .default)
    static let bunkerCaption = Font.system(size: 13, weight: .regular, design: .default)
    static let bunkerLabel = Font.system(size: 12, weight: .medium, design: .default)
}

// MARK: - Spacing
enum Spacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}
