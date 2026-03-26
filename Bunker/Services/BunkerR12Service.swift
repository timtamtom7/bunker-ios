import Foundation

// R12: Social Features — Decision Teams, Community Wisdom, Accountability
@MainActor
final class BunkerR12Service: ObservableObject {
    static let shared = BunkerR12Service()

    @Published var teamDecisions: [TeamDecision] = []
    @Published var communityQuestions: [CommunityQuestion] = []
    @Published var accountabilityPartners: [AccountabilityPartner] = []
    @Published var decisionDatabase: [DecisionCase] = []

    private let storageKey = "bunkerSocialData"

    private init() {
        loadData()
    }

    // MARK: - Team Decisions

    struct TeamDecision: Identifiable, Codable, Equatable {
        let id: UUID
        var title: String
        var description: String
        var options: [DecisionOption]
        var votes: [Vote]
        var status: DecisionStatus
        var teamMemberIds: [String]
        var createdById: String
        var createdAt: Date
        var expiresAt: Date?

        enum DecisionStatus: String, Codable {
            case open, voting, decided, expired
        }

        struct DecisionOption: Identifiable, Codable, Equatable {
            let id: UUID
            var title: String
            var description: String
            var voteCount: Int

            init(id: UUID = UUID(), title: String, description: String = "", voteCount: Int = 0) {
                self.id = id
                self.title = title
                self.description = description
                self.voteCount = voteCount
            }
        }

        struct Vote: Identifiable, Codable, Equatable {
            let id: UUID
            var voterId: String
            var voterName: String
            var optionId: UUID
            var votedAt: Date

            init(id: UUID = UUID(), voterId: String = "local", voterName: String = "You", optionId: UUID, votedAt: Date = Date()) {
                self.id = id
                self.voterId = voterId
                self.voterName = voterName
                self.optionId = optionId
                self.votedAt = votedAt
            }
        }

        init(
            id: UUID = UUID(),
            title: String,
            description: String = "",
            options: [DecisionOption] = [],
            votes: [Vote] = [],
            status: DecisionStatus = .voting,
            teamMemberIds: [String] = ["local"],
            createdById: String = "local",
            createdAt: Date = Date(),
            expiresAt: Date? = nil
        ) {
            self.id = id
            self.title = title
            self.description = description
            self.options = options
            self.votes = votes
            self.status = status
            self.teamMemberIds = teamMemberIds
            self.createdById = createdById
            self.createdAt = createdAt
            self.expiresAt = expiresAt
        }
    }

    func createTeamDecision(title: String, description: String, options: [String]) -> TeamDecision {
        let decisionOptions = options.map { TeamDecision.DecisionOption(title: $0) }
        let decision = TeamDecision(title: title, description: description, options: decisionOptions)
        teamDecisions.insert(decision, at: 0)
        saveData()
        return decision
    }

    func vote(on decisionId: UUID, optionId: UUID) {
        guard let index = teamDecisions.firstIndex(where: { $0.id == decisionId }) else { return }
        let vote = TeamDecision.Vote(optionId: optionId)
        teamDecisions[index].votes.append(vote)
        // Update vote counts
        for i in 0..<teamDecisions[index].options.count {
            let count = teamDecisions[index].votes.filter { $0.optionId == teamDecisions[index].options[i].id }.count
            teamDecisions[index].options[i].voteCount = count
        }
        saveData()
    }

    func deleteTeamDecision(_ decisionId: UUID) {
        teamDecisions.removeAll { $0.id == decisionId }
        saveData()
    }

    // MARK: - Community Questions (Help Me Decide)

    struct CommunityQuestion: Identifiable, Codable, Equatable {
        let id: UUID
        var authorId: String
        var authorName: String
        var isAnonymous: Bool
        var question: String
        var options: [String]
        var responses: [Response]
        var category: QuestionCategory
        var createdAt: Date

        enum QuestionCategory: String, Codable, CaseIterable {
            case career = "Career"
            case personal = "Personal"
            case financial = "Financial"
            case relationship = "Relationship"
            case product = "Product"
            case other = "Other"
        }

        struct Response: Identifiable, Codable, Equatable {
            let id: UUID
            var responderId: String
            var responderName: String
            var selectedOption: Int  // Index
            var reasoning: String?
            var respondedAt: Date

            init(id: UUID = UUID(), responderId: String = "local", responderName: String = "You", selectedOption: Int, reasoning: String? = nil, respondedAt: Date = Date()) {
                self.id = id
                self.responderId = responderId
                self.responderName = responderName
                self.selectedOption = selectedOption
                self.reasoning = reasoning
                self.respondedAt = respondedAt
            }
        }

        init(
            id: UUID = UUID(),
            authorId: String = "local",
            authorName: String = "You",
            isAnonymous: Bool = false,
            question: String,
            options: [String],
            responses: [Response] = [],
            category: QuestionCategory = .other,
            createdAt: Date = Date()
        ) {
            self.id = id
            self.authorId = authorId
            self.authorName = authorName
            self.isAnonymous = isAnonymous
            self.question = question
            self.options = options
            self.responses = responses
            self.category = category
            self.createdAt = createdAt
        }

        var displayName: String { isAnonymous ? "Anonymous" : authorName }
    }

    func askQuestion(question: String, options: [String], category: CommunityQuestion.QuestionCategory, isAnonymous: Bool = false) -> CommunityQuestion {
        let communityQuestion = CommunityQuestion(isAnonymous: isAnonymous, question: question, options: options, category: category)
        communityQuestions.insert(communityQuestion, at: 0)
        saveData()
        return communityQuestion
    }

    func respondToQuestion(_ questionId: UUID, optionIndex: Int, reasoning: String? = nil) {
        guard let index = communityQuestions.firstIndex(where: { $0.id == questionId }) else { return }
        let response = CommunityQuestion.Response(selectedOption: optionIndex, reasoning: reasoning)
        communityQuestions[index].responses.append(response)
        saveData()
    }

    func deleteQuestion(_ questionId: UUID) {
        communityQuestions.removeAll { $0.id == questionId }
        saveData()
    }

    // MARK: - Accountability Partners

    struct AccountabilityPartner: Identifiable, Codable, Equatable {
        let id: UUID
        var partnerId: String
        var partnerName: String
        var commitments: [Commitment]
        var status: PartnershipStatus
        var startedAt: Date

        enum PartnershipStatus: String, Codable {
            case active, paused, ended
        }

        struct Commitment: Identifiable, Codable, Equatable {
            let id: UUID
            var description: String
            var targetDate: Date?
            var isCompleted: Bool
            var completedAt: Date?

            init(id: UUID = UUID(), description: String, targetDate: Date? = nil, isCompleted: Bool = false, completedAt: Date? = nil) {
                self.id = id
                self.description = description
                self.targetDate = targetDate
                self.isCompleted = isCompleted
                self.completedAt = completedAt
            }
        }

        init(
            id: UUID = UUID(),
            partnerId: String,
            partnerName: String,
            commitments: [Commitment] = [],
            status: PartnershipStatus = .active,
            startedAt: Date = Date()
        ) {
            self.id = id
            self.partnerId = partnerId
            self.partnerName = partnerName
            self.commitments = commitments
            self.status = status
            self.startedAt = startedAt
        }
    }

    func addPartner(name: String) -> AccountabilityPartner {
        let partner = AccountabilityPartner(partnerId: UUID().uuidString, partnerName: name)
        accountabilityPartners.append(partner)
        saveData()
        return partner
    }

    func addCommitment(to partnerId: UUID, description: String, targetDate: Date? = nil) {
        guard let index = accountabilityPartners.firstIndex(where: { $0.id == partnerId }) else { return }
        let commitment = AccountabilityPartner.Commitment(description: description, targetDate: targetDate)
        accountabilityPartners[index].commitments.append(commitment)
        saveData()
    }

    func completeCommitment(partnerId: UUID, commitmentId: UUID) {
        guard let partnerIndex = accountabilityPartners.firstIndex(where: { $0.id == partnerId }),
              let commitIndex = accountabilityPartners[partnerIndex].commitments.firstIndex(where: { $0.id == commitmentId }) else { return }
        accountabilityPartners[partnerIndex].commitments[commitIndex].isCompleted = true
        accountabilityPartners[partnerIndex].commitments[commitIndex].completedAt = Date()
        saveData()
    }

    func removePartner(_ partnerId: UUID) {
        accountabilityPartners.removeAll { $0.id == partnerId }
        saveData()
    }

    // MARK: - Decision Database (Community Wisdom)

    struct DecisionCase: Identifiable, Codable, Equatable {
        let id: UUID
        var title: String
        var description: String
        var outcome: String
        var category: String
        var votesHelpful: Int
        var votesNotHelpful: Int
        var createdAt: Date

        init(
            id: UUID = UUID(),
            title: String,
            description: String,
            outcome: String,
            category: String = "General",
            votesHelpful: Int = 0,
            votesNotHelpful: Int = 0,
            createdAt: Date = Date()
        ) {
            self.id = id
            self.title = title
            self.description = description
            self.outcome = outcome
            self.category = category
            self.votesHelpful = votesHelpful
            self.votesNotHelpful = votesNotHelpful
            self.createdAt = createdAt
        }
    }

    func addDecisionCase(title: String, description: String, outcome: String, category: String) -> DecisionCase {
        let decisionCase = DecisionCase(title: title, description: description, outcome: outcome, category: category)
        decisionDatabase.insert(decisionCase, at: 0)
        saveData()
        return decisionCase
    }

    func voteHelpful(_ caseId: UUID) {
        guard let index = decisionDatabase.firstIndex(where: { $0.id == caseId }) else { return }
        decisionDatabase[index].votesHelpful += 1
        saveData()
    }

    func voteNotHelpful(_ caseId: UUID) {
        guard let index = decisionDatabase.firstIndex(where: { $0.id == caseId }) else { return }
        decisionDatabase[index].votesNotHelpful += 1
        saveData()
    }

    // MARK: - Persistence

    private struct SocialData: Codable {
        var teamDecisions: [TeamDecision]
        var communityQuestions: [CommunityQuestion]
        var accountabilityPartners: [AccountabilityPartner]
        var decisionDatabase: [DecisionCase]
    }

    private func loadData() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let socialData = try? JSONDecoder().decode(SocialData.self, from: data) else {
            return
        }
        teamDecisions = socialData.teamDecisions
        communityQuestions = socialData.communityQuestions
        accountabilityPartners = socialData.accountabilityPartners
        decisionDatabase = socialData.decisionDatabase
    }

    private func saveData() {
        let socialData = SocialData(
            teamDecisions: teamDecisions,
            communityQuestions: communityQuestions,
            accountabilityPartners: accountabilityPartners,
            decisionDatabase: decisionDatabase
        )
        if let data = try? JSONEncoder().encode(socialData) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    // MARK: - Demo Data

    func loadDemoData() {
        guard teamDecisions.isEmpty && communityQuestions.isEmpty else { return }

        // Demo team decision
        let teamDecision = TeamDecision(
            title: "Which office location?",
            description: "We need to decide between downtown and the waterfront office for the new team space.",
            options: [
                TeamDecision.DecisionOption(title: "Downtown", description: "Closer to transit, more options"),
                TeamDecision.DecisionOption(title: "Waterfront", description: "Better views, newer building")
            ]
        )
        teamDecisions = [teamDecision]

        // Demo community question
        let question = CommunityQuestion(
            question: "Should I take the senior role with more money but less creative control?",
            options: ["Yes, take it", "No, keep current role", "Negotiate terms"],
            category: .career
        )
        communityQuestions = [question]

        // Demo accountability partner
        let partner = AccountabilityPartner(
            partnerId: UUID().uuidString,
            partnerName: "Alex",
            commitments: [
                AccountabilityPartner.Commitment(description: "Make a major decision by Friday"),
                AccountabilityPartner.Commitment(description: "Review all options before deciding")
            ]
        )
        accountabilityPartners = [partner]

        // Demo decision case
        let decisionCase = DecisionCase(
            title: "Changed careers at 35",
            description: "Left a stable finance job to join a startup. Analyzed risk vs. reward for 3 months.",
            outcome: "Best decision made. Learned to quantify intangible happiness factors.",
            category: "Career"
        )
        decisionDatabase = [decisionCase]

        saveData()
    }
}
