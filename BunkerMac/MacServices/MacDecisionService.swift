import Foundation

// Re-export essential services from Bunker
// These are macOS-compatible service wrappers

@MainActor
final class DecisionService: ObservableObject {
    static let shared = DecisionService()

    @Published private(set) var decisions: [Decision] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let database = DatabaseService.shared

    private init() {}

    func loadDecisions() async {
        isLoading = true
        defer { isLoading = false }

        do {
            decisions = try database.fetchAllDecisions()
        } catch {
            errorMessage = "Failed to load decisions."
        }
    }

    func saveDecision(_ decision: Decision) async {
        do {
            try database.saveDecision(decision)
            if let index = decisions.firstIndex(where: { $0.id == decision.id }) {
                decisions[index] = decision
            } else {
                decisions.insert(decision, at: 0)
            }
        } catch {
            errorMessage = "Failed to save."
        }
    }

    func deleteDecision(_ decision: Decision) async {
        do {
            try database.deleteDecision(id: decision.id)
            decisions.removeAll { $0.id == decision.id }
        } catch {
            errorMessage = "Failed to delete."
        }
    }

    func addCriteria(to decision: inout Decision, name: String, importance: Int) {
        let criteria = Criteria(name: name, importance: importance)
        decision.criteria.append(criteria)
        decision.updatedAt = Date()
    }

    func removeCriteria(from decision: inout Decision, at index: Int) {
        guard decision.criteria.indices.contains(index) else { return }
        decision.criteria.remove(at: index)
        decision.updatedAt = Date()
    }

    func addOption(to decision: inout Decision, option: String) {
        decision.options.append(option)
        decision.updatedAt = Date()
    }

    func removeOption(from decision: inout Decision, at index: Int) {
        guard decision.options.indices.contains(index) else { return }
        decision.options.remove(at: index)
        decision.updatedAt = Date()
    }

    func cloneDecision(_ decision: Decision) -> Decision {
        Decision(
            title: "\(decision.title) (Copy)",
            description: decision.description,
            criteria: decision.criteria.map { criteria in
                Criteria(name: criteria.name, importance: criteria.importance, scores: [:])
            },
            options: decision.options,
            stake: decision.stake,
            reversibility: decision.reversibility,
            timeHorizon: decision.timeHorizon
        )
    }

    func scoreCriteria(_ criteriaIndex: Int, optionIndex: Int, score: Int, in decision: inout Decision) {
        guard decision.criteria.indices.contains(criteriaIndex),
              decision.options.indices.contains(optionIndex) else { return }
        let optionId = UUID(uuidString: "\(decision.id.uuidString)-\(optionIndex)") ?? UUID()
        decision.criteria[criteriaIndex].setScore(score, for: optionId)
        decision.updatedAt = Date()
    }

    func simulateOutcomes(for decision: Decision) async -> [Outcome] {
        let outcomes = Outcome.compute(from: decision)
        for outcome in outcomes {
            try? database.saveOutcome(outcome)
        }
        return outcomes
    }
}
