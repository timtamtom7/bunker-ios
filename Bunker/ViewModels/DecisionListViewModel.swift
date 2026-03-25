import Foundation
import SwiftUI

@MainActor
@Observable
final class DecisionListViewModel {
    var decisions: [Decision] = []
    var isLoading = false
    var errorMessage: String?
    var showNewDecision = false

    private let service = DecisionService.shared

    func load() async {
        isLoading = true
        defer { isLoading = false }
        await service.loadDecisions()
        decisions = service.decisions
    }

    func delete(_ decision: Decision) async {
        await service.deleteDecision(decision)
        decisions = service.decisions
    }

    func delete(at offsets: IndexSet) async {
        for index in offsets {
            let decision = decisions[index]
            await service.deleteDecision(decision)
        }
        decisions = service.decisions
    }

    func refresh() async {
        await load()
    }
}
