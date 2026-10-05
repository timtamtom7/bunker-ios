import Foundation

/// R5: Onboarding service for guided first decision
final class OnboardingService: @unchecked Sendable {
    static let shared = OnboardingService()

    private let hasCompletedOnboardingKey = "bunker_has_completed_onboarding"
    private let onboardingStepKey = "bunker_onboarding_step"

    private init() {}

    var hasCompletedOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: hasCompletedOnboardingKey) }
        set { UserDefaults.standard.set(newValue, forKey: hasCompletedOnboardingKey) }
    }

    var currentStep: Int {
        get { UserDefaults.standard.integer(forKey: onboardingStepKey) }
        set { UserDefaults.standard.set(newValue, forKey: onboardingStepKey) }
    }

    func reset() {
        hasCompletedOnboarding = false
        currentStep = 0
    }

    func complete() {
        hasCompletedOnboarding = true
        currentStep = 0
    }

    // MARK: - Onboarding Steps

    static let steps: [OnboardingStep] = [
        OnboardingStep(
            id: "welcome",
            title: "Welcome to Bunker",
            subtitle: "Where high-stakes decisions get serious",
            description: "Bunker helps you make better decisions by structuring your thinking, weighing criteria, and simulating outcomes.",
            systemImage: "building.columns.fill",
            cta: "Let's Start"
        ),
        OnboardingStep(
            id: "criteria",
            title: "Define What Matters",
            subtitle: "Your criteria, your weights",
            description: "Add criteria like Cost, Quality, Risk, or Time. Rate how important each one is. Bunker uses these to score your options.",
            systemImage: "slider.horizontal.3",
            cta: "Next"
        ),
        OnboardingStep(
            id: "options",
            title: "Compare Your Options",
            subtitle: "Score each option fairly",
            description: "Add the choices you're weighing. Score each one against your criteria. Bunker calculates the weighted total.",
            systemImage: "square.stack.3d.up.fill",
            cta: "Next"
        ),
        OnboardingStep(
            id: "outcome",
            title: "See the Best Outcome",
            subtitle: "Confidence comes from structure",
            description: "Bunker simulates outcomes based on your scores. The highest-weighted option is your recommendation — with a confidence score.",
            systemImage: "chart.bar.fill",
            cta: "Make First Decision"
        )
    ]
}

struct OnboardingStep: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let description: String
    let systemImage: String
    let cta: String
}
