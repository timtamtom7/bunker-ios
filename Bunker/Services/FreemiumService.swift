import Foundation

/// R5: Freemium subscription tier management
@MainActor final class FreemiumService: ObservableObject {
    static let shared = FreemiumService()

    @Published private(set) var currentTier: SubscriptionTier = .free

    private let tierKey = "bunker_subscription_tier"
    private let decisionCountKey = "bunker_decision_count_free"

    init() {
        loadTier()
    }

    // MARK: - Tier Definitions

    enum SubscriptionTier: String, Codable, CaseIterable, Sendable {
        case free = "Free"
        case pro = "Pro"
        case team = "Team"

        var maxDecisions: Int {
            switch self {
            case .free: return 5
            case .pro: return Int.max
            case .team: return Int.max
            }
        }

        var maxCriteriaPerDecision: Int {
            switch self {
            case .free: return 3
            case .pro: return Int.max
            case .team: return Int.max
            }
        }

        var maxCollaborators: Int {
            switch self {
            case .free: return 1
            case .pro: return 5
            case .team: return Int.max
            }
        }

        var aiAdviceEnabled: Bool { self != .free }
        var templatesEnabled: Bool { self != .free }
        var groupsEnabled: Bool { self != .free }
        var exportEnabled: Bool { self != .free }
        var calendarSyncEnabled: Bool { self != .free }
        var shareCodesEnabled: Bool { self != .free }

        var priceDisplay: String {
            switch self {
            case .free: return "Free"
            case .pro: return "$4.99/mo"
            case .team: return "$9.99/mo"
            }
        }

        var description: String {
            switch self {
            case .free: return "Up to 5 decisions, 3 criteria each"
            case .pro: return "Unlimited decisions, AI coach, templates, export"
            case .team: return "Everything in Pro + team spaces, admin controls"
            }
        }
    }

    // MARK: - Feature Gating

    func canCreateDecision(totalDecisions: Int) -> Bool {
        currentTier != .free || totalDecisions < SubscriptionTier.free.maxDecisions
    }

    func canAddCriteria(currentCriteriaCount: Int) -> Bool {
        currentTier != .free || currentCriteriaCount < SubscriptionTier.free.maxCriteriaPerDecision
    }

    func canUseTemplate() -> Bool { currentTier.templatesEnabled }
    func canUseGroups() -> Bool { currentTier.groupsEnabled }
    func canExport() -> Bool { currentTier.exportEnabled }
    func canSyncCalendar() -> Bool { currentTier.calendarSyncEnabled }
    func canUseShareCode() -> Bool { currentTier.shareCodesEnabled }
    func canUseAIAdvice() -> Bool { currentTier.aiAdviceEnabled }

    func upgradePrompt(forFeature feature: String) -> String {
        switch currentTier {
        case .free: return "Upgrade to Pro to unlock \(feature)"
        case .pro: return "Upgrade to Team to unlock \(feature)"
        case .team: return ""
        }
    }

    // MARK: - Tier Management

    func setTier(_ tier: SubscriptionTier) {
        currentTier = tier
        UserDefaults.standard.set(tier.rawValue, forKey: tierKey)
    }

    private func loadTier() {
        if let saved = UserDefaults.standard.string(forKey: tierKey),
           let tier = SubscriptionTier(rawValue: saved) {
            currentTier = tier
        } else {
            currentTier = .free
        }
    }

    // MARK: - Usage Stats

    func usageStats(decisions: [Decision]) -> UsageStats {
        UsageStats(
            totalDecisions: decisions.count,
            maxDecisions: currentTier.maxDecisions,
            isAtLimit: currentTier == .free && decisions.count >= SubscriptionTier.free.maxDecisions
        )
    }
}

struct UsageStats: Sendable {
    let totalDecisions: Int
    let maxDecisions: Int
    let isAtLimit: Bool

    var remaining: Int { max(0, maxDecisions - totalDecisions) }

    var usagePercent: Double {
        guard maxDecisions > 0 && maxDecisions != Int.max else { return 0 }
        return min(1.0, Double(totalDecisions) / Double(maxDecisions))
    }
}
