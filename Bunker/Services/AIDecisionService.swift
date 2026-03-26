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
                let optionId = UUID(uuidString: "\(decision.id.uuidString)-\(optionIndex)")!
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
