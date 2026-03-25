import Foundation
import SwiftUI

@MainActor
@Observable
final class DecisionDetailViewModel {
    var decision: Decision
    var outcomes: [Outcome] = []
    var isLoadingOutcomes = false
    var showAddCriteria = false
    var showAddOption = false
    var showScoring = false
    var showDeleteConfirmation = false
    var showShare = false
    var scoringCriteriaIndex: Int?
    var scoringOptionIndex: Int?
    var aiInsight: String = ""
    var newCriteriaName = ""
    var newCriteriaImportance = 5
    var newOptionName = ""

    private let service = DecisionService.shared
    private let aiService = AIAnalysisService.shared
    private let decisionAdviceService = AIDecisionService.shared

    init(decision: Decision) {
        self.decision = decision
        self.aiInsight = aiService.generateInsight(for: decision)
    }

    func save() async {
        await service.saveDecision(decision)
        aiInsight = aiService.generateInsight(for: decision)
        decisionAdviceService.scheduleReminder(for: decision)
        // Auto-generate AI advice when decision is complete
        if decision.isComplete && decision.aiAdvice == nil {
            decision.aiAdvice = await decisionAdviceService.generateAdvice(for: decision)
            await service.saveDecision(decision)
        }
    }

    func addCriteria() async {
        guard !newCriteriaName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        service.addCriteria(to: &decision, name: newCriteriaName.trimmingCharacters(in: .whitespaces), importance: newCriteriaImportance)
        newCriteriaName = ""
        newCriteriaImportance = 5
        await save()
    }

    func removeCriteria(at index: Int) async {
        service.removeCriteria(from: &decision, at: index)
        await save()
    }

    func addOption() async {
        guard !newOptionName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        service.addOption(to: &decision, option: newOptionName.trimmingCharacters(in: .whitespaces))
        newOptionName = ""
        await save()
    }

    func removeOption(at index: Int) async {
        service.removeOption(from: &decision, at: index)
        await save()
    }

    func setScore(criteriaIndex: Int, optionIndex: Int, score: Int) async {
        service.scoreCriteria(criteriaIndex, optionIndex: optionIndex, score: score, in: &decision)
        await save()
    }

    func simulateOutcomes() async {
        isLoadingOutcomes = true
        defer { isLoadingOutcomes = false }

        outcomes = await service.simulateOutcomes(for: decision)
    }

    func refreshInsight() {
        aiInsight = aiService.generateInsight(for: decision)
    }
    
    func generateAIAdvice() async {
        decision.aiAdvice = await decisionAdviceService.generateAdvice(for: decision)
        await save()
    }

    func delete() async {
        await service.deleteDecision(decision)
    }

    func refresh() async {
        await simulateOutcomes()
        refreshInsight()
    }
}
