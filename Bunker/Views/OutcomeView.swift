import SwiftUI

struct OutcomeView: View {
    let outcome: Outcome
    let decision: Decision
    @State private var isExpanded = false

    private let aiService = AIAnalysisService.shared

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Header
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: Spacing.xxs) {
                        Text(outcome.option)
                            .font(.bunkerHeading3)
                            .foregroundStyle(Color.bunkerTextPrimary)

                        HStack(spacing: Spacing.xs) {
                            Label(String(format: "%.1f", outcome.weightedScore), systemImage: "chart.bar.fill")
                                .font(.bunkerCaption)
                                .foregroundStyle(Color.bunkerPrimary)

                            Label("\(Int(outcome.confidence))% confidence", systemImage: "checkmark.seal")
                                .font(.bunkerCaption)
                                .foregroundStyle(Color.bunkerTextSecondary)
                        }
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.bunkerCaption)
                        .foregroundStyle(Color.bunkerTextTertiary)
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                Divider()
                    .background(Color.bunkerDivider)

                // Breakdown
                ForEach(outcome.scoreBreakdown) { item in
                    HStack {
                        Text(item.criteriaName)
                            .font(.bunkerBodySmall)
                            .foregroundStyle(Color.bunkerTextPrimary)

                        Spacer()

                        Text("w:\(item.criteriaWeight)")
                            .font(.bunkerCaption)
                            .foregroundStyle(Color.bunkerTextTertiary)

                        Text("s:\(item.optionScore)")
                            .font(.bunkerCaption)
                            .foregroundStyle(Color.bunkerPrimary)

                        Text(String(format: "%.1f", item.weightedValue))
                            .font(.bunkerCaption)
                            .foregroundStyle(Color.bunkerTextSecondary)
                            .frame(width: 36, alignment: .trailing)
                    }
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.bunkerSurfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.bunkerDivider, lineWidth: 1)
        )
    }
}

struct OutcomeHistoryView: View {
    @State private var decisions: [Decision] = []
    @State private var outcomesByDecision: [UUID: [Outcome]] = [:]
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bunkerBackground
                    .ignoresSafeArea()

                if isLoading {
                    ProgressView()
                        .tint(Color.bunkerPrimary)
                } else if decisions.isEmpty {
                    emptyState
                } else {
                    historyList
                }
            }
            .navigationTitle("Outcomes")
            .task {
                await loadData()
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 56))
                .foregroundStyle(Color.bunkerTextTertiary)

            Text("No outcomes yet")
                .font(.bunkerHeading2)
                .foregroundStyle(Color.bunkerTextPrimary)

            Text("Simulate decisions to see outcome history here.")
                .font(.bunkerBody)
                .foregroundStyle(Color.bunkerTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(Spacing.xl)
    }

    private var historyList: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.lg) {
                ForEach(decisions) { decision in
                    if let outcomes = outcomesByDecision[decision.id], !outcomes.isEmpty {
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text(decision.title)
                                .font(.bunkerHeading3)
                                .foregroundStyle(Color.bunkerTextPrimary)
                                .padding(.horizontal, Spacing.xs)

                            ForEach(outcomes) { outcome in
                                OutcomeRow(outcome: outcome, rank: 1)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.sm)
        }
    }

    private func loadData() async {
        isLoading = true
        defer { isLoading = false }

        await DecisionService.shared.loadDecisions()
        decisions = DecisionService.shared.decisions.filter { !$0.criteria.isEmpty && !$0.options.isEmpty }

        for decision in decisions {
            let outcomes = await DecisionService.shared.fetchOutcomes(for: decision.id)
            if !outcomes.isEmpty {
                outcomesByDecision[decision.id] = outcomes
            }
        }
    }
}

#Preview("Outcome View") {
    OutcomeView(outcome: .preview, decision: .preview)
        .padding()
        .background(Color.bunkerBackground)
        .preferredColorScheme(.dark)
}

#Preview("Outcome History") {
    OutcomeHistoryView()
        .preferredColorScheme(.dark)
}
