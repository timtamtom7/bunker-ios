import Foundation

// MARK: - Decision Templates

/// A saved template for creating new decisions
struct DecisionTemplate: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var description: String?
    var icon: String  // SF Symbol name
    var criteria: [CriteriaTemplate]  // Pre-defined criteria for this template
    var options: [String]  // Common options for this template type
    var stake: StakeLevel
    var reversibility: Reversibility
    var timeHorizon: TimeHorizon
    var tags: [String]
    var usageCount: Int
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        name: String,
        description: String? = nil,
        icon: String = "doc.on-doc",
        criteria: [CriteriaTemplate] = [],
        options: [String] = [],
        stake: StakeLevel = .medium,
        reversibility: Reversibility = .moderate,
        timeHorizon: TimeHorizon = .mediumTerm,
        tags: [String] = [],
        usageCount: Int = 0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.icon = icon
        self.criteria = criteria
        self.options = options
        self.stake = stake
        self.reversibility = reversibility
        self.timeHorizon = timeHorizon
        self.tags = tags
        self.usageCount = usageCount
        self.createdAt = createdAt
    }
}

struct CriteriaTemplate: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var importance: Int  // 1-10 default importance
    var guidance: String?  // Optional hint for how to score this criteria
    
    init(id: UUID = UUID(), name: String, importance: Int = 5, guidance: String? = nil) {
        self.id = id
        self.name = name
        self.importance = importance
        self.guidance = guidance
    }
}

// NOTE: StakeLevel, Reversibility, and TimeHorizon are defined in Decision.swift

// MARK: - Default Templates

extension DecisionTemplate {
    static let templates: [DecisionTemplate] = [
        DecisionTemplate(
            name: "Career Move",
            description: "Evaluate a job change or career pivot",
            icon: "briefcase",
            criteria: [
                CriteriaTemplate(name: "Salary & Benefits", importance: 8, guidance: "Consider total comp including bonus, equity, benefits"),
                CriteriaTemplate(name: "Growth Potential", importance: 9, guidance: "Room for advancement and skill development"),
                CriteriaTemplate(name: "Work-Life Balance", importance: 7, guidance: "Hours, commute, flexibility"),
                CriteriaTemplate(name: "Company Culture", importance: 6, guidance: "Values, management style, team dynamics"),
                CriteriaTemplate(name: "Job Security", importance: 7, guidance: "Company stability and industry outlook"),
            ],
            options: ["Stay at current job", "Accept new offer", "Negotiate counteroffer"],
            stake: .high,
            reversibility: .difficult,
            timeHorizon: .longTerm,
            tags: ["career", "work", "job"]
        ),
        DecisionTemplate(
            name: "Major Purchase",
            description: "Evaluate a significant buying decision",
            icon: "cart",
            criteria: [
                CriteriaTemplate(name: "Price vs. Value", importance: 8, guidance: "Is the price justified by what you get?"),
                CriteriaTemplate(name: "Long-term Need", importance: 7, guidance: "How long will this serve you?"),
                CriteriaTemplate(name: "Quality", importance: 7, guidance: "Build quality, brand reputation"),
                CriteriaTemplate(name: "Opportunity Cost", importance: 6, guidance: "What else could you do with this money?"),
            ],
            options: ["Buy now", "Wait and save", "Buy used/refurbished", "Don't buy"],
            stake: .high,
            reversibility: .moderate,
            timeHorizon: .mediumTerm,
            tags: ["purchase", "buying", "shopping"]
        ),
        DecisionTemplate(
            name: "Relocation",
            description: "Evaluate moving to a new city or neighborhood",
            icon: "house",
            criteria: [
                CriteriaTemplate(name: "Cost of Living", importance: 8, guidance: "Housing, taxes, general expenses"),
                CriteriaTemplate(name: "Job Market", importance: 7, guidance: "Career opportunities in the area"),
                CriteriaTemplate(name: "Quality of Life", importance: 8, guidance: "Weather, culture, recreation, safety"),
                CriteriaTemplate(name: "Proximity to Family/Friends", importance: 6, guidance: "Distance and travel ease to loved ones"),
                CriteriaTemplate(name: "Commute / Transportation", importance: 5, guidance: "Local transit, walkability, drive times"),
            ],
            options: ["Move", "Stay", "Delay decision"],
            stake: .critical,
            reversibility: .impossible,
            timeHorizon: .longTerm,
            tags: ["relocation", "moving", "housing", "city"]
        ),
        DecisionTemplate(
            name: "Partnership",
            description: "Evaluate a business or personal partnership",
            icon: "handshake",
            criteria: [
                CriteriaTemplate(name: "Trust & Reliability", importance: 10, guidance: "Track record and integrity"),
                CriteriaTemplate(name: "Shared Goals", importance: 8, guidance: "Aligned vision and objectives"),
                CriteriaTemplate(name: "Complementary Skills", importance: 7, guidance: "Does each person bring what the other lacks?"),
                CriteriaTemplate(name: "Risk Sharing", importance: 7, guidance: "How is risk and reward divided?"),
                CriteriaTemplate(name: "Communication", importance: 8, guidance: "Ease of open, honest communication"),
            ],
            options: ["Partner", "Pass", "Counter-propose"],
            stake: .high,
            reversibility: .difficult,
            timeHorizon: .longTerm,
            tags: ["partnership", "business", "relationship"]
        ),
        DecisionTemplate(
            name: "Tech Stack",
            description: "Choose a technology or tool",
            icon: "cpu",
            criteria: [
                CriteriaTemplate(name: "Developer Experience", importance: 7, guidance: "How productive will the team be?"),
                CriteriaTemplate(name: "Performance", importance: 7, guidance: "Speed, scalability, reliability"),
                CriteriaTemplate(name: "Ecosystem", importance: 6, guidance: "Libraries, community, tooling"),
                CriteriaTemplate(name: "Future-Proof", importance: 6, guidance: "Longevity and vendor lock-in risk"),
                CriteriaTemplate(name: "Cost", importance: 5, guidance: "Licensing, infrastructure, maintenance"),
            ],
            options: ["Option A", "Option B", "Build in-house"],
            stake: .medium,
            reversibility: .difficult,
            timeHorizon: .longTerm,
            tags: ["technology", "software", "engineering"]
        ),
        DecisionTemplate(
            name: "Major Investment",
            description: "Evaluate a significant financial decision",
            icon: "dollarsign.circle",
            criteria: [
                CriteriaTemplate(name: "Expected Return", importance: 9, guidance: "Potential gains over time horizon"),
                CriteriaTemplate(name: "Risk Level", importance: 9, guidance: "Probability of losing principal"),
                CriteriaTemplate(name: "Liquidity", importance: 6, guidance: "How quickly can you access the money?"),
                CriteriaTemplate(name: "Tax Efficiency", importance: 5, guidance: "Tax implications of the investment"),
                CriteriaTemplate(name: "Diversification", importance: 7, guidance: "How does this fit your portfolio?"),
            ],
            options: ["Invest", "Hold cash", "Pay down debt", "Diversify existing"],
            stake: .high,
            reversibility: .moderate,
            timeHorizon: .longTerm,
            tags: ["investment", "finance", "money"]
        ),
    ]
}

// MARK: - R7: Decision Groups

struct DecisionGroup: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var iconName: String
    var color: String
    var decisionIds: [UUID]
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        name: String,
        iconName: String = "folder",
        color: String = "4A90D9",
        decisionIds: [UUID] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.color = color
        self.decisionIds = decisionIds
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    var decisionCount: Int { decisionIds.count }
}

// MARK: - R7: Collaboration

struct SharedDecision: Identifiable, Codable {
    let id: UUID
    let decisionId: UUID
    var shareCode: String
    var permissions: SharePermission
    var sharedAt: Date
    var expiresAt: Date?
    var views: Int
    var lastViewedAt: Date?
    
    init(
        id: UUID = UUID(),
        decisionId: UUID,
        shareCode: String = "",
        permissions: SharePermission = .view,
        sharedAt: Date = Date(),
        expiresAt: Date? = nil,
        views: Int = 0,
        lastViewedAt: Date? = nil
    ) {
        self.id = id
        self.decisionId = decisionId
        self.shareCode = shareCode.isEmpty ? SharedDecision.generateCode() : shareCode
        self.permissions = permissions
        self.sharedAt = sharedAt
        self.expiresAt = expiresAt
        self.views = views
        self.lastViewedAt = lastViewedAt
    }
    
    static func generateCode() -> String {
        let chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        return String((0..<6).map { _ in chars.randomElement()! })
    }
    
    var isExpired: Bool {
        guard let expiry = expiresAt else { return false }
        return Date() > expiry
    }
}

enum SharePermission: String, Codable, CaseIterable {
    case view = "View Only"
    case comment = "View & Comment"
    case edit = "View & Edit"
    
    var description: String {
        switch self {
        case .view: return "Others can view your decision"
        case .comment: return "Others can view and add comments"
        case .edit: return "Others can view and suggest edits"
        }
    }
}

// MARK: - R7: Decision Statistics

struct DecisionStats: Codable {
    var totalDecisions: Int
    var completedDecisions: Int
    var pendingDecisions: Int
    var averageCriteriaPerDecision: Double
    var averageOptionsPerDecision: Double
    var topCriteria: [String]
    var mostActiveGroup: String?
    
    var completionRate: Double {
        guard totalDecisions > 0 else { return 0 }
        return Double(completedDecisions) / Double(totalDecisions)
    }
}

// MARK: - R7: Group Icons

struct DecisionGroupIcon {
    static let icons: [(name: String, label: String)] = [
        ("folder", "General"),
        ("briefcase", "Work"),
        ("house", "Personal"),
        ("dollarsign.circle", "Financial"),
        ("heart", "Health"),
        ("book", "Learning"),
        ("airplane", "Travel"),
        ("graduationcap", "Education"),
        ("house.circle", "Home"),
        ("cart", "Shopping"),
    ]
}
