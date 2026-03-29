import Foundation
import NaturalLanguage
import UserNotifications

final class AIDecisionService: @unchecked Sendable {
    static let shared = AIDecisionService()
    
    private init() {}
    
    // MARK: - AI Decision Advice
    
    func generateAdvice(for decision: Decision) async -> String {
        guard decision.isComplete else {
            return "Add at least one option and one criterion to get AI advice."
        }
        
        var advice: [String] = []
        
        // Check completeness
        if decision.criteria.count < 2 {
            advice.append("Consider adding more criteria — decisions with 3+ criteria tend to be more thorough.")
        }
        
        // Check scoring
        let scoredCount = decision.criteria.filter { $0.isScored }.count
        if scoredCount < decision.criteria.count {
            advice.append("\(decision.criteria.count - scoredCount) criteria still need scoring.")
        }
        
        // Stake-based deep advice
        switch decision.stake {
        case .critical:
            advice.append("⚠️ Critical stakes — this could fundamentally change your life trajectory.")
            advice.append(stakeCriticalAdvice(for: decision))
        case .high:
            advice.append("🔥 High-stakes decision — take this seriously and consider external input.")
            advice.append(stakeHighAdvice(for: decision))
        case .medium:
            advice.append("📊 Moderate stakes — a balanced approach is appropriate here.")
        case .low:
            advice.append("💡 Lower stakes — don't overthink this. Make a call and move on.")
        }
        
        // Reversibility framing
        switch decision.reversibility {
        case .impossible:
            advice.append("🚫 This is irreversible. Double-check your reasoning and consider seeking counsel.")
        case .difficult:
            advice.append("🔄 Reversing this will be hard. Make sure you're confident before committing.")
        case .moderate:
            advice.append("↔️ Some flexibility exists — you can course-correct if needed.")
        case .easy:
            advice.append("✅ Easy to reverse — don't fear making a wrong call here.")
        }
        
        // Time horizon framing
        switch decision.timeHorizon {
        case .permanent:
            advice.append("⏳ This is permanent. Ask yourself: will I regret not choosing this in 10 years?")
        case .longTerm:
            advice.append("📅 Long-term impact. Think about how this aligns with where you want to be.")
        case .mediumTerm:
            advice.append("🗓️ Medium-term decision. Consider both immediate and downstream effects.")
        case .shortTerm:
            advice.append("⚡ Short-term choice. Quick iteration is fine here.")
        }
        
        // Pattern analysis from criteria names
        let criteriaText = decision.criteria.map { $0.name.lowercased() }.joined(separator: " ")
        if criteriaText.contains("cost") && !criteriaText.contains("value") && !criteriaText.contains("benefit") {
            advice.append("You mention costs but not benefits. Consider adding a 'value' or 'benefit' criterion.")
        }
        if !criteriaText.contains("risk") && !criteriaText.contains("downside") {
            advice.append("No risk criteria detected. What could go wrong with each option?")
        }
        
        // Find the leading option
        if let leading = leadingOption(for: decision) {
            advice.append("Based on your criteria, '\(leading)' is currently leading — but verify this aligns with your gut.")
        }
        
        // Generate a question to challenge assumptions
        let challenge = generateChallengeQuestion(for: decision)
        advice.append(challenge)
        
        return advice.joined(separator: "\n\n")
    }
    
    private func stakeCriticalAdvice(for decision: Decision) -> String {
        var tips = [
            "Sleep on it before deciding.",
            "Get a second opinion from someone you trust.",
            "Document your reasoning so you can review it later.",
            "Ask: would I make this same decision if I knew more?"
        ]
        return tips.randomElement() ?? tips[0]
    }
    
    private func stakeHighAdvice(for decision: Decision) -> String {
        var tips = [
            "Consider the worst-case scenario for each option.",
            "Talk it through with someone who has been in a similar situation.",
            "Visualize yourself in 1 year — will you regret this?",
            "Prioritize criteria that align with your core values."
        ]
        return tips.randomElement() ?? tips[0]
    }
    
    private func leadingOption(for decision: Decision) -> String? {
        var optionScores: [String: Double] = [:]
        
        for (optionIndex, option) in decision.options.enumerated() {
            var totalScore: Double = 0
            var totalWeight: Double = 0
            
            for criterion in decision.criteria {
                let optionId = UUID(uuidString: "\(decision.id.uuidString)-\(optionIndex)") ?? UUID()
                let score = criterion.score(for: optionId)
                if score > 0 {
                    totalScore += Double(score) * Double(criterion.importance)
                    totalWeight += Double(criterion.importance)
                }
            }
            
            optionScores[option] = totalWeight > 0 ? totalScore / totalWeight : 0
        }
        
        return optionScores.max(by: { $0.value < $1.value })?.key
    }
    
    private func generateChallengeQuestion(for decision: Decision) -> String {
        let questions = [
            "What would you do if you couldn't reverse this decision?",
            "If this decision went perfectly wrong, what would happen?",
            "What does your intuition say — and why?",
            "Would you recommend this same choice to a close friend?",
            "What are you most afraid of happening?",
            "If you made this decision in 5 years instead of today, would you choose differently?",
            "What's the opportunity cost of not choosing your second option?",
            "What would the 'worst version of yourself' choose? What about the 'best version'?",
            "If this decision were a person, what would they look like?",
            "What's the one thing you wish you knew before making this?"
        ]
        return questions.randomElement() ?? "What would you do if you couldn't reverse this decision?"
    }
    
    // MARK: - AI Analysis

    func analyzeDecision(_ decision: Decision) -> AIAnalysis {
        guard decision.isComplete else {
            return AIAnalysis(
                scenarios: [],
                blindSpots: ["Decision is incomplete — add criteria and options."],
                missingInfo: ["At least one criterion", "At least two options"],
                recommendation: "Complete your decision setup before seeking AI analysis.",
                confidenceScore: 0
            )
        }

        var scenarios: [Scenario] = []
        var blindSpots: [String] = []
        var missingInfo: [String] = []
        var recommendation: String = ""
        var confidenceScore: Double = 50

        // Generate scenarios based on criteria
        let scoredCount = decision.criteria.filter { $0.isScored }.count
        let totalCriteria = decision.criteria.count

        for (index, option) in decision.options.enumerated() {
            let optionId = UUID(uuidString: "\(decision.id.uuidString)-\(index)") ?? UUID()
            var totalWeighted: Double = 0
            var totalWeight: Double = 0

            for criterion in decision.criteria {
                let score = criterion.score(for: optionId)
                if score > 0 {
                    totalWeighted += Double(score) * Double(criterion.importance)
                    totalWeight += Double(criterion.importance)
                }
            }

            let normalizedScore = totalWeight > 0 ? totalWeighted / totalWeight : 0
            let probability = min(1.0, max(0.0, normalizedScore / 10.0))

            let scenario = Scenario(
                title: option,
                probability: probability,
                outcome: generateOutcomeDescription(for: option, score: normalizedScore, criteria: decision.criteria, decision: decision)
            )
            scenarios.append(scenario)
        }

        // Sort scenarios by probability
        scenarios.sort { $0.probability > $1.probability }

        // Identify blind spots
        let criteriaText = decision.criteria.map { $0.name.lowercased() }.joined(separator: " ")
        if !criteriaText.contains("cost") && !criteriaText.contains("budget") && !criteriaText.contains("value") {
            blindSpots.append("Cost/value not explicitly weighed against other factors")
        }
        if !criteriaText.contains("risk") && !criteriaText.contains("downside") && !criteriaText.contains("failure") {
            blindSpots.append("No risk or downside analysis — what could go wrong?")
        }
        if !criteriaText.contains("time") && !criteriaText.contains("duration") {
            blindSpots.append("Time investment not considered — how much time does each option require?")
        }
        if decision.options.count < 2 {
            blindSpots.append("Only one option defined — consider alternatives")
        }
        if decision.options.count > 5 {
            blindSpots.append("Many options may indicate scope creep — narrow to 2-3 strong candidates")
        }
        if decision.stake == .critical && blindSpots.count < 2 {
            blindSpots.append("Critical stakes demand extra scrutiny — consider seeking external input")
        }
        if scoredCount < totalCriteria {
            blindSpots.append("\(totalCriteria - scoredCount) criteria are unscored — these affect recommendation quality")
        }

        // Identify missing information
        if decision.title.count < 10 {
            missingInfo.append("Decision title is brief — add more context for better analysis")
        }
        if decision.description.count < 20 {
            missingInfo.append("Decision description lacks detail — what background is important?")
        }
        if decision.deadlineDate == nil {
            missingInfo.append("No deadline set — time constraints affect the decision context")
        }
        if scoredCount < totalCriteria {
            missingInfo.append("Score all \(totalCriteria) criteria to improve confidence")
        }
        if decision.stake == .low && missingInfo.isEmpty {
            missingInfo.append("Consider: what would change your mind about this choice?")
        }

        // Calculate confidence
        var confidence: Double = 50
        confidence += Double(scoredCount) / Double(max(1, totalCriteria)) * 30
        confidence += decision.options.isEmpty ? 0 : 10
        confidence += blindSpots.isEmpty ? 10 : max(0, 10 - Double(blindSpots.count) * 2)
        confidenceScore = min(95, max(10, confidence))

        // Generate recommendation
        if let topScenario = scenarios.first {
            if topScenario.probability > 0.7 {
                recommendation = "'\(topScenario.title)' shows strong alignment with your weighted criteria. Proceed if this feels right."
            } else if topScenario.probability > 0.5 {
                recommendation = "'\(topScenario.title)' is leading, but the gap to alternatives is narrow. Consider refining your criteria."
            } else {
                recommendation = "No clear leader yet. Score all criteria and consider whether your weights reflect your true priorities."
            }
        }

        if decision.stake == .critical {
            recommendation = "⚠️ Critical decision — sleep on it. Get a second opinion. Document your reasoning. \(recommendation)"
        }

        if !blindSpots.isEmpty {
            recommendation += "\n\nKey concern: \(blindSpots.first ?? "Review your blind spots above.")"
        }

        return AIAnalysis(
            scenarios: scenarios,
            blindSpots: blindSpots,
            missingInfo: missingInfo,
            recommendation: recommendation,
            confidenceScore: confidenceScore
        )
    }

    private func generateOutcomeDescription(for option: String, score: Double, criteria: [Criteria], decision: Decision) -> String {
        let strengths = criteria.filter { c in
            let optIdx = decision.options.firstIndex(of: option) ?? 0
            let optionId = UUID(uuidString: "\(decision.id.uuidString)-\(optIdx)") ?? UUID()
            return c.score(for: optionId) >= 7
        }.map { $0.name }

        let weaknesses = criteria.filter { c in
            let optIdx = decision.options.firstIndex(of: option) ?? 0
            let optionId = UUID(uuidString: "\(decision.id.uuidString)-\(optIdx)") ?? UUID()
            return c.score(for: optionId) > 0 && c.score(for: optionId) < 4
        }.map { $0.name }

        var desc = "Score: \(String(format: "%.1f", score))/10"
        if !strengths.isEmpty {
            desc += " — Strong in: \(strengths.joined(separator: ", "))"
        }
        if !weaknesses.isEmpty {
            desc += " — Weak in: \(weaknesses.joined(separator: ", "))"
        }
        return desc
    }

    struct AIAnalysis {
        let scenarios: [Scenario]
        let blindSpots: [String]
        let missingInfo: [String]
        let recommendation: String
        let confidenceScore: Double
    }

    struct Scenario {
        let title: String
        let probability: Double
        let outcome: String
    }

    // MARK: - Reminders
    
    func scheduleReminder(for decision: Decision) {
        let center = UNUserNotificationCenter.current()
        
        // 2 days before deadline
        if let deadline = decision.deadlineDate {
            center.removePendingNotificationRequests(withIdentifiers: [
                "deadline_2day_\(decision.id.uuidString)",
                "deadline_today_\(decision.id.uuidString)",
                "deadline_followup_\(decision.id.uuidString)"
            ])
            
            // 2 days before
            let twoDayContent = UNMutableNotificationContent()
            twoDayContent.title = "⏰ Decision deadline approaching"
            twoDayContent.body = "\"\(decision.title)\" is due in 2 days. Have you made your decision?"
            twoDayContent.sound = .default
            twoDayContent.categoryIdentifier = "DECISION_REMINDER"
            
            let twoDayDate = Calendar.current.date(byAdding: .day, value: -2, to: deadline) ?? deadline
            let twoDayComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: twoDayDate)
            let twoDayTrigger = UNCalendarNotificationTrigger(dateMatching: twoDayComponents, repeats: false)
            let twoDayRequest = UNNotificationRequest(
                identifier: "deadline_2day_\(decision.id.uuidString)",
                content: twoDayContent,
                trigger: twoDayTrigger
            )
            center.add(twoDayRequest)
            
            // On deadline day
            let todayContent = UNMutableNotificationContent()
            todayContent.title = "📋 Decision day"
            todayContent.body = "\"\(decision.title)\" is due today. Have you decided yet?"
            todayContent.sound = .default
            todayContent.categoryIdentifier = "DECISION_REMINDER"
            
            let deadlineComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: deadline)
            let deadlineTrigger = UNCalendarNotificationTrigger(dateMatching: deadlineComponents, repeats: false)
            let deadlineRequest = UNNotificationRequest(
                identifier: "deadline_today_\(decision.id.uuidString)",
                content: todayContent,
                trigger: deadlineTrigger
            )
            center.add(deadlineRequest)
            
            // 1 week after deadline (follow-up)
            let followUpDate = Calendar.current.date(byAdding: .day, value: 7, to: deadline) ?? deadline
            let followUpContent = UNMutableNotificationContent()
            followUpContent.title = "🤔 How did it go?"
            followUpContent.body = "\"\(decision.title)\" — what did you decide? Mark the outcome to track your decision quality."
            followUpContent.sound = .default
            followUpContent.categoryIdentifier = "DECISION_FOLLOWUP"
            
            let followUpComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: followUpDate)
            let followUpTrigger = UNCalendarNotificationTrigger(dateMatching: followUpComponents, repeats: false)
            let followUpRequest = UNNotificationRequest(
                identifier: "deadline_followup_\(decision.id.uuidString)",
                content: followUpContent,
                trigger: followUpTrigger
            )
            center.add(followUpRequest)
        }
        
        // Custom reminder
        if let reminder = decision.reminderDate {
            center.removePendingNotificationRequests(withIdentifiers: ["reminder_\(decision.id.uuidString)"])
            
            let content = UNMutableNotificationContent()
            content.title = "Time to decide"
            content.body = "\"\(decision.title)\" — what's your gut telling you?"
            content.sound = .default
            content.categoryIdentifier = "DECISION_REMINDER"
            
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour], from: reminder)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: "reminder_\(decision.id.uuidString)", content: content, trigger: trigger)
            
            center.add(request)
        }
    }
    
    func cancelReminder(for decision: Decision) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [
            "deadline_2day_\(decision.id.uuidString)",
            "deadline_today_\(decision.id.uuidString)",
            "deadline_followup_\(decision.id.uuidString)",
            "reminder_\(decision.id.uuidString)"
        ])
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    }
}
