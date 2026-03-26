import Foundation
import NaturalLanguage

@MainActor
final class AIAnalysisService: ObservableObject {
    static let shared = AIAnalysisService()

    private init() {}

    func generateInsight(for decision: Decision) -> String {
        guard !decision.title.isEmpty else {
            return "Add a title to start analyzing your decision."
        }

        var insights: [String] = []

        // Analyze title sentiment
        let titleSentiment = analyzeSentiment(decision.title)
        if titleSentiment > 0.3 {
            insights.append("Your decision framing is positive and forward-looking.")
        } else if titleSentiment < -0.3 {
            insights.append("The framing suggests some concern — consider what could go right.")
        }

        // Check criteria completeness
        if decision.criteria.isEmpty {
            insights.append("No criteria defined yet. Add what matters most to this decision.")
        } else if decision.criteria.count == 1 {
            insights.append("Single criterion detected. Consider other factors that might matter.")
        } else if decision.criteria.count >= 5 {
            insights.append("Well-rounded criteria set with \(decision.criteria.count) dimensions.")
        }

        // Check importance distribution
        if !decision.criteria.isEmpty {
            let avgImportance = decision.criteria.reduce(0) { $0 + $1.importance } / decision.criteria.count
            if avgImportance > 7 {
                insights.append("High-stakes decision — all criteria are weighted heavily.")
            } else if avgImportance < 4 {
                insights.append("Lower-stakes factors. Good for routine decisions.")
            }
        }

        // Check options
        if decision.options.isEmpty {
            insights.append("No options yet. Define what you're choosing between.")
        } else if decision.options.count == 1 {
            insights.append("Only one option defined. Consider alternative approaches.")
        } else if decision.options.count >= 4 {
            insights.append("Multiple options provide good comparison depth.")
        }

        // Check scoring status
        let scoredCriteria = decision.criteria.filter { $0.isScored }
        if !scoredCriteria.isEmpty {
            insights.append("\(scoredCriteria.count) of \(decision.criteria.count) criteria have scores — you're close to a recommendation.")
        }

        // Summary
        if decision.criteria.count >= 3 && !decision.options.isEmpty && scoredCriteria.count == decision.criteria.count {
            insights.append("Ready to simulate outcomes. Pull to analyze.")
        }

        if insights.isEmpty {
            insights.append("Keep building your decision criteria and options.")
        }

        return insights.joined(separator: "\n")
    }

    func generateOutcomeSummary(outcomes: [Outcome]) -> String {
        guard let top = outcomes.first else {
            return "No outcomes to analyze yet."
        }
        let confidence: String
        if top.confidence >= 80 {
            confidence = "high confidence"
        } else if top.confidence >= 50 {
            confidence = "moderate confidence"
        } else {
            confidence = "low confidence — consider scoring more criteria"
        }

        var summary = "**\(top.option)** ranks highest with a weighted score of \(String(format: "%.1f", top.weightedScore)). "
        summary += "This recommendation has \(confidence)."

        if outcomes.count > 1 {
            let gap = (outcomes.first?.weightedScore ?? 0) - (outcomes.dropFirst().first?.weightedScore ?? 0)
            if gap > 2 {
                summary += " There's a significant gap to the second option — the choice is clearer."
            } else if gap < 0.5 {
                summary += " The margin is narrow — consider refining your criteria."
            }
        }

        return summary
    }

    private func analyzeSentiment(_ text: String) -> Double {
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = text
        let range = text.startIndex..<text.endIndex

        var totalScore: Double = 0
        var count = 0

        tagger.enumerateTags(in: range, unit: .paragraph, scheme: .sentimentScore, options: []) { tag, _ in
            if let tag = tag, let score = Double(tag.rawValue) {
                totalScore += score
                count += 1
            }
            return true
        }

        return count > 0 ? totalScore / Double(count) : 0
    }
}
