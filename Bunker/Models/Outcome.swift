import Foundation

struct Outcome: Identifiable, Codable {
    let id: UUID
    let decisionId: UUID
    let option: String
    let weightedScore: Double
    let confidence: Double // 0-100
    let scoreBreakdown: [ScoreBreakdown]
    let generatedAt: Date

    struct ScoreBreakdown: Identifiable, Codable {
        let id: UUID
        let criteriaName: String
        let criteriaWeight: Int
        let optionScore: Int
        let weightedValue: Double
    }

    init(
        id: UUID = UUID(),
        decisionId: UUID,
        option: String,
        weightedScore: Double,
        confidence: Double,
        scoreBreakdown: [ScoreBreakdown] = [],
        generatedAt: Date = Date()
    ) {
        self.id = id
        self.decisionId = decisionId
        self.option = option
        self.weightedScore = weightedScore
        self.confidence = confidence
        self.scoreBreakdown = scoreBreakdown
        self.generatedAt = generatedAt
    }
}

extension Outcome {
    static func compute(from decision: Decision) -> [Outcome] {
        guard !decision.criteria.isEmpty, !decision.options.isEmpty else { return [] }

        let totalImportance = decision.criteria.reduce(0) { $0 + $1.importance }
        guard totalImportance > 0 else { return [] }

        var outcomes: [Outcome] = []

        for optionIndex in decision.options.indices {
            let optionId = UUID(uuidString: "\(decision.id.uuidString)-\(optionIndex)") ?? UUID()
            var breakdown: [Outcome.ScoreBreakdown] = []
            var weightedSum: Double = 0

            for criteria in decision.criteria {
                let score = criteria.score(for: optionId)
                let weightedValue = Double(score * criteria.importance) / Double(totalImportance)
                weightedSum += weightedValue

                breakdown.append(Outcome.ScoreBreakdown(
                    id: criteria.id,
                    criteriaName: criteria.name,
                    criteriaWeight: criteria.importance,
                    optionScore: score,
                    weightedValue: weightedValue
                ))
            }

            // Confidence based on how many criteria are scored
            let scoredCount = decision.criteria.filter { $0.score(for: optionId) > 0 }.count
            let totalCount = decision.criteria.count
            let confidence = Double(scoredCount) / Double(totalCount) * 100

            let outcome = Outcome(
                decisionId: decision.id,
                option: decision.options[optionIndex],
                weightedScore: weightedSum,
                confidence: confidence,
                scoreBreakdown: breakdown
            )
            outcomes.append(outcome)
        }

        return outcomes.sorted { $0.weightedScore > $1.weightedScore }
    }
}

extension Outcome {
    static let preview = Outcome(
        decisionId: UUID(),
        option: "Node.js",
        weightedScore: 7.2,
        confidence: 85.0,
        scoreBreakdown: []
    )
}
