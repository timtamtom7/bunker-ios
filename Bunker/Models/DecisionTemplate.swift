import Foundation

struct DecisionTemplate: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var description: String
    var icon: String
    var options: [String]
    var criteria: [Criteria]
    var stake: StakeLevel
    var reversibility: Reversibility
    var timeHorizon: TimeHorizon

    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        icon: String,
        options: [String],
        criteria: [Criteria],
        stake: StakeLevel = .medium,
        reversibility: Reversibility = .moderate,
        timeHorizon: TimeHorizon = .mediumTerm
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.icon = icon
        self.options = options
        self.criteria = criteria
        self.stake = stake
        self.reversibility = reversibility
        self.timeHorizon = timeHorizon
    }

    func toDecision() -> Decision {
        Decision(
            title: "",
            description: "",
            criteria: criteria,
            options: options,
            stake: stake,
            reversibility: reversibility,
            timeHorizon: timeHorizon
        )
    }
}

extension DecisionTemplate {
    static let templates: [DecisionTemplate] = [
        DecisionTemplate(
            name: "Job Offer Comparison",
            description: "Compare multiple job offers across key dimensions",
            icon: "briefcase.fill",
            options: ["Accept Offer A", "Accept Offer B", "Decline Both"],
            criteria: [
                Criteria(name: "Salary & Benefits", importance: 9),
                Criteria(name: "Growth & Learning", importance: 8),
                Criteria(name: "Work-Life Balance", importance: 8),
                Criteria(name: "Company Culture", importance: 7),
                Criteria(name: "Location & Commute", importance: 6),
                Criteria(name: "Job Security", importance: 7)
            ],
            stake: .high,
            reversibility: .difficult,
            timeHorizon: .longTerm
        ),
        DecisionTemplate(
            name: "Moving Decision",
            description: "Evaluate relocation options for you or your family",
            icon: "house.fill",
            options: ["Stay Current Location", "Move to City A", "Move to City B"],
            criteria: [
                Criteria(name: "Cost of Living", importance: 8),
                Criteria(name: "Career Opportunities", importance: 8),
                Criteria(name: "Quality of Life", importance: 9),
                Criteria(name: "Proximity to Family", importance: 7),
                Criteria(name: "Climate & Environment", importance: 6),
                Criteria(name: "Social Community", importance: 7)
            ],
            stake: .critical,
            reversibility: .difficult,
            timeHorizon: .permanent
        ),
        DecisionTemplate(
            name: "Major Purchase",
            description: "Compare big-ticket items like car, home, or tech",
            icon: "creditcard.fill",
            options: ["Option A", "Option B", "Option C"],
            criteria: [
                Criteria(name: "Price", importance: 8),
                Criteria(name: "Quality & Durability", importance: 8),
                Criteria(name: "Features", importance: 6),
                Criteria(name: "Resale Value", importance: 5),
                Criteria(name: "Maintenance Cost", importance: 6),
                Criteria(name: "Aesthetics", importance: 4)
            ],
            stake: .high,
            reversibility: .difficult,
            timeHorizon: .longTerm
        ),
        DecisionTemplate(
            name: "Business Decision",
            description: "Strategic business choices with stakeholders",
            icon: "building.2.fill",
            options: ["Plan A", "Plan B", "Pivot Strategy"],
            criteria: [
                Criteria(name: "ROI", importance: 9),
                Criteria(name: "Risk Level", importance: 8),
                Criteria(name: "Time to Market", importance: 7),
                Criteria(name: "Team Impact", importance: 6),
                Criteria(name: "Competitive Advantage", importance: 8),
                Criteria(name: "Operational Complexity", importance: 5)
            ],
            stake: .critical,
            reversibility: .difficult,
            timeHorizon: .longTerm
        ),
        DecisionTemplate(
            name: "Relationship Decision",
            description: "Navigate personal relationship crossroads",
            icon: "heart.fill",
            options: ["Stay the Course", "Make a Change", "Seek Counsel First"],
            criteria: [
                Criteria(name: "Emotional Well-being", importance: 9),
                Criteria(name: "Shared Values", importance: 9),
                Criteria(name: "Communication Quality", importance: 8),
                Criteria(name: "Life Goals Alignment", importance: 8),
                Criteria(name: "Support System", importance: 7),
                Criteria(name: "Growth Potential", importance: 7)
            ],
            stake: .critical,
            reversibility: .impossible,
            timeHorizon: .permanent
        ),
        DecisionTemplate(
            name: "Education Choice",
            description: "Decide between schools, courses, or certifications",
            icon: "graduationcap.fill",
            options: ["Option A", "Option B", "Defer Decision"],
            criteria: [
                Criteria(name: "Reputation & Ranking", importance: 7),
                Criteria(name: "Cost & ROI", importance: 8),
                Criteria(name: "Program Quality", importance: 9),
                Criteria(name: "Location", importance: 6),
                Criteria(name: "Career Services", importance: 8),
                Criteria(name: "Network & Alumni", importance: 7)
            ],
            stake: .high,
            reversibility: .moderate,
            timeHorizon: .longTerm
        )
    ]
}
