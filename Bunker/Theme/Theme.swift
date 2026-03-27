import SwiftUI
import UIKit

// MARK: - iOS 26 Liquid Glass Design System
// Theme tokens for consistent iOS 26 Liquid Glass design language

enum Theme {
    
    // MARK: - Corner Radius Tokens (iOS 26 Liquid Glass)
    enum CornerRadius {
        /// Extra small - 6pt (minimum touch target rounding)
        static let xs: CGFloat = 6
        /// Small - 10pt (compact elements)
        static let sm: CGFloat = 10
        /// Medium - 14pt (standard cards, buttons)
        static let md: CGFloat = 14
        /// Large - 20pt (prominent cards)
        static let lg: CGFloat = 20
        /// Extra large - 28pt (modal sheets, floating panels)
        static let xl: CGFloat = 28
        /// Full liquid glass pill - 40pt
        static let pill: CGFloat = 40
    }
    
    // MARK: - Font Tokens (iOS 26 Liquid Glass - Minimum 11pt)
    enum Typography {
        /// Display - 34pt Bold
        static let display = Font.system(size: 34, weight: .bold, design: .default)
        /// Title Large - 28pt Semibold
        static let titleLarge = Font.system(size: 28, weight: .semibold, design: .default)
        /// Title Medium - 22pt Semibold
        static let titleMedium = Font.system(size: 22, weight: .semibold, design: .default)
        /// Title Small - 20pt Semibold
        static let titleSmall = Font.system(size: 20, weight: .semibold, design: .default)
        /// Body Large - 17pt Regular
        static let bodyLarge = Font.system(size: 17, weight: .regular, design: .default)
        /// Body Medium - 15pt Regular
        static let bodyMedium = Font.system(size: 15, weight: .regular, design: .default)
        /// Body Small - 14pt Regular (minimum for secondary text)
        static let bodySmall = Font.system(size: 14, weight: .regular, design: .default)
        /// Caption - 12pt Medium (minimum for labels)
        static let caption = Font.system(size: 12, weight: .medium, design: .default)
        /// Caption Small - 11pt Medium (absolute minimum per iOS 26)
        static let captionSmall = Font.system(size: 11, weight: .medium, design: .default)
    }
    
    // MARK: - Spacing Tokens
    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // MARK: - Shadow Tokens (Liquid Glass effect)
    enum Shadow {
        static let subtle = (color: Color.black.opacity(0.08), radius: CGFloat(8), x: CGFloat(0), y: CGFloat(2))
        static let medium = (color: Color.black.opacity(0.12), radius: CGFloat(16), x: CGFloat(0), y: CGFloat(4))
        static let prominent = (color: Color.black.opacity(0.16), radius: CGFloat(24), x: CGFloat(0), y: CGFloat(8))
    }
}

// MARK: - Haptic Feedback (iOS 26 Liquid Glass interactions)
@MainActor
enum HapticFeedback {
    /// Light impact for subtle interactions (toggles, selections)
    static func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Medium impact for standard button presses
    static func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Heavy impact for significant actions (deletions, confirmations)
    static func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Soft impact for liquid glass touch feel
    static func soft() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Rigid impact for precise interactions
    static func rigid() {
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Success notification feedback
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
    
    /// Warning notification feedback
    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
    }
    
    /// Error notification feedback
    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
    }
    
    /// Selection changed feedback
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
}

// MARK: - Button Styles (iOS 26 Liquid Glass)
struct LiquidGlassButtonStyle: ButtonStyle {
    let isPrimary: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm)
            .background(
                isPrimary 
                    ? Color.bunkerPrimary 
                    : Color.bunkerSurface
            )
            .foregroundStyle(
                isPrimary 
                    ? Color.white 
                    : Color.bunkerTextPrimary
            )
            .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.md))
            .shadow(
                color: Color.black.opacity(configuration.isPressed ? 0.0 : 0.08),
                radius: configuration.isPressed ? 2 : 6,
                x: 0,
                y: configuration.isPressed ? 1 : 3
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct LiquidGlassIconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(Theme.Spacing.xs)
            .background(
                Color.bunkerSurface.opacity(configuration.isPressed ? 0.8 : 0.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.sm))
            .scaleEffect(configuration.isPressed ? 0.93 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct LiquidGlassCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                    .fill(Color.bunkerSurfaceCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                            .stroke(Color.bunkerPrimary.opacity(configuration.isPressed ? 0.4 : 0.0), lineWidth: 1)
                    )
            )
            .shadow(
                color: Color.black.opacity(configuration.isPressed ? 0.04 : 0.08),
                radius: configuration.isPressed ? 4 : 12,
                x: 0,
                y: configuration.isPressed ? 2 : 4
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == LiquidGlassButtonStyle {
    static var liquidGlass: LiquidGlassButtonStyle { LiquidGlassButtonStyle(isPrimary: false) }
    static var liquidGlassPrimary: LiquidGlassButtonStyle { LiquidGlassButtonStyle(isPrimary: true) }
}

// MARK: - Accessibility Helpers
extension View {
    /// Adds accessibility label with haptic feedback capability tracking
    func accessibleButton(label: String, hint: String? = nil) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(.isButton)
    }
    
    /// Adds accessibility label for interactive controls
    func accessibleControl(label: String, hint: String? = nil) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
    }
}
