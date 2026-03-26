import Foundation

struct Decision: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var description: String
    var criteria: [Criteria]
    var options: [String]
    var createdAt: Date
    var updatedAt: Date
    var deadlineDate: Date?
    var reminderDate: Date?
    var resolvedAt: Date?
    var isGoodOutcome: Bool?
    var resolvedOption: String?
    var outcomeReflection: String?
    var journalEntries: [JournalEntry]
    var stake: StakeLevel
    var reversibility: Reversibility
    var timeHorizon: TimeHorizon
    var aiAdvice: String?
    var decisionHistory: [DecisionHistoryEntry]
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        criteria: [Criteria] = [],
        options: [String] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        deadlineDate: Date? = nil,
        reminderDate: Date? = nil,
        resolvedAt: Date? = nil,
        isGoodOutcome: Bool? = nil,
        resolvedOption: String? = nil,
        outcomeReflection: String? = nil,
        journalEntries: [JournalEntry] = [],
        stake: StakeLevel = .medium,
        reversibility: Reversibility = .moderate,
        timeHorizon: TimeHorizon = .mediumTerm,
        aiAdvice: String? = nil,
        decisionHistory: [DecisionHistoryEntry] = []
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.criteria = criteria
        self.options = options
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deadlineDate = deadlineDate
        self.reminderDate = reminderDate
        self.resolvedAt = resolvedAt
        self.isGoodOutcome = isGoodOutcome
        self.resolvedOption = resolvedOption
        self.outcomeReflection = outcomeReflection
        self.journalEntries = journalEntries
        self.stake = stake
        self.reversibility = reversibility
        self.timeHorizon = timeHorizon
        self.aiAdvice = aiAdvice
        self.decisionHistory = decisionHistory
    }
    
    var isComplete: Bool {
        !criteria.isEmpty && !options.isEmpty
    }
    
    var allCriteriaScored: Bool {
        criteria.allSatisfy { $0.isScored }
    }
    
    var daysSinceCreation: Int {
        Calendar.current.dateComponents([.day], from: createdAt, to: Date()).day ?? 0
    }
    
    var isOverdue: Bool {
        guard let deadline = deadlineDate else { return false }
        return Date() > deadline && resolvedAt == nil
    }
    
    var daysUntilDeadline: Int? {
        guard let deadline = deadlineDate else { return nil }
        return Calendar.current.dateComponents([.day], from: Date(), to: deadline).day
    }
    
    var isResolved: Bool {
        resolvedOption != nil
    }
    
    var statusText: String {
        if isResolved {
            return isGoodOutcome == true ? "Succeeded" : (isGoodOutcome == false ? "Failed" : "Resolved")
        }
        if allCriteriaScored {
            return "Ready"
        }
        if isComplete {
            return "Scoring"
        }
        return "Draft"
    }
}

/// Journal entry for tracking notes throughout the decision-making process
struct JournalEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var content: String
    let createdAt: Date
    
    init(id: UUID = UUID(), content: String, createdAt: Date = Date()) {
        self.id = id
        self.content = content
        self.createdAt = createdAt
    }
}

struct DecisionHistoryEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var note: String
    var createdAt: Date
    
    init(id: UUID = UUID(), note: String, createdAt: Date = Date()) {
        self.id = id
        self.note = note
        self.createdAt = createdAt
    }
}

enum StakeLevel: String, Codable, CaseIterable, Equatable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"
    
    var color: String {
        switch self {
        case .low: return "34C759"
        case .medium: return "F5A623"
        case .high: return "FF9500"
        case .critical: return "FF453A"
        }
    }
    
    var description: String {
        switch self {
        case .low: return "Minor impact — easy to change"
        case .medium: return "Moderate impact on your life/work"
        case .high: return "Major life/work impact"
        case .critical: return "Potentially irreversible, major consequences"
        }
    }
}

enum Reversibility: String, Codable, CaseIterable, Equatable {
    case easy = "Easy"
    case moderate = "Moderate"
    case difficult = "Difficult"
    case impossible = "Impossible"
    
    var description: String {
        switch self {
        case .easy: return "Can be undone easily"
        case .moderate: return "Takes some effort to reverse"
        case .difficult: return "Hard to reverse once made"
        case .impossible: return "Cannot be undone"
        }
    }
}

enum TimeHorizon: String, Codable, CaseIterable, Equatable {
    case shortTerm = "Short-term"
    case mediumTerm = "Medium-term"
    case longTerm = "Long-term"
    case permanent = "Permanent"
    
    var description: String {
        switch self {
        case .shortTerm: return "Days to weeks"
        case .mediumTerm: return "Months to a year"
        case .longTerm: return "Several years"
        case .permanent: return "Forever"
        }
    }
}

extension Decision {
    static let preview = Decision(
        title: "Choose a Tech Stack",
        description: "Evaluate options for the backend architecture of our new product.",
        criteria: [
            Criteria(name: "Performance", importance: 8),
            Criteria(name: "Developer Experience", importance: 7),
            Criteria(name: "Scalability", importance: 9),
            Criteria(name: "Cost", importance: 6)
        ],
        options: ["Node.js", "Go", "Rust"],
        stake: .high,
        reversibility: .difficult,
        timeHorizon: .longTerm
    )
    
    static let empty = Decision(
        title: "",
        description: "",
        criteria: [],
        options: []
    )
}
