import SwiftUI

struct MacDecisionEditorView: View {
    let decisionId: UUID
    @Binding var allDecisions: [Decision]
    @State private var outcomes: [Outcome] = []
    @State private var isLoadingOutcomes = false
    @State private var showAddCriteria = false
    @State private var showAddOption = false
    @State private var showSettings = false
    @State private var aiInsight = ""
    @State private var newCriteriaName = ""
    @State private var newCriteriaImportance = 5
    @State private var newOptionName = ""
    @State private var showAIAnalysis = false

    private let service = DecisionService.shared
    private let aiService = AIAnalysisService.shared
    private let decisionAdviceService = AIDecisionService.shared

    private var decisionBinding: Binding<Decision> {
        Binding(
            get: { allDecisions.first(where: { $0.id == decisionId }) ?? Decision.empty },
            set: { newValue in
                if let idx = allDecisions.firstIndex(where: { $0.id == decisionId }) {
                    allDecisions[idx] = newValue
                }
            }
        )
    }

    private var decision: Decision {
        allDecisions.first(where: { $0.id == decisionId }) ?? Decision.empty
    }

    var body: some View {
        VStack(spacing: 0) {
            headerBar

            Divider()
                .background(BunkerColors.divider)

            ScrollView {
                VStack(spacing: 24) {
                    titleSection
                    metaSection

                    Divider()
                        .background(BunkerColors.divider)

                    criteriaSection

                    Divider()
                        .background(BunkerColors.divider)

                    optionsSection

                    Divider()
                        .background(BunkerColors.divider)

                    aiAnalysisSection

                    if showOutcomeSimulator {
                        outcomeSimulatorSection
                    }
                }
                .padding(24)
            }
            .background(BunkerColors.background)
        }
        .background(BunkerColors.background)
        .onAppear {
            refreshInsight()
            loadOutcomes()
        }
        .sheet(isPresented: $showAddCriteria) {
            addCriteriaSheet
        }
        .sheet(isPresented: $showAddOption) {
            addOptionSheet
        }
        .sheet(isPresented: $showAIAnalysis) {
            MacAIAnalysisView(decision: decision)
        }
    }

    @State private var showOutcomeSimulator = false

    // MARK: - Header Bar
    private var headerBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(decision.title.isEmpty ? "New Decision" : decision.title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(BunkerColors.textPrimary)
                Text("AI Decision Workspace")
                    .font(.system(size: 12))
                    .foregroundColor(BunkerColors.textTertiary)
            }
            Spacer()

            HStack(spacing: 12) {
                Button {
                    Task { await saveDecision() }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.down")
                        Text("Save")
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(BunkerColors.textPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(BunkerColors.surfaceSecondary)
                    .cornerRadius(6)
                }
                .buttonStyle(.plain)

                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape")
                        .foregroundColor(BunkerColors.textSecondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(BunkerColors.surface)
    }

    // MARK: - Title Section
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("DECISION")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(BunkerColors.primary)

            VStack(spacing: 8) {
                TextField("Decision title", text: binding(for: \.title))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(BunkerColors.textPrimary)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(BunkerColors.surfaceSecondary)
                    .cornerRadius(8)

                TextField("Describe the decision context...", text: binding(for: \.description), axis: .vertical)
                    .font(.system(size: 14))
                    .foregroundColor(BunkerColors.textSecondary)
                    .textFieldStyle(.plain)
                    .lineLimit(3...6)
                    .padding(12)
                    .background(BunkerColors.surfaceSecondary)
                    .cornerRadius(8)
            }
        }
    }

    private func binding<T>(for keyPath: WritableKeyPath<Decision, T>) -> Binding<T> {
        Binding(
            get: { decision[keyPath: keyPath] },
            set: { newValue in
                if let idx = allDecisions.firstIndex(where: { $0.id == decisionId }) {
                    allDecisions[idx][keyPath: keyPath] = newValue
                }
            }
        )
    }

    // MARK: - Meta Section
    private var metaSection: some View {
        HStack(spacing: 16) {
            metaCard(title: "Stake", value: decision.stake.rawValue, color: stakeColor)
            metaCard(title: "Reversibility", value: decision.reversibility.rawValue, color: BunkerColors.textSecondary)
            metaCard(title: "Time Horizon", value: decision.timeHorizon.rawValue, color: BunkerColors.textSecondary)
            Spacer()
        }
    }

    private func metaCard(title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(BunkerColors.textTertiary)
            Text(value)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(color)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(BunkerColors.surfaceSecondary)
        .cornerRadius(6)
    }

    private var stakeColor: Color {
        switch decision.stake {
        case .low: return BunkerColors.success
        case .medium: return BunkerColors.warning
        case .high: return Color.orange
        case .critical: return BunkerColors.error
        }
    }

    // MARK: - Criteria Section
    private var criteriaSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("CRITERIA")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(BunkerColors.primary)
                Spacer()
                Button {
                    showAddCriteria = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text("Add")
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(BunkerColors.accent)
                }
                .buttonStyle(.plain)
            }

            if decision.criteria.isEmpty {
                emptyStateCard(
                    icon: "checklist",
                    title: "No criteria yet",
                    subtitle: "Add what matters to this decision"
                )
            } else {
                VStack(spacing: 6) {
                    ForEach(Array(decision.criteria.enumerated()), id: \.element.id) { index, criteria in
                        MacCriteriaRow(
                            criteria: criteria,
                            options: decision.options,
                            decisionId: decision.id,
                            criteriaIndex: index,
                            onScoreChange: { optIdx, score in
                                Task { await scoreCriteria(criteriaIndex: index, optionIndex: optIdx, score: score) }
                            },
                            onDelete: {
                                Task { await removeCriteria(at: index) }
                            }
                        )
                    }
                }
            }
        }
    }

    // MARK: - Options Section
    private var optionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("OPTIONS")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(BunkerColors.primary)
                Spacer()
                Button {
                    showAddOption = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text("Add")
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(BunkerColors.accent)
                }
                .buttonStyle(.plain)
            }

            if decision.options.isEmpty {
                emptyStateCard(
                    icon: "square.stack.3d.up",
                    title: "No options yet",
                    subtitle: "Define what you're choosing between"
                )
            } else {
                VStack(spacing: 8) {
                    ForEach(Array(decision.options.enumerated()), id: \.offset) { index, option in
                        MacOptionRow(
                            option: option,
                            criteria: decision.criteria,
                            decisionId: decision.id,
                            optionIndex: index,
                            onScoreChange: { critIdx, score in
                                Task { await scoreCriteria(criteriaIndex: critIdx, optionIndex: index, score: score) }
                            },
                            onDelete: {
                                Task { await removeOption(at: index) }
                            }
                        )
                    }
                }
            }
        }
    }

    // MARK: - AI Analysis Section
    private var aiAnalysisSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("AI ANALYSIS")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(BunkerColors.accent)
                Spacer()
                Button {
                    showAIAnalysis = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "brain")
                        Text("Deep Analysis")
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(BunkerColors.accent)
                }
                .buttonStyle(.plain)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(aiInsight.isEmpty ? "Add criteria and options to get AI insights..." : aiInsight)
                    .font(.system(size: 13))
                    .foregroundColor(aiInsight.isEmpty ? BunkerColors.textTertiary : BunkerColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(BunkerColors.surfaceSecondary)
                    .cornerRadius(8)
            }

            if !outcomes.isEmpty {
                recommendationCard
            }
        }
    }

    private var recommendationCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("RECOMMENDATION")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(BunkerColors.success)

            if let top = outcomes.first {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(top.option)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(BunkerColors.textPrimary)
                        Text("Score: \(String(format: "%.1f", top.weightedScore)) • Confidence: \(Int(top.confidence))%")
                            .font(.system(size: 12))
                            .foregroundColor(BunkerColors.textSecondary)
                    }
                    Spacer()
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 24))
                        .foregroundColor(BunkerColors.success)
                }
                .padding(12)
                .background(BunkerColors.success.opacity(0.1))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(BunkerColors.success.opacity(0.3), lineWidth: 1)
                )
            }
        }
    }

    // MARK: - Outcome Simulator Section
    private var outcomeSimulatorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("OUTCOME SIMULATION")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(BunkerColors.accent)
                Spacer()
                if isLoadingOutcomes {
                    ProgressView()
                        .scaleEffect(0.7)
                } else {
                    Button {
                        Task { await simulateOutcomes() }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "play.fill")
                            Text("Simulate")
                        }
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(BunkerColors.accent)
                    }
                    .buttonStyle(.plain)
                }
            }

            if outcomes.isEmpty {
                emptyStateCard(
                    icon: "chart.bar.xaxis",
                    title: "No outcomes yet",
                    subtitle: "Score your criteria to simulate outcomes"
                )
            } else {
                VStack(spacing: 8) {
                    ForEach(outcomes) { outcome in
                        outcomeRow(outcome: outcome, rank: outcomes.firstIndex(where: { $0.id == outcome.id }) ?? 0)
                    }
                }
            }
        }
    }

    private func outcomeRow(outcome: Outcome, rank: Int) -> some View {
        HStack {
            Text("#\(rank + 1)")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(rank == 0 ? BunkerColors.success : BunkerColors.textTertiary)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(outcome.option)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(BunkerColors.textPrimary)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(BunkerColors.surfaceSecondary)
                            .frame(height: 4)
                        Rectangle()
                            .fill(rank == 0 ? BunkerColors.accent : BunkerColors.primary)
                            .frame(width: geo.size.width * (outcome.weightedScore / 10.0), height: 4)
                    }
                    .cornerRadius(2)
                }
                .frame(height: 4)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "%.1f", outcome.weightedScore))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(BunkerColors.textPrimary)
                Text("\(Int(outcome.confidence))% conf")
                    .font(.system(size: 11))
                    .foregroundColor(BunkerColors.textTertiary)
            }
        }
        .padding(12)
        .background(BunkerColors.surfaceSecondary)
        .cornerRadius(8)
    }

    // MARK: - Sheets
    private var addCriteriaSheet: some View {
        VStack(spacing: 16) {
            Text("Add Criteria")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(BunkerColors.textPrimary)

            TextField("Criteria name (e.g., Cost, Quality)", text: $newCriteriaName)
                .textFieldStyle(.plain)
                .padding(10)
                .background(BunkerColors.surfaceSecondary)
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Importance")
                        .font(.system(size: 13))
                        .foregroundColor(BunkerColors.textSecondary)
                    Spacer()
                    Text("\(newCriteriaImportance)/10")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(BunkerColors.primary)
                }
                Slider(value: Binding(
                    get: { Double(newCriteriaImportance) },
                    set: { newCriteriaImportance = Int($0) }
                ), in: 1...10, step: 1)
                .accentColor(BunkerColors.primary)
            }

            HStack(spacing: 12) {
                Button("Cancel") {
                    showAddCriteria = false
                    newCriteriaName = ""
                }
                .foregroundColor(BunkerColors.textSecondary)

                Spacer()

                Button("Add") {
                    Task { await addCriteria() }
                    showAddCriteria = false
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(BunkerColors.textPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(BunkerColors.primary)
                .cornerRadius(8)
            }
        }
        .padding(20)
        .frame(width: 360)
        .background(BunkerColors.surface)
    }

    private var addOptionSheet: some View {
        VStack(spacing: 16) {
            Text("Add Option")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(BunkerColors.textPrimary)

            TextField("Option name (e.g., Option A)", text: $newOptionName)
                .textFieldStyle(.plain)
                .padding(10)
                .background(BunkerColors.surfaceSecondary)
                .cornerRadius(8)

            HStack(spacing: 12) {
                Button("Cancel") {
                    showAddOption = false
                    newOptionName = ""
                }
                .foregroundColor(BunkerColors.textSecondary)

                Spacer()

                Button("Add") {
                    Task { await addOption() }
                    showAddOption = false
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(BunkerColors.textPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(BunkerColors.primary)
                .cornerRadius(8)
            }
        }
        .padding(20)
        .frame(width: 360)
        .background(BunkerColors.surface)
    }

    // MARK: - Helpers
    private func emptyStateCard(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(BunkerColors.textTertiary)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(BunkerColors.textSecondary)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(BunkerColors.textTertiary)
            }
            Spacer()
        }
        .padding(12)
        .background(BunkerColors.surfaceSecondary.opacity(0.5))
        .cornerRadius(8)
    }

    // MARK: - Actions
    private func saveDecision() async {
        await service.saveDecision(decision)
        refreshInsight()
    }

    private func addCriteria() async {
        guard !newCriteriaName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        if let idx = allDecisions.firstIndex(where: { $0.id == decisionId }) {
            let criteria = Criteria(name: newCriteriaName.trimmingCharacters(in: .whitespaces), importance: newCriteriaImportance)
            allDecisions[idx].criteria.append(criteria)
            allDecisions[idx].updatedAt = Date()
            await service.saveDecision(allDecisions[idx])
            newCriteriaName = ""
            newCriteriaImportance = 5
            refreshInsight()
        }
    }

    private func removeCriteria(at index: Int) async {
        if let idx = allDecisions.firstIndex(where: { $0.id == decisionId }) {
            guard allDecisions[idx].criteria.indices.contains(index) else { return }
            allDecisions[idx].criteria.remove(at: index)
            allDecisions[idx].updatedAt = Date()
            await service.saveDecision(allDecisions[idx])
            refreshInsight()
        }
    }

    private func addOption() async {
        guard !newOptionName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        if let idx = allDecisions.firstIndex(where: { $0.id == decisionId }) {
            allDecisions[idx].options.append(newOptionName.trimmingCharacters(in: .whitespaces))
            allDecisions[idx].updatedAt = Date()
            await service.saveDecision(allDecisions[idx])
            newOptionName = ""
            refreshInsight()
        }
    }

    private func removeOption(at index: Int) async {
        if let idx = allDecisions.firstIndex(where: { $0.id == decisionId }) {
            guard allDecisions[idx].options.indices.contains(index) else { return }
            allDecisions[idx].options.remove(at: index)
            allDecisions[idx].updatedAt = Date()
            await service.saveDecision(allDecisions[idx])
            refreshInsight()
        }
    }

    private func scoreCriteria(criteriaIndex: Int, optionIndex: Int, score: Int) async {
        if let idx = allDecisions.firstIndex(where: { $0.id == decisionId }) {
            guard allDecisions[idx].criteria.indices.contains(criteriaIndex),
                  allDecisions[idx].options.indices.contains(optionIndex) else { return }
            let optionId = UUID(uuidString: "\(decision.id.uuidString)-\(optionIndex)") ?? UUID()
            allDecisions[idx].criteria[criteriaIndex].setScore(score, for: optionId)
            allDecisions[idx].updatedAt = Date()
            await service.saveDecision(allDecisions[idx])
            loadOutcomes()
        }
    }

    private func simulateOutcomes() async {
        isLoadingOutcomes = true
        outcomes = await service.simulateOutcomes(for: decision)
        isLoadingOutcomes = false
    }

    private func loadOutcomes() {
        Task {
            outcomes = await service.simulateOutcomes(for: decision)
        }
    }

    private func refreshInsight() {
        aiInsight = aiService.generateInsight(for: decision)
    }
}
