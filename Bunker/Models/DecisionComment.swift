import Foundation

/// R6: Decision comment model for collaboration
struct DecisionComment: Identifiable, Codable, Equatable {
    let id: UUID
    let decisionId: UUID
    let authorId: UUID
    let authorName: String
    var content: String
    let createdAt: Date
    var updatedAt: Date?
    var mentions: [UUID]  // User IDs mentioned in comment

    init(
        id: UUID = UUID(),
        decisionId: UUID,
        authorId: UUID,
        authorName: String,
        content: String,
        createdAt: Date = Date(),
        updatedAt: Date? = nil,
        mentions: [UUID] = []
    ) {
        self.id = id
        self.decisionId = decisionId
        self.authorId = authorId
        self.authorName = authorName
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.mentions = mentions
    }

    var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
}

/// R6: Collaboration session for shared decision-making
struct CollaborationSession: Identifiable, Codable {
    let id: UUID
    let decisionId: UUID
    var participants: [CollaborationParticipant]
    var comments: [DecisionComment]
    var isActive: Bool
    let createdAt: Date
    var endedAt: Date?

    init(
        id: UUID = UUID(),
        decisionId: UUID,
        participants: [CollaborationParticipant] = [],
        comments: [DecisionComment] = [],
        isActive: Bool = true,
        createdAt: Date = Date(),
        endedAt: Date? = nil
    ) {
        self.id = id
        self.decisionId = decisionId
        self.participants = participants
        self.comments = comments
        self.isActive = isActive
        self.createdAt = createdAt
        self.endedAt = endedAt
    }

    var commentCount: Int { comments.count }
}

struct CollaborationParticipant: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let role: ParticipantRole
    var joinedAt: Date

    enum ParticipantRole: String, Codable {
        case owner
        case editor
        case viewer
    }
}
