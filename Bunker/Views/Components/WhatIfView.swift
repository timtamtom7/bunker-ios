import SwiftUI

struct WhatIfScenarioView: View {
    let decision: Decision
    @State private var scenarioAdjustments: [String: Double] = [:]
    @State private var simulatedOutcomes: [Outcome] = []
    @State private var isSimulating = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bunkerBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        headerSection

                        if !scenarioAdjustments.isEmpty {
                            adjustmentsSection
                            simulatedOutcomesSection
                        }
                    }
                    .padding(Spacing.md)
                }
            }
            .navigationTitle("What-If Analysis")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Color.bunkerPrimary)
                }
            }
            .task {
                initializeScenarios()
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Image(systemName: "wand.and.stars")
                    .font(.title2)
                    .foregroundStyle(Color.bunkerAccent)
                Text("What Would Change?")
                    .font(.bunkerHeading2)
                    .foregroundStyle(Color.bunkerTextPrimary)
            }

            Text("Adjust weights to see how your recommendation might shift.")
                .font(.bunkerBody)
                .foregroundStyle(Color.bunkerTextSecondary)
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.bunkerSurfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var adjustmentsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Adjusted Criteria Weights")
                .font(.bunkerHeading3)
                .foregroundStyle(Color.bunkerTextPrimary)

            ForEach(decision.criteria) { criteria in
                let currentWeight = scenarioAdjustments[criteria.id.uuidString] ?? Double(criteria.importance)
                let originalWeight = criteria.importance
                let delta = Int(currentWeight) - originalWeight

                HStack {
                    Text(criteria.name)
                        .font(.bunkerBody)
                        .foregroundStyle(Color.bunkerTextPrimary)

                    Spacer()

                    Text("was \(originalWeight)")
                        .font(.bunkerCaption)
                        .foregroundStyle(Color.bunkerTextTertiary)

                    Text("→ \(Int(currentWeight))")
                        .font(.bunkerBody)
                        .foregroundStyle(delta > 0 ? Color.bunkerSuccess : delta < 0 ? Color.bunkerError : Color.bunkerTextPrimary)

                    Text("(\(delta > 0 ? "+" : "")\(delta))")
                        .font(.bunkerCaption)
                        .foregroundStyle(Color.bunkerTextTertiary)
                }
                .padding(Spacing.sm)
                .background(Color.bunkerSurface)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }

    private var simulatedOutcomesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Simulated Outcomes")
                .font(.bunkerHeading3)
                .foregroundStyle(Color.bunkerTextPrimary)

            if isSimulating {
                HStack {
                    Spacer()
                    ProgressView()
                        .tint(Color.bunkerPrimary)
                    Text("Simulating...")
                        .font(.bunkerBody)
                        .foregroundStyle(Color.bunkerTextSecondary)
                    Spacer()
                }
                .padding(Spacing.lg)
            } else {
                ForEach(simulatedOutcomes) { outcome in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(outcome.option)
                                .font(.bunkerBody)
                                .foregroundStyle(Color.bunkerTextPrimary)

                            Text("Score: \(String(format: "%.1f", outcome.weightedScore))")
                                .font(.bunkerCaption)
                                .foregroundStyle(Color.bunkerPrimary)
                        }

                        Spacer()

                        Text("\(Int(outcome.confidence))% confidence")
                            .font(.bunkerCaption)
                            .foregroundStyle(Color.bunkerTextTertiary)
                    }
                    .padding(Spacing.sm)
                    .background(
                        outcome.id == simulatedOutcomes.first?.id
                            ? Color.bunkerSuccess.opacity(0.1)
                            : Color.bunkerSurface
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                outcome.id == simulatedOutcomes.first?.id ? Color.bunkerSuccess.opacity(0.3) : Color.clear,
                                lineWidth: 1
                            )
                    )
                }
            }
        }
    }

    private func initializeScenarios() {
        for criteria in decision.criteria {
            scenarioAdjustments[criteria.id.uuidString] = Double(criteria.importance)
        }
        runSimulation()
    }

    private func runSimulation() {
        isSimulating = true

        Task {
            // Simulate based on adjusted weights
            var outcomes: [Outcome] = []
            for option in decision.options {
                let score = simulateOption(option)
                outcomes.append(Outcome(
                    decisionId: decision.id,
                    option: option,
                    weightedScore: score,
                    confidence: calculateConfidence(for: option),
                    scoreBreakdown: []
                ))
            }
            outcomes.sort { $0.weightedScore > $1.weightedScore }

            await MainActor.run {
                simulatedOutcomes = outcomes
                isSimulating = false
            }
        }
    }

    private func simulateOption(_ option: String) -> Double {
        // Simple weighted simulation using adjusted criteria weights
        var totalScore: Double = 0
        for criteria in decision.criteria {
            let adjustedWeight = scenarioAdjustments[criteria.id.uuidString] ?? Double(criteria.importance)
            // Simulate a random score between 5-10 for each criteria/option combo
            let simulatedScore = Double.random(in: 5...10)
            totalScore += simulatedScore * (adjustedWeight / 10.0)
        }
        return totalScore
    }

    private func calculateConfidence(for option: String) -> Double {
        // Confidence based on score spread
        guard let myScore = simulatedOutcomes.first(where: { $0.option == option })?.weightedScore,
              let topScore = simulatedOutcomes.first?.weightedScore else {
            return 70
        }
        let spread = topScore - myScore
        return max(40, min(98, 100 - spread * 5))
    }
}

#Preview {
    WhatIfScenarioView(decision: .preview)
        .preferredColorScheme(.dark)
}
