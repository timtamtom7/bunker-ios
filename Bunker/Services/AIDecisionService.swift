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
        
        // Stake-based advice
        switch decision.stake {
        case .critical, .high:
            advice.append("This is a high-stakes decision. Consider sleeping on it before committing.")
            if decision.reversibility == .impossible {
                advice.append("This decision is irreversible. Make sure you've explored all angles.")
            }
        case .low, .medium:
            if decision.options.count > 3 {
                advice.append("With multiple options, try narrowing to your top 2-3 before deep analysis.")
            }
        }
        
        // Time horizon advice
        if decision.timeHorizon == .permanent {
            advice.append("A permanent decision deserves extra scrutiny. What would you tell someone else in your situation?")
        }
        
        // Pattern analysis from criteria names
        let criteriaText = decision.criteria.map { $0.name.lowercased() }.joined(separator: " ")
        if criteriaText.contains("cost") && !criteriaText.contains("value") && !criteriaText.contains("benefit") {
            advice.append("You mention costs but not benefits. Consider adding a 'value' or 'benefit' criterion.")
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
    
    private func leadingOption(for decision: Decision) -> String? {
        var optionScores: [String: Double] = [:]
        
        for option in decision.options {
            var totalScore: Double = 0
            var totalWeight: Double = 0
            
            for criterion in decision.criteria {
                let score = criterion.score(for: UUID())
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
        
        if let deadline = decision.deadlineDate {
            center.removePendingNotificationRequests(withIdentifiers: ["deadline_\(decision.id.uuidString)"])
            
            let content = UNMutableNotificationContent()
            content.title = "Decision deadline approaching"
            content.body = "\"\(decision.title)\" is due soon. Have you made your decision?"
            content.sound = .default
            content.categoryIdentifier = "DECISION_REMINDER"
            
            let reminderDate = Calendar.current.date(byAdding: .day, value: -2, to: deadline) ?? deadline
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour], from: reminderDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: "deadline_\(decision.id.uuidString)", content: content, trigger: trigger)
            
            center.add(request)
        }
        
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
            "deadline_\(decision.id.uuidString)",
            "reminder_\(decision.id.uuidString)"
        ])
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    }
}
