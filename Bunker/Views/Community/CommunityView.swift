import SwiftUI

// R12: Community & Social Features View
struct CommunityView: View {
    @State private var socialService = BunkerR12Service.shared
    @State private var selectedTab: CommunityTab = .teams
    @State private var showingNewDecision = false
    @State private var showingNewQuestion = false
    @State private var showingNewPartner = false

    enum CommunityTab: String, CaseIterable {
        case teams = "Teams"
        case wisdom = "Wisdom"
        case accountability = "Accountability"
        case questions = "Help Me"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bunkerBackground
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Picker("", selection: $selectedTab) {
                        ForEach(CommunityTab.allCases, id: \.self) { tab in
                            Text(tab.rawValue).tag(tab)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.xs)

                    ScrollView {
                        switch selectedTab {
                        case .teams:
                            teamDecisionsView
                        case .wisdom:
                            wisdomView
                        case .accountability:
                            accountabilityView
                        case .questions:
                            questionsView
                        }
                    }
                }
            }
            .navigationTitle("Community")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            showingNewDecision = true
                        } label: {
                            Label("Team Decision", systemImage: "person.3")
                        }
                        Button {
                            showingNewQuestion = true
                        } label: {
                            Label("Ask Community", systemImage: "bubble.left")
                        }
                        Button {
                            showingNewPartner = true
                        } label: {
                            Label("Add Partner", systemImage: "hand.raised")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Color.bunkerAccent)
                    }
                }
            }
            .sheet(isPresented: $showingNewDecision) {
                NewTeamDecisionSheet(socialService: socialService)
            }
            .sheet(isPresented: $showingNewQuestion) {
                NewQuestionSheet(socialService: socialService)
            }
            .sheet(isPresented: $showingNewPartner) {
                NewPartnerSheet(socialService: socialService)
            }
            .onAppear {
                socialService.loadDemoData()
            }
        }
    }

    // MARK: - Team Decisions View

    private var teamDecisionsView: some View {
        LazyVStack(spacing: Spacing.md) {
            ForEach(socialService.teamDecisions) { decision in
                TeamDecisionCard(decision: decision, socialService: socialService)
            }

            if socialService.teamDecisions.isEmpty {
                emptyTeamDecisionsView
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.top, Spacing.sm)
    }

    private var emptyTeamDecisionsView: some View {
        emptyStateView(
            icon: "person.3",
            title: "No team decisions",
            subtitle: "Collaborate with your team to make better decisions together",
            buttonTitle: "Create Decision",
            action: { showingNewDecision = true }
        )
    }

    // MARK: - Community Wisdom View

    private var wisdomView: some View {
        LazyVStack(spacing: Spacing.md) {
            ForEach(socialService.decisionDatabase) { decisionCase in
                DecisionCaseCard(decisionCase: decisionCase, socialService: socialService)
            }

            if socialService.decisionDatabase.isEmpty {
                emptyWisdomView
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.top, Spacing.sm)
    }

    private var emptyWisdomView: some View {
        emptyStateView(
            icon: "lightbulb",
            title: "No decision cases yet",
            subtitle: "Learn from others' decisions and share your own experiences",
            buttonTitle: nil,
            action: nil
        )
    }

    // MARK: - Accountability View

    private var accountabilityView: some View {
        LazyVStack(spacing: Spacing.md) {
            ForEach(socialService.accountabilityPartners) { partner in
                AccountabilityPartnerCard(partner: partner, socialService: socialService)
            }

            if socialService.accountabilityPartners.isEmpty {
                emptyAccountabilityView
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.top, Spacing.sm)
    }

    private var emptyAccountabilityView: some View {
        emptyStateView(
            icon: "hand.raised",
            title: "No accountability partners",
            subtitle: "Add a partner to stay accountable for your decisions",
            buttonTitle: "Add Partner",
            action: { showingNewPartner = true }
        )
    }

    // MARK: - Help Me Decide View

    private var questionsView: some View {
        LazyVStack(spacing: Spacing.md) {
            ForEach(socialService.communityQuestions) { question in
                CommunityQuestionCard(question: question, socialService: socialService)
            }

            if socialService.communityQuestions.isEmpty {
                emptyQuestionsView
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.top, Spacing.sm)
    }

    private var emptyQuestionsView: some View {
        emptyStateView(
            icon: "bubble.left",
            title: "No questions yet",
            subtitle: "Ask the community to help you make your next decision",
            buttonTitle: "Ask Question",
            action: { showingNewQuestion = true }
        )
    }

    // MARK: - Empty State Helper

    private func emptyStateView(icon: String, title: String, subtitle: String, buttonTitle: String?, action: (() -> Void)?) -> some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(Color.bunkerAccent.opacity(0.5))

            Text(title)
                .font(.headline)
                .foregroundStyle(Color.bunkerTextPrimary)

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(Color.bunkerTextSecondary)
                .multilineTextAlignment(.center)

            if let buttonTitle = buttonTitle, let action = action {
                Button(action: action) {
                    Text(buttonTitle)
                        .font(.headline)
                        .foregroundStyle(Color.bunkerBackground)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.bunkerAccent)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.vertical, 48)
    }
}

// MARK: - Team Decision Card

struct TeamDecisionCard: View {
    let decision: BunkerR12Service.TeamDecision
    @ObservedObject var socialService: BunkerR12Service

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(decision.title)
                        .font(.headline)
                        .foregroundStyle(Color.bunkerTextPrimary)

                    Text("\(decision.teamMemberIds.count) members")
                        .font(.caption)
                        .foregroundStyle(Color.bunkerTextTertiary)
                }

                Spacer()

                statusBadge
            }

            if !decision.description.isEmpty {
                Text(decision.description)
                    .font(.subheadline)
                    .foregroundStyle(Color.bunkerTextSecondary)
                    .lineLimit(2)
            }

            Divider()
                .background(Color.bunkerDivider)

            ForEach(decision.options) { option in
                let voteCount = decision.votes.filter { $0.optionId == option.id }.count

                Button {
                    socialService.vote(on: decision.id, optionId: option.id)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(option.title)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(Color.bunkerTextPrimary)

                            if !option.description.isEmpty {
                                Text(option.description)
                                    .font(.caption)
                                    .foregroundStyle(Color.bunkerTextTertiary)
                            }
                        }

                        Spacer()

                        Text("\(voteCount)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.bunkerAccent)

                        Image(systemName: "checkmark.circle")
                            .foregroundStyle(Color.bunkerAccent)
                    }
                    .padding(Spacing.sm)
                    .background(Color.bunkerSurfaceCard)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }

            Button {
                socialService.deleteTeamDecision(decision.id)
            } label: {
                Label("Delete", systemImage: "trash")
                    .font(.caption)
                    .foregroundStyle(Color.bunkerError)
            }
        }
        .padding(Spacing.md)
        .background(Color.bunkerSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var statusBadge: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(statusColor)
                .frame(width: 6, height: 6)
            Text(decision.status.rawValue.capitalized)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundStyle(statusColor)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(statusColor.opacity(0.15))
        .clipShape(Capsule())
    }

    private var statusColor: Color {
        switch decision.status {
        case .open, .voting: return Color.bunkerAccent
        case .decided: return Color.bunkerSuccess
        case .expired: return Color.bunkerTextTertiary
        }
    }
}

// MARK: - Community Question Card

struct CommunityQuestionCard: View {
    let question: BunkerR12Service.CommunityQuestion
    @ObservedObject var socialService: BunkerR12Service
    @State private var selectedOption: Int?
    @State private var reasoning = ""

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Circle()
                    .fill(Color.bunkerPrimary.opacity(0.3))
                    .frame(width: 32, height: 32)
                    .overlay {
                        Text(String(question.displayName.prefix(1)))
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.bunkerPrimary)
                    }

                VStack(alignment: .leading, spacing: 2) {
                    Text(question.displayName)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.bunkerTextPrimary)

                    Text(question.category.rawValue)
                        .font(.caption2)
                        .foregroundStyle(Color.bunkerPrimary)
                }

                Spacer()

                Text("\(question.responses.count) responses")
                    .font(.caption)
                    .foregroundStyle(Color.bunkerTextTertiary)
            }

            Text(question.question)
                .font(.headline)
                .foregroundStyle(Color.bunkerTextPrimary)

            ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                let responseCount = question.responses.filter { $0.selectedOption == index }.count

                Button {
                    selectedOption = index
                } label: {
                    HStack {
                        Text(option)
                            .font(.subheadline)
                            .foregroundStyle(Color.bunkerTextPrimary)

                        Spacer()

                        if responseCount > 0 {
                            Text("\(responseCount)")
                                .font(.caption)
                                .foregroundStyle(Color.bunkerTextTertiary)
                        }

                        Image(systemName: selectedOption == index ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(selectedOption == index ? Color.bunkerAccent : Color.bunkerTextTertiary)
                    }
                    .padding(Spacing.sm)
                    .background(selectedOption == index ? Color.bunkerAccent.opacity(0.1) : Color.bunkerSurfaceCard)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }

            if selectedOption != nil {
                TextField("Reasoning (optional)", text: $reasoning)
                    .textFieldStyle(.plain)
                    .font(.caption)
                    .padding(Spacing.sm)
                    .background(Color.bunkerSurfaceCard)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                Button {
                    if let option = selectedOption {
                        socialService.respondToQuestion(question.id, optionIndex: option, reasoning: reasoning.isEmpty ? nil : reasoning)
                        selectedOption = nil
                        reasoning = ""
                    }
                } label: {
                    Text("Submit Response")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.bunkerBackground)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.bunkerAccent)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.bunkerSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Accountability Partner Card

struct AccountabilityPartnerCard: View {
    let partner: BunkerR12Service.AccountabilityPartner
    @ObservedObject var socialService: BunkerR12Service
    @State private var newCommitment = ""

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Partner: \(partner.partnerName)")
                        .font(.headline)
                        .foregroundStyle(Color.bunkerTextPrimary)

                    HStack(spacing: 4) {
                        Circle()
                            .fill(partner.status == .active ? Color.bunkerSuccess : Color.bunkerTextTertiary)
                            .frame(width: 6, height: 6)
                        Text(partner.status.rawValue.capitalized)
                            .font(.caption)
                            .foregroundStyle(partner.status == .active ? Color.bunkerSuccess : Color.bunkerTextTertiary)
                    }
                }

                Spacer()

                Button {
                    socialService.removePartner(partner.id)
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption)
                        .foregroundStyle(Color.bunkerError)
                }
            }

            Divider()
                .background(Color.bunkerDivider)

            ForEach(partner.commitments) { commitment in
                HStack {
                    Image(systemName: commitment.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(commitment.isCompleted ? Color.bunkerSuccess : Color.bunkerTextTertiary)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(commitment.description)
                            .font(.subheadline)
                            .foregroundStyle(commitment.isCompleted ? Color.bunkerTextTertiary : Color.bunkerTextPrimary)
                            .strikethrough(commitment.isCompleted)

                        if let targetDate = commitment.targetDate {
                            Text("Due: \(targetDate.formatted(date: .abbreviated, time: .omitted))")
                                .font(.caption2)
                                .foregroundStyle(Color.bunkerTextTertiary)
                        }
                    }

                    Spacer()

                    if !commitment.isCompleted {
                        Button {
                            socialService.completeCommitment(partnerId: partner.id, commitmentId: commitment.id)
                        } label: {
                            Text("Done")
                                .font(.caption)
                                .foregroundStyle(Color.bunkerAccent)
                        }
                    }
                }
                .padding(.vertical, 4)
            }

            HStack {
                TextField("New commitment...", text: $newCommitment)
                    .textFieldStyle(.plain)
                    .font(.caption)
                    .padding(Spacing.xs)
                    .background(Color.bunkerSurfaceCard)
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                Button {
                    if !newCommitment.isEmpty {
                        socialService.addCommitment(to: partner.id, description: newCommitment)
                        newCommitment = ""
                    }
                } label: {
                    Image(systemName: "plus.circle")
                        .foregroundStyle(Color.bunkerAccent)
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.bunkerSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Decision Case Card

struct DecisionCaseCard: View {
    let decisionCase: BunkerR12Service.DecisionCase
    @ObservedObject var socialService: BunkerR12Service

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(decisionCase.title)
                        .font(.headline)
                        .foregroundStyle(Color.bunkerTextPrimary)

                    Text(decisionCase.category)
                        .font(.caption2)
                        .foregroundStyle(Color.bunkerPrimary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.bunkerPrimary.opacity(0.15))
                        .clipShape(Capsule())
                }

                Spacer()
            }

            Text(decisionCase.description)
                .font(.subheadline)
                .foregroundStyle(Color.bunkerTextSecondary)
                .lineLimit(3)

            Divider()
                .background(Color.bunkerDivider)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Outcome")
                        .font(.caption2)
                        .foregroundStyle(Color.bunkerTextTertiary)
                    Text(decisionCase.outcome)
                        .font(.caption)
                        .foregroundStyle(Color.bunkerSuccess)
                        .lineLimit(2)
                }

                Spacer()

                HStack(spacing: Spacing.sm) {
                    Button {
                        socialService.voteHelpful(decisionCase.id)
                    } label: {
                        HStack(spacing: 2) {
                            Image(systemName: "hand.thumbsup")
                            Text("\(decisionCase.votesHelpful)")
                        }
                        .font(.caption)
                        .foregroundStyle(Color.bunkerAccent)
                    }
                    .buttonStyle(.plain)

                    Button {
                        socialService.voteNotHelpful(decisionCase.id)
                    } label: {
                        HStack(spacing: 2) {
                            Image(systemName: "hand.thumbsdown")
                            Text("\(decisionCase.votesNotHelpful)")
                        }
                        .font(.caption)
                        .foregroundStyle(Color.bunkerTextTertiary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.bunkerSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - New Team Decision Sheet

struct NewTeamDecisionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var socialService: BunkerR12Service
    @State private var title = ""
    @State private var description = ""
    @State private var option1 = ""
    @State private var option2 = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bunkerBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Spacing.md) {
                        TextField("Decision Title", text: $title)
                            .textFieldStyle(.plain)
                            .padding(Spacing.md)
                            .background(Color.bunkerSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                        TextField("Description (optional)", text: $description, axis: .vertical)
                            .textFieldStyle(.plain)
                            .lineLimit(2...4)
                            .padding(Spacing.md)
                            .background(Color.bunkerSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("Options")
                                .font(.caption)
                                .foregroundStyle(Color.bunkerTextTertiary)

                            TextField("Option 1", text: $option1)
                                .textFieldStyle(.plain)
                                .padding(Spacing.md)
                                .background(Color.bunkerSurface)
                                .clipShape(RoundedRectangle(cornerRadius: 12))

                            TextField("Option 2", text: $option2)
                                .textFieldStyle(.plain)
                                .padding(Spacing.md)
                                .background(Color.bunkerSurface)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(Spacing.md)
                }
            }
            .navigationTitle("Team Decision")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        let options = [option1, option2].filter { !$0.isEmpty }
                        _ = socialService.createTeamDecision(title: title, description: description, options: options)
                        dismiss()
                    }
                    .disabled(title.isEmpty || option1.isEmpty || option2.isEmpty)
                }
            }
        }
    }
}

// MARK: - New Question Sheet

struct NewQuestionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var socialService: BunkerR12Service
    @State private var question = ""
    @State private var option1 = ""
    @State private var option2 = ""
    @State private var option3 = ""
    @State private var category: BunkerR12Service.CommunityQuestion.QuestionCategory = .other
    @State private var isAnonymous = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bunkerBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Spacing.md) {
                        TextField("What decision are you facing?", text: $question, axis: .vertical)
                            .textFieldStyle(.plain)
                            .lineLimit(2...4)
                            .padding(Spacing.md)
                            .background(Color.bunkerSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                        Picker("Category", selection: $category) {
                            ForEach(BunkerR12Service.CommunityQuestion.QuestionCategory.allCases, id: \.self) { cat in
                                Text(cat.rawValue).tag(cat)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding(Spacing.md)
                        .background(Color.bunkerSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("Options")
                                .font(.caption)
                                .foregroundStyle(Color.bunkerTextTertiary)

                            TextField("Option 1", text: $option1)
                                .textFieldStyle(.plain)
                                .padding(Spacing.md)
                                .background(Color.bunkerSurface)
                                .clipShape(RoundedRectangle(cornerRadius: 12))

                            TextField("Option 2", text: $option2)
                                .textFieldStyle(.plain)
                                .padding(Spacing.md)
                                .background(Color.bunkerSurface)
                                .clipShape(RoundedRectangle(cornerRadius: 12))

                            TextField("Option 3 (optional)", text: $option3)
                                .textFieldStyle(.plain)
                                .padding(Spacing.md)
                                .background(Color.bunkerSurface)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        Toggle("Post Anonymously", isOn: $isAnonymous)
                            .tint(Color.bunkerAccent)
                            .padding(.horizontal, Spacing.xs)
                    }
                    .padding(Spacing.md)
                }
            }
            .navigationTitle("Ask Community")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ask") {
                        let options = [option1, option2, option3].filter { !$0.isEmpty }
                        _ = socialService.askQuestion(question: question, options: options, category: category, isAnonymous: isAnonymous)
                        dismiss()
                    }
                    .disabled(question.isEmpty || option1.isEmpty || option2.isEmpty)
                }
            }
        }
    }
}

// MARK: - New Partner Sheet

struct NewPartnerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var socialService: BunkerR12Service
    @State private var name = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bunkerBackground.ignoresSafeArea()

                VStack(spacing: Spacing.lg) {
                    TextField("Partner Name", text: $name)
                        .textFieldStyle(.plain)
                        .padding(Spacing.md)
                        .background(Color.bunkerSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    Spacer()
                }
                .padding(Spacing.md)
            }
            .navigationTitle("Add Partner")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        _ = socialService.addPartner(name: name)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

#Preview {
    CommunityView()
        .preferredColorScheme(.dark)
}
