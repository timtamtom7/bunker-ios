import Foundation

/// R9: Achievement badges for gamification
final class AchievementService: @unchecked Sendable {
    static let shared = AchievementService()

    private init() {}

    // MARK: - Achievement Types

    enum AchievementType: String, Codable, CaseIterable {
        case firstDecision = "first_decision"
        case tenDecisions = "ten_decisions"
        case fiftyDecisions = "fifty_decisions"
        case hundredDecisions = "hundred_decisions"

        case firstAIInsight = "first_ai_insight"
        case tenAIInsights = "ten_ai_insights"
        case fiftyAIInsights = "fifty_ai_insights"

        case firstTemplate = "first_template"
        case fiveTemplates = "five_templates"
        case tenTemplates = "ten_templates"

        case firstGroup = "first_group"
        case fiveGroups = "five_groups"

        case shareDecision = "share_decision"
        case calendarSync = "calendar_sync"
        case exportDecision = "export_decision"

        case weekStreak = "week_streak"
        case monthStreak = "month_streak"

        case perfectScore = "perfect_score"
        case highConfidence = "high_confidence"
        case lowRiskHighReward = "low_risk_high_reward"

        var title: String {
            switch self {
            case .firstDecision: return "First Step"
            case .tenDecisions: return "Getting Started"
            case .fiftyDecisions: return "Decision Maker"
            case .hundredDecisions: return "Century Club"
            case .firstAIInsight: return "AI Enhanced"
            case .tenAIInsights: return "AI Power User"
            case .fiftyAIInsights: return "AI Master"
            case .firstTemplate: return "Template Creator"
            case .fiveTemplates: return "Template Library"
            case .tenTemplates: return "Template Master"
            case .firstGroup: return "Organized"
            case .fiveGroups: return "Group Master"
            case .shareDecision: return "Sharing is Caring"
            case .calendarSync: return "Synced"
            case .exportDecision: return "Data Driven"
            case .weekStreak: return "Week Warrior"
            case .monthStreak: return "Monthly Master"
            case .perfectScore: return "Perfectionist"
            case .highConfidence: return "Confident"
            case .lowRiskHighReward: return "Risk Analyst"
            }
        }

        var description: String {
            switch self {
            case .firstDecision: return "Created your first decision"
            case .tenDecisions: return "Created 10 decisions"
            case .fiftyDecisions: return "Created 50 decisions"
            case .hundredDecisions: return "Created 100 decisions"
            case .firstAIInsight: return "Used AI to analyze a decision"
            case .tenAIInsights: return "Used AI 10 times"
            case .fiftyAIInsights: return "Used AI 50 times"
            case .firstTemplate: return "Created your first template"
            case .fiveTemplates: return "Created 5 templates"
            case .tenTemplates: return "Created 10 templates"
            case .firstGroup: return "Created your first group"
            case .fiveGroups: return "Created 5 groups"
            case .shareDecision: return "Shared a decision"
            case .calendarSync: return "Enabled calendar sync"
            case .exportDecision: return "Exported a decision"
            case .weekStreak: return "Made decisions for 7 days straight"
            case .monthStreak: return "Made decisions for 30 days straight"
            case .perfectScore: return "Got a perfect 10/10 on all criteria"
            case .highConfidence: return "Made a decision with 95%+ confidence"
            case .lowRiskHighReward: return "Made a high-reward decision with low risk"
            }
        }

        var icon: String {
            switch self {
            case .firstDecision: return "star.fill"
            case .tenDecisions, .fiftyDecisions, .hundredDecisions: return "star.circle.fill"
            case .firstAIInsight, .tenAIInsights, .fiftyAIInsights: return "brain.head.profile"
            case .firstTemplate, .fiveTemplates, .tenTemplates: return "doc.on-doc.fill"
            case .firstGroup, .fiveGroups: return "folder.fill"
            case .shareDecision: return "square.and.arrow.up.fill"
            case .calendarSync: return "calendar"
            case .exportDecision: return "arrow.down.doc.fill"
            case .weekStreak, .monthStreak: return "flame.fill"
            case .perfectScore: return "checkmark.seal.fill"
            case .highConfidence: return "bolt.fill"
            case .lowRiskHighReward: return "scale.3d"
            }
        }

        var tier: BadgeTier {
            switch self {
            case .firstDecision, .firstAIInsight, .firstTemplate, .firstGroup, .shareDecision, .calendarSync, .exportDecision:
                return .bronze
            case .tenDecisions, .tenAIInsights, .fiveTemplates, .fiveGroups, .weekStreak, .highConfidence:
                return .silver
            case .fiftyDecisions, .fiftyAIInsights, .tenTemplates, .monthStreak, .perfectScore, .lowRiskHighReward:
                return .gold
            case .hundredDecisions:
                return .platinum
            }
        }
    }

    enum BadgeTier: String, Codable {
        case bronze, silver, gold, platinum

        var color: String {
            switch self {
            case .bronze: return "#CD7F32"
            case .silver: return "#C0C0C0"
            case .gold: return "#FFD700"
            case .platinum: return "#E5E4E2"
            }
        }
    }

    struct Achievement: Identifiable, Codable {
        let id: UUID
        let type: AchievementType
        let earnedAt: Date
        let metadata: [String: String]
    }

    // MARK: - Achievement Checking

    func checkAndAwardAchievements(for decisions: [Decision]) -> [Achievement] {
        var newAchievements: [Achievement] = []
        let existing = getUnlockedAchievements()

        for type in AchievementType.allCases {
            if existing.contains(where: { $0.type == type }) { continue }

            if let achievement = checkAchievement(type, decisions: decisions) {
                newAchievements.append(achievement)
            }
        }

        if !newAchievements.isEmpty {
            saveAchievements(existing + newAchievements)
        }

        return newAchievements
    }

    private func checkAchievement(_ type: AchievementType, decisions: [Decision]) -> Achievement? {
        switch type {
        case .firstDecision:
            if decisions.count >= 1 {
                return makeAchievement(type)
            }
        case .tenDecisions:
            if decisions.count >= 10 {
                return makeAchievement(type)
            }
        case .fiftyDecisions:
            if decisions.count >= 50 {
                return makeAchievement(type)
            }
        case .hundredDecisions:
            if decisions.count >= 100 {
                return makeAchievement(type)
            }
        case .firstTemplate:
            // Template tracking would require separate storage
            // Skipping for now
            break
        case .perfectScore:
            if decisions.contains(where: { decision in
                decision.criteria.allSatisfy { $0.importance == 10 }
            }) {
                return makeAchievement(type)
            }
        default:
            return nil
        }
        return nil
    }

    private func makeAchievement(_ type: AchievementType) -> Achievement {
        Achievement(
            id: UUID(),
            type: type,
            earnedAt: Date(),
            metadata: [:]
        )
    }

    // MARK: - Persistence

    private let achievementsKey = "bunker_achievements"

    func getUnlockedAchievements() -> [Achievement] {
        guard let data = UserDefaults.standard.data(forKey: achievementsKey),
              let achievements = try? JSONDecoder().decode([Achievement].self, from: data) else {
            return []
        }
        return achievements
    }

    private func saveAchievements(_ achievements: [Achievement]) {
        if let data = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(data, forKey: achievementsKey)
        }
    }

    // MARK: - Stats

    func totalAchievements() -> Int { getUnlockedAchievements().count }

    func achievementsByTier() -> [BadgeTier: Int] {
        let achievements = getUnlockedAchievements()
        var result: [BadgeTier: Int] = [.bronze: 0, .silver: 0, .gold: 0, .platinum: 0]
        for achievement in achievements {
            result[achievement.type.tier, default: 0] += 1
        }
        return result
    }
}
