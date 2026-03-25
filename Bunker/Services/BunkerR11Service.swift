import Foundation
import EventKit

// R11: Calendar Sync, Templates, Team Groups for Bunker
@MainActor
final class BunkerR11Service: ObservableObject {
    static let shared = BunkerR11Service()

    @Published var teamGroups: [TeamGroup] = []

    private init() {}

    // MARK: - Calendar Sync

    func syncToCalendar(decision: Decision) async throws {
        let store = EKEventStore()
        let authorized = try await store.requestFullAccessToEvents()

        guard authorized else { return }

        let event = EKEvent(eventStore: store)
        event.title = "Decision: \(decision.title)"
        event.notes = decision.notes
        event.startDate = decision.dueDate
        event.endDate = decision.dueDate?.addingTimeInterval(3600)
        event.calendar = store.defaultCalendarForNewEvents

        try store.save(event, span: .thisEvent)
    }

    // MARK: - Decision Templates

    struct DecisionTemplate: Identifiable, Codable {
        let id: UUID
        var name: String
        var category: String
        var questions: [String]
        var criteria: [String]
    }

    static let defaultTemplates: [DecisionTemplate] = [
        DecisionTemplate(id: UUID(), name: "Buy vs Lease", category: "Financial", questions: ["Monthly budget?", "How long will you need the item?"], criteria: ["Cost", "Flexibility", "Long-term value"]),
        DecisionTemplate(id: UUID(), name: "Job Offer Comparison", category: "Career", questions: ["Salary?", "Benefits?", "Culture fit?"], criteria: ["Compensation", "Growth", "Work-life balance"]),
        DecisionTemplate(id: UUID(), name: "Major Purchase", category: "Financial", questions: ["Do you need it or want it?", "What's the total cost?"], criteria: ["Necessity", "Affordability", "Long-term value"])
    ]

    func applyTemplate(_ template: DecisionTemplate, to decision: inout Decision) {
        decision.notes = template.questions.joined(separator: "\n- ")
    }

    // MARK: - Team Groups

    struct TeamGroup: Identifiable {
        let id: UUID
        var name: String
        var members: [TeamMember]
        var decisions: [Decision]
        var isAnonymous: Bool

        var inviteCode: String {
            String(UUID().uuidString.prefix(8))
        }
    }

    struct TeamMember: Identifiable {
        let id: UUID
        var name: String
        var isHost: Bool
    }

    struct Decision: Identifiable {
        let id: UUID
        var title: String
        var notes: String
        var dueDate: Date?
        var votes: [Vote]
    }

    struct Vote: Identifiable {
        let id: UUID
        let memberId: UUID
        var choice: String
        var reasoning: String
    }

    func createTeam(name: String) -> TeamGroup {
        TeamGroup(id: UUID(), name: name, members: [], decisions: [], isAnonymous: false)
    }

    func vote(on decision: Decision, choice: String, reasoning: String, memberId: UUID) -> Decision {
        var updated = decision
        updated.votes.append(Vote(id: UUID(), memberId: memberId, choice: choice, reasoning: reasoning))
        return updated
    }
}
