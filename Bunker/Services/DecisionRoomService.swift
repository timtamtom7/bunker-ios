import Foundation

/// R12: Decision Room Service for team-based decision making
final class DecisionRoomService: @unchecked Sendable {
    static let shared = DecisionRoomService()

    /// In-memory store for decision rooms (replace with DatabaseService persistence as needed)
    private var rooms: [UUID: DecisionRoom] = [:]

    private init() {}

    /// Creates a new decision room and returns a room invite with a 6-character join code
    func createRoom(decision: Decision) -> RoomInvite {
        let roomId = UUID()
        let code = generateJoinCode()
        let expiresAt = Date().addingTimeInterval(24 * 60 * 60) // 24 hours

        let room = DecisionRoom(
            id: roomId,
            decision: decision,
            participants: [],
            votes: [:],
            createdAt: Date(),
            inviteCode: code,
            inviteExpiresAt: expiresAt
        )
        rooms[room.id] = room

        // Store invite code mapping
        inviteCodes[code] = room.id

        return RoomInvite(
            code: code,
            roomId: room.id,
            expiresAt: expiresAt
        )
    }

    /// Joins a room using a 6-character invite code
    func joinRoom(code: String, participant: Participant) async throws {
        guard let roomId = inviteCodes[code.uppercased()] else {
            throw DecisionRoomError.invalidCode
        }

        guard var room = rooms[roomId] else {
            throw DecisionRoomError.roomNotFound
        }

        guard room.inviteExpiresAt > Date() else {
            throw DecisionRoomError.inviteExpired
        }

        // Don't add duplicate participants
        if !room.participants.contains(where: { $0.id == participant.id }) {
            room.participants.append(participant)
            rooms[roomId] = room
        }
    }

    /// Returns the room for a given room ID
    func getRoom(roomId: UUID) -> DecisionRoom? {
        return rooms[roomId]
    }

    /// Records a vote from a participant for a specific option
    func vote(roomId: UUID, participantId: UUID, optionIndex: Int) {
        guard var room = rooms[roomId] else { return }
        room.votes[participantId] = optionIndex
        rooms[roomId] = room
    }

    /// Closes voting on a room and returns final tallies
    func closeVoting(roomId: UUID) -> DecisionRoom? {
        guard var room = rooms[roomId] else { return nil }
        room.isClosed = true
        room.closedAt = Date()
        rooms[roomId] = room
        return room
    }

    /// Returns voting results as tallies per option index
    func getVotingResults(roomId: UUID) -> [Int: Int] {
        guard let room = rooms[roomId] else { return [:] }
        return room.voteTallies
    }

    // MARK: - Private

    private var inviteCodes: [String: UUID] = [:]

    private func generateJoinCode() -> String {
        let characters = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789" // Excluding confusing chars
        return String((0..<6).map { _ in characters.randomElement()! })
    }
}

// MARK: - Supporting Types

struct DecisionRoom: Identifiable {
    let id: UUID
    let decision: Decision
    var participants: [Participant]
    var votes: [UUID: Int] // participantId: optionIndex
    var isClosed: Bool = false
    var closedAt: Date?
    let createdAt: Date
    let inviteCode: String
    let inviteExpiresAt: Date

    /// Returns vote count per option index
    var voteTallies: [Int: Int] {
        var tallies: [Int: Int] = [:]
        for (_, optionIndex) in votes {
            tallies[optionIndex, default: 0] += 1
        }
        return tallies
    }

    /// Returns the winning option index (or nil if tied/no votes)
    var winningOptionIndex: Int? {
        let tallies = voteTallies
        guard !tallies.isEmpty else { return nil }
        let maxCount = tallies.values.max() ?? 0
        let winners = tallies.filter { $0.value == maxCount }
        return winners.count == 1 ? winners.first?.key : nil
    }

    /// Whether a participant has voted
    func hasVoted(participantId: UUID) -> Bool {
        votes[participantId] != nil
    }

    /// Returns anonymized vote display (participant count per option, not who voted)
    var anonymizedResults: [(option: String, count: Int)] {
        decision.options.enumerated().map { index, option in
            (option: option, count: voteTallies[index] ?? 0)
        }
    }
}

struct RoomInvite {
    let code: String
    let roomId: UUID
    let expiresAt: Date

    var isExpired: Bool {
        Date() > expiresAt
    }

    var formattedExpires: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: expiresAt, relativeTo: Date())
    }
}

struct Participant: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    var email: String?
    var avatarColor: String // hex color for avatar
    var joinedAt: Date

    init(id: UUID = UUID(), name: String, email: String? = nil, avatarColor: String? = nil, joinedAt: Date = Date()) {
        self.id = id
        self.name = name
        self.email = email
        self.avatarColor = avatarColor ?? Self.randomColor()
        self.joinedAt = joinedAt
    }

    private static func randomColor() -> String {
        let colors = ["4A90D9", "38B2AC", "68D391", "F6AD55", "FC8181", "9F7AEA", "ED64A6"]
        return colors.randomElement() ?? "4A90D9"
    }
}

enum DecisionRoomError: LocalizedError {
    case invalidCode
    case roomNotFound
    case inviteExpired
    case notParticipant

    var errorDescription: String? {
        switch self {
        case .invalidCode: return "Invalid invite code"
        case .roomNotFound: return "Room not found"
        case .inviteExpired: return "This invite has expired"
        case .notParticipant: return "You are not a participant in this room"
        }
    }
}

// MARK: - Advisor Sharing

struct AdvisorShare: Identifiable, Codable {
    let id: UUID
    let decisionId: UUID
    let advisor: Advisor
    var score: Int? // 1-10 rating given by advisor
    var comments: String?
    let sharedAt: Date
    var respondedAt: Date?

    init(id: UUID = UUID(), decisionId: UUID, advisor: Advisor, sharedAt: Date = Date()) {
        self.id = id
        self.decisionId = decisionId
        self.advisor = advisor
        self.sharedAt = sharedAt
    }
}

struct Advisor: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    var title: String? // e.g., "Dr.", "Prof.", "Senior Engineer"
    var email: String?
    var specialty: String? // e.g., "Finance", "Technology", "Medicine"
    var avatarColor: String

    init(id: UUID = UUID(), name: String, title: String? = nil, email: String? = nil, specialty: String? = nil) {
        self.id = id
        self.name = name
        self.title = title
        self.email = email
        self.specialty = specialty
        self.avatarColor = Self.randomColor()
    }

    var displayName: String {
        [title, name].compactMap { $0 }.joined(separator: " ")
    }

    private static func randomColor() -> String {
        let colors = ["4A90D9", "38B2AC", "68D391", "F6AD55", "FC8181", "9F7AEA", "ED64A6"]
        return colors.randomElement() ?? "4A90D9"
    }
}

/// Service for sharing decisions with advisors
final class AdvisorShareService: @unchecked Sendable {
    static let shared = AdvisorShareService()

    private var shares: [UUID: [AdvisorShare]] = [:] // decisionId: shares

    private init() {}

    /// Share a decision with an advisor
    func shareWithAdvisor(decisionId: UUID, advisor: Advisor) -> AdvisorShare {
        let share = AdvisorShare(decisionId: decisionId, advisor: advisor)
        shares[decisionId, default: []].append(share)
        return share
    }

    /// Get all shares for a decision
    func getShares(for decisionId: UUID) -> [AdvisorShare] {
        shares[decisionId] ?? []
    }

    /// Get share by ID
    func getShare(shareId: UUID) -> AdvisorShare? {
        for shareList in shares.values {
            if let share = shareList.first(where: { $0.id == shareId }) {
                return share
            }
        }
        return nil
    }

    /// Advisor responds with score and comments
    func respond(shareId: UUID, score: Int, comments: String?) {
        guard var share = getShare(shareId: shareId) else { return }
        share.score = score
        share.comments = comments
        share.respondedAt = Date()

        if let index = shares[share.decisionId]?.firstIndex(where: { $0.id == shareId }) {
            shares[share.decisionId]?[index] = share
        }
    }

    /// Remove a share
    func removeShare(shareId: UUID) {
        for (decisionId, shareList) in shares {
            if let index = shareList.firstIndex(where: { $0.id == shareId }) {
                shares[decisionId]?.remove(at: index)
                return
            }
        }
    }
}
