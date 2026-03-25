import SwiftUI

@MainActor struct DecisionDetailView: View {
    @State private var viewModel: DecisionDetailViewModel
    @Environment(\.dismiss) private var dismiss

    init(decision: Decision) {
        _viewModel = State(initialValue: DecisionDetailViewModel(decision: decision))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                headerSection
                insightCard
                if !viewModel.decision.options.isEmpty || !viewModel.decision.criteria.isEmpty {
                    dashboardSection
                }
                criteriaSection
                optionsSection
                if !viewModel.decision.options.isEmpty && !viewModel.decision.criteria.isEmpty {
                    scoringSection
                }
                if !viewModel.outcomes.isEmpty {
                    outcomesSection
                }
                Spacer(minLength: Spacing.xxl)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.md)
        }
        .background(Color.bunkerBackground)
        .navigationTitle("Decision")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    Task { await viewModel.simulateOutcomes() }
                } label: {
                    Label("Simulate", systemImage: "play.fill")
                        .font(.bunkerBodySmall)
                }
                .disabled(viewModel.decision.criteria.isEmpty || viewModel.decision.options.isEmpty)

                Menu {
                    Button {
                        viewModel.showShare = true
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }

                    Button(role: .destructive) {
                        viewModel.showDeleteConfirmation = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.bunkerBodySmall)
                }
            }
        }
        .confirmationDialog(
            "Delete Decision",
            isPresented: $viewModel.showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                Task {
                    await viewModel.delete()
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete \"\(viewModel.decision.title)\" and all its data. This cannot be undone.")
        }
        .sheet(isPresented: $viewModel.showShare) {
            ShareDecisionView(decision: viewModel.decision, outcomes: viewModel.outcomes)
        }
        .refreshable {
            await viewModel.refresh()
        }
        .sheet(isPresented: addCriteriaBinding) {
            AddCriteriaSheet(viewModel: viewModel)
        }
        .sheet(isPresented: addOptionBinding) {
            AddOptionSheet(viewModel: viewModel)
        }
        .sheet(isPresented: showScoringBinding) {
            scoringSheetContent
        }
        .onChange(of: viewModel.decision) { _, _ in
            Task { await viewModel.save() }
        }
    }

    private var addCriteriaBinding: Binding<Bool> {
        Binding(get: { viewModel.showAddCriteria },
                set: { viewModel.showAddCriteria = $0 })
    }

    private var addOptionBinding: Binding<Bool> {
        Binding(get: { viewModel.showAddOption },
                set: { viewModel.showAddOption = $0 })
    }

    private var showScoringBinding: Binding<Bool> {
        Binding(get: { viewModel.showScoring },
                set: { viewModel.showScoring = $0 })
    }

    @ViewBuilder
    private var scoringSheetContent: some View {
        if let criteriaIndex = viewModel.scoringCriteriaIndex,
           let optionIndex = viewModel.scoringOptionIndex {
            ScoringSheet(
                viewModel: viewModel,
                criteriaIndex: criteriaIndex,
                optionIndex: optionIndex
            )
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            TextField("Decision Title", text: Binding(
                get: { viewModel.decision.title },
                set: { viewModel.decision.title = $0 }
            ))
            .font(.bunkerHeading1)
            .foregroundStyle(Color.bunkerTextPrimary)

            TextField("Describe the decision context...", text: Binding(
                get: { viewModel.decision.description },
                set: { viewModel.decision.description = $0 }
            ), axis: .vertical)
            .font(.bunkerBody)
            .foregroundStyle(Color.bunkerTextSecondary)
            .lineLimit(3...6)

            // Deadline & Reminder row
            HStack(spacing: Spacing.sm) {
                deadlinePicker
                reminderPicker
            }

            // Stake framework row
            stakeFrameworkRow
        }
    }

    private var deadlinePicker: some View {
        HStack(spacing: Spacing.xxs) {
            Image(systemName: "calendar")
                .font(.bunkerCaption)
                .foregroundStyle(Color.bunkerAccent)

            DatePicker(
                "",
                selection: Binding(
                    get: { viewModel.decision.deadlineDate ?? Date() },
                    set: { viewModel.decision.deadlineDate = $0 }
                ),
                displayedComponents: .date
            )
            .labelsHidden()
            .font(.bunkerCaption)
            .tint(Color.bunkerAccent)

            if viewModel.decision.deadlineDate != nil {
                Button {
                    viewModel.decision.deadlineDate = nil
                    Task { await viewModel.save() }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.bunkerCaption)
                        .foregroundStyle(Color.bunkerTextTertiary)
                }
            }
        }
        .padding(Spacing.xs)
        .background(Color.bunkerSurface)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var reminderPicker: some View {
        HStack(spacing: Spacing.xxs) {
            Image(systemName: "bell")
                .font(.bunkerCaption)
                .foregroundStyle(Color.bunkerWarning)

            DatePicker(
                "",
                selection: Binding(
                    get: { viewModel.decision.reminderDate ?? Date() },
                    set: { viewModel.decision.reminderDate = $0 }
                ),
                displayedComponents: [.date, .hourAndMinute]
            )
            .labelsHidden()
            .font(.bunkerCaption)
            .tint(Color.bunkerWarning)

            if viewModel.decision.reminderDate != nil {
                Button {
                    viewModel.decision.reminderDate = nil
                    Task { await viewModel.save() }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.bunkerCaption)
                        .foregroundStyle(Color.bunkerTextTertiary)
                }
            }
        }
        .padding(Spacing.xs)
        .background(Color.bunkerSurface)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var stakeFrameworkRow: some View {
        HStack(spacing: Spacing.xs) {
            // Stake
            VStack(alignment: .leading, spacing: 2) {
                Text("Stake")
                    .font(.bunkerLabel)
                    .foregroundStyle(Color.bunkerTextTertiary)
                Picker("Stake", selection: Binding(
                    get: { viewModel.decision.stake },
                    set: { viewModel.decision.stake = $0; Task { await viewModel.save() } }
                )) {
                    ForEach(StakeLevel.allCases, id: \.self) { level in
                        Text(level.rawValue).tag(level)
                    }
                }
                .pickerStyle(.menu)
                .tint(Color(hex: viewModel.decision.stake.color))
            }

            Divider()
                .frame(height: 30)
                .background(Color.bunkerDivider)

            // Reversibility
            VStack(alignment: .leading, spacing: 2) {
                Text("Reversibility")
                    .font(.bunkerLabel)
                    .foregroundStyle(Color.bunkerTextTertiary)
                Picker("Reversibility", selection: Binding(
                    get: { viewModel.decision.reversibility },
                    set: { viewModel.decision.reversibility = $0; Task { await viewModel.save() } }
                )) {
                    ForEach(Reversibility.allCases, id: \.self) { level in
                        Text(level.rawValue).tag(level)
                    }
                }
                .pickerStyle(.menu)
                .tint(Color.bunkerTextSecondary)
            }

            Divider()
                .frame(height: 30)
                .background(Color.bunkerDivider)

            // Time Horizon
            VStack(alignment: .leading, spacing: 2) {
                Text("Horizon")
                    .font(.bunkerLabel)
                    .foregroundStyle(Color.bunkerTextTertiary)
                Picker("TimeHorizon", selection: Binding(
                    get: { viewModel.decision.timeHorizon },
                    set: { viewModel.decision.timeHorizon = $0; Task { await viewModel.save() } }
                )) {
                    ForEach(TimeHorizon.allCases, id: \.self) { level in
                        Text(level.rawValue).tag(level)
                    }
                }
                .pickerStyle(.menu)
                .tint(Color.bunkerTextSecondary)
            }
        }
        .padding(Spacing.sm)
        .background(Color.bunkerSurface)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var dashboardSection: some View {
        DecisionDashboardView(decision: viewModel.decision, outcomes: viewModel.outcomes)
    }

    private var insightCard: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundStyle(Color.bunkerAccent)
                Text("Bunker Analysis")
                    .font(.bunkerLabel)
                    .foregroundStyle(Color.bunkerAccent)
                Spacer()

                Button {
                    Task { await viewModel.generateAIAdvice() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.bunkerCaption)
                        .foregroundStyle(Color.bunkerAccent)
                }
            }

            Text(viewModel.aiInsight.isEmpty ? "Add options and criteria to get AI analysis..." : viewModel.aiInsight)
                .font(.bunkerBodySmall)
                .foregroundStyle(viewModel.aiInsight.isEmpty ? Color.bunkerTextTertiary : Color.bunkerTextSecondary)
                .lineLimit(6)

            // Show full AI advice if available
            if let aiAdvice = viewModel.decision.aiAdvice, !aiAdvice.isEmpty {
                Divider()
                    .background(Color.bunkerDivider.opacity(0.3))

                Text(aiAdvice)
                    .font(.bunkerCaption)
                    .foregroundStyle(Color.bunkerTextSecondary)
                    .lineLimit(8)
            }
        }
        .padding(Spacing.md)
        .background(Color.bunkerAccent.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.bunkerAccent.opacity(0.3), lineWidth: 1)
        )
    }

    private var criteriaSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text("Criteria")
                    .font(.bunkerHeading2)
                    .foregroundStyle(Color.bunkerTextPrimary)

                Spacer()

                Button {
                    viewModel.showAddCriteria = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Color.bunkerPrimary)
                }
            }

            if viewModel.decision.criteria.isEmpty {
                emptyCriteriaState
            } else {
                ForEach(Array(viewModel.decision.criteria.enumerated()), id: \.element.id) { index, criteria in
                    CriteriaRow(
                        criteria: criteria,
                        onDelete: {
                            Task { await viewModel.removeCriteria(at: index) }
                        }
                    )
                }
            }
        }
    }

    private var emptyCriteriaState: some View {
        VStack(spacing: Spacing.xs) {
            Image(systemName: "slider.horizontal.3")
                .font(.system(size: 32))
                .foregroundStyle(Color.bunkerTextTertiary)
            Text("Add what matters to this decision")
                .font(.bunkerBodySmall)
                .foregroundStyle(Color.bunkerTextTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.lg)
        .background(Color.bunkerSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var optionsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text("Options")
                    .font(.bunkerHeading2)
                    .foregroundStyle(Color.bunkerTextPrimary)

                Spacer()

                Button {
                    viewModel.showAddOption = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Color.bunkerPrimary)
                }
            }

            if viewModel.decision.options.isEmpty {
                emptyOptionsState
            } else {
                ForEach(Array(viewModel.decision.options.enumerated()), id: \.offset) { index, option in
                    OptionRow(
                        option: option,
                        onDelete: {
                            Task { await viewModel.removeOption(at: index) }
                        }
                    )
                }
            }
        }
    }

    private var emptyOptionsState: some View {
        VStack(spacing: Spacing.xs) {
            Image(systemName: "square.stack.3d.up")
                .font(.system(size: 32))
                .foregroundStyle(Color.bunkerTextTertiary)
            Text("Define what you're choosing between")
                .font(.bunkerBodySmall)
                .foregroundStyle(Color.bunkerTextTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.lg)
        .background(Color.bunkerSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var scoringSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Score Options")
                .font(.bunkerHeading2)
                .foregroundStyle(Color.bunkerTextPrimary)

            Text("Tap a cell to score how each option performs on a criteria.")
                .font(.bunkerCaption)
                .foregroundStyle(Color.bunkerTextTertiary)

            ScoringGrid(viewModel: viewModel)
        }
    }

    private var outcomesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text("Simulated Outcomes")
                    .font(.bunkerHeading2)
                    .foregroundStyle(Color.bunkerTextPrimary)

                Spacer()

                if viewModel.isLoadingOutcomes {
                    ProgressView()
                        .tint(Color.bunkerPrimary)
                        .scaleEffect(0.8)
                }
            }

            ForEach(Array(viewModel.outcomes.enumerated()), id: \.element.id) { index, outcome in
                OutcomeRow(outcome: outcome, rank: index + 1)
            }
        }
    }
}

// MARK: - Supporting Views

struct CriteriaRow: View {
    let criteria: Criteria
    let onDelete: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(criteria.name)
                    .font(.bunkerBody)
                    .foregroundStyle(Color.bunkerTextPrimary)

                HStack(spacing: Spacing.xxs) {
                    Text("Weight:")
                        .font(.bunkerCaption)
                        .foregroundStyle(Color.bunkerTextTertiary)
                    Text("\(criteria.importance)")
                        .font(.bunkerCaption)
                        .foregroundStyle(Color.bunkerPrimary)
                }
            }

            Spacer()

            if criteria.isScored {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color.bunkerSuccess)
            }

            Button(role: .destructive) {
                onDelete()
            } label: {
                Image(systemName: "trash")
                    .font(.bunkerCaption)
                    .foregroundStyle(Color.bunkerError)
            }
        }
        .padding(Spacing.sm)
        .background(Color.bunkerSurface)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct OptionRow: View {
    let option: String
    let onDelete: () -> Void

    var body: some View {
        HStack {
            Image(systemName: "square.stack.3d.up.fill")
                .font(.bunkerCaption)
                .foregroundStyle(Color.bunkerPrimary)

            Text(option)
                .font(.bunkerBody)
                .foregroundStyle(Color.bunkerTextPrimary)

            Spacer()

            Button(role: .destructive) {
                onDelete()
            } label: {
                Image(systemName: "trash")
                    .font(.bunkerCaption)
                    .foregroundStyle(Color.bunkerError)
            }
        }
        .padding(Spacing.sm)
        .background(Color.bunkerSurface)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct ScoringGrid: View {
    @Bindable var viewModel: DecisionDetailViewModel

    var body: some View {
        VStack(spacing: 2) {
            scoringHeader
            Divider().background(Color.bunkerDivider)
            criteriaRows
        }
        .padding(Spacing.sm)
        .background(Color.bunkerSurfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var scoringHeader: some View {
        HStack(spacing: 2) {
            Text("").frame(width: 80)
            ForEach(Array(viewModel.decision.options.enumerated()), id: \.offset) { _, option in
                Text(option)
                    .font(.bunkerCaption)
                    .foregroundColor(Color.bunkerTextSecondary)
                    .frame(maxWidth: .infinity)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .padding(.vertical, Spacing.xs)
    }

    private var criteriaRows: some View {
        ForEach(Array(viewModel.decision.criteria.enumerated()), id: \.element.id) { criteriaIndex, criteria in
            criteriaRow(criteria: criteria, criteriaIndex: criteriaIndex)
        }
    }

    private func criteriaRow(criteria: Criteria, criteriaIndex: Int) -> some View {
        HStack(spacing: 2) {
            Text(criteria.name)
                .font(.bunkerCaption)
                .foregroundColor(Color.bunkerTextPrimary)
                .frame(width: 80, alignment: .leading)
                .lineLimit(1)

            ForEach(Array(viewModel.decision.options.enumerated()), id: \.offset) { optionIndex, _ in
                scoreButton(criteriaIndex: criteriaIndex, optionIndex: optionIndex)
            }
        }
    }

    private func scoreButton(criteriaIndex: Int, optionIndex: Int) -> some View {
        let optionId = UUID(uuidString: "\(viewModel.decision.id.uuidString)-\(optionIndex)") ?? UUID()
        let score = viewModel.decision.criteria[criteriaIndex].score(for: optionId)
        let hasScore = score > 0

        return Button {
            viewModel.scoringCriteriaIndex = criteriaIndex
            viewModel.scoringOptionIndex = optionIndex
            viewModel.showScoring = true
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(hasScore ? Color.bunkerPrimary.opacity(Double(score) / 10.0 + 0.1) : Color.bunkerSurface)
                Text(hasScore ? "\(score)" : "—")
                    .font(.bunkerCaption)
                    .foregroundColor(hasScore ? Color.bunkerTextPrimary : Color.bunkerTextTertiary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 36)
        }
    }
}

struct OutcomeRow: View {
    let outcome: Outcome
    let rank: Int

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack {
                Text("#\(rank)")
                    .font(.bunkerLabel)
                    .foregroundStyle(Color.bunkerPrimary)
                    .frame(width: 28)

                Text(outcome.option)
                    .font(.bunkerHeading3)
                    .foregroundStyle(Color.bunkerTextPrimary)

                Spacer()

                Text("\(Int(outcome.confidence))%")
                    .font(.bunkerCaption)
                    .foregroundStyle(Color.bunkerTextTertiary)
            }

            // Score bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.bunkerSecondary)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(rank == 1 ? Color.bunkerSuccess : Color.bunkerPrimary)
                        .frame(width: geo.size.width * (outcome.weightedScore / 10.0))
                }
            }
            .frame(height: 8)

            HStack {
                Text("Score: \(String(format: "%.1f", outcome.weightedScore))")
                    .font(.bunkerCaption)
                    .foregroundStyle(Color.bunkerTextSecondary)

                Spacer()

                if rank == 1 {
                    Text("Recommended")
                        .font(.bunkerLabel)
                        .foregroundStyle(Color.bunkerSuccess)
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.bunkerSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Sheets

struct AddCriteriaSheet: View {
    @Bindable var viewModel: DecisionDetailViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Criteria Name") {
                    TextField("e.g., Cost, Speed, Quality", text: $viewModel.newCriteriaName)
                }

                Section("Importance (1-10)") {
                    Stepper("Importance: \(viewModel.newCriteriaImportance)", value: $viewModel.newCriteriaImportance, in: 1...10)
                }
            }
            .navigationTitle("Add Criteria")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        Task {
                            await viewModel.addCriteria()
                            dismiss()
                        }
                    }
                    .disabled(viewModel.newCriteriaName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

struct AddOptionSheet: View {
    @Bindable var viewModel: DecisionDetailViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Option Name") {
                    TextField("e.g., Option A, Plan B", text: $viewModel.newOptionName)
                }
            }
            .navigationTitle("Add Option")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        Task {
                            await viewModel.addOption()
                            dismiss()
                        }
                    }
                    .disabled(viewModel.newOptionName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

struct ScoringSheet: View {
    @Bindable var viewModel: DecisionDetailViewModel
    let criteriaIndex: Int
    let optionIndex: Int
    @Environment(\.dismiss) private var dismiss
    @State private var score: Int = 5

    var criteriaName: String {
        guard viewModel.decision.criteria.indices.contains(criteriaIndex) else { return "" }
        return viewModel.decision.criteria[criteriaIndex].name
    }

    var optionName: String {
        guard viewModel.decision.options.indices.contains(optionIndex) else { return "" }
        return viewModel.decision.options[optionIndex]
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.xl) {
                Text("Score: \(criteriaName) for \(optionName)")
                    .font(.bunkerHeading2)
                    .foregroundStyle(Color.bunkerTextPrimary)

                Text("\(score)")
                    .font(.system(size: 64, weight: .bold))
                    .foregroundStyle(Color.bunkerPrimary)
                    .contentTransition(.numericText())

                Slider(value: Binding(
                    get: { Double(score) },
                    set: { score = Int($0) }
                ), in: 1...10, step: 1)
                .tint(Color.bunkerPrimary)

                HStack {
                    Text("1")
                        .font(.bunkerCaption)
                        .foregroundStyle(Color.bunkerTextTertiary)
                    Spacer()
                    Text("10")
                        .font(.bunkerCaption)
                        .foregroundStyle(Color.bunkerTextTertiary)
                }

                Text("How well does \(optionName) perform on \(criteriaName)?")
                    .font(.bunkerBodySmall)
                    .foregroundStyle(Color.bunkerTextSecondary)
                    .multilineTextAlignment(.center)

                Spacer()
            }
            .padding(Spacing.lg)
            .background(Color.bunkerBackground)
            .navigationTitle("Score")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await viewModel.setScore(criteriaIndex: criteriaIndex, optionIndex: optionIndex, score: score)
                            dismiss()
                        }
                    }
                }
            }
            .onAppear {
                let criteria = viewModel.decision.criteria[criteriaIndex]
                let optionId = UUID(uuidString: "\(viewModel.decision.id.uuidString)-\(optionIndex)") ?? UUID()
                score = criteria.score(for: optionId)
                if score == 0 { score = 5 }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    NavigationStack {
        DecisionDetailView(decision: .preview)
    }
    .preferredColorScheme(.dark)
}
