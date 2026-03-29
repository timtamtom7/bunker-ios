import SwiftUI

struct MacOutcomeSimulatorView: View {
    let decision: Decision
    @Environment(\.dismiss) private var dismiss
    @State private var analysis: AIDecisionService.AIAnalysis?
    @State private var isSimulating = false
    @State private var selectedScenarioIndex: Int? = nil
    @State private var showWhatIf = false
    @State private var whatIfText = ""

    private let aiService = AIDecisionService.shared

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Outcome Simulator")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(BunkerColors.textPrimary)
                    Text("What if scenarios and risk assessment")
                        .font(.system(size: 12))
                        .foregroundColor(BunkerColors.textTertiary)
                }
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(BunkerColors.textTertiary)
                }
                .buttonStyle(.plain)
            }
            .padding(20)
            .background(BunkerColors.surface)

            Divider()
                .background(BunkerColors.divider)

            // Content
            ScrollView {
                VStack(spacing: 20) {
                    // What If Input
                    whatIfSection

                    // Confidence Score
                    if let analysis = analysis {
                        confidenceSection(analysis)

                        // Scenarios
                        scenariosSection(analysis)

                        // Risk Assessment
                        riskSection(analysis)
                    }
                }
                .padding(20)
            }
            .background(BunkerColors.background)

            Divider()
                .background(BunkerColors.divider)

            // Run Simulation Button
            HStack {
                Button {
                    Task { await runSimulation() }
                } label: {
                    HStack(spacing: 8) {
                        if isSimulating {
                            ProgressView()
                                .scaleEffect(0.7)
                                .tint(BunkerColors.textPrimary)
                        } else {
                            Image(systemName: "play.fill")
                        }
                        Text(isSimulating ? "Simulating..." : "Run Simulation")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(BunkerColors.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(isSimulating ? BunkerColors.textTertiary : BunkerColors.primary)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .disabled(isSimulating)
            }
            .padding(20)
            .background(BunkerColors.surface)
        }
        .frame(width: 580, height: 640)
        .background(BunkerColors.background)
        .onAppear {
            Task { await runSimulation() }
        }
    }

    // MARK: - What If Section
    private var whatIfSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "wand.and.stars")
                    .foregroundColor(BunkerColors.accent)
                Text("WHAT IF...")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(BunkerColors.accent)
            }

            VStack(spacing: 8) {
                TextField("e.g., What if I scored Cost lower?", text: $whatIfText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13))
                    .foregroundColor(BunkerColors.textPrimary)
                    .padding(10)
                    .background(BunkerColors.surfaceSecondary)
                    .cornerRadius(8)

                HStack(spacing: 8) {
                    whatIfButton("Score all criteria higher") {
                        whatIfText = "What if I scored everything more generously?"
                    }
                    whatIfButton("Reverse top criteria") {
                        whatIfText = "What if my top criterion was actually less important?"
                    }
                }

                HStack(spacing: 8) {
                    whatIfButton("Add risk criterion") {
                        whatIfText = "What if I added a risk criterion?"
                    }
                    whatIfButton("Remove an option") {
                        whatIfText = "What if one option wasn't available?"
                    }
                }
            }
        }
    }

    private func whatIfButton(_ label: String, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 10))
                Text(label)
                    .font(.system(size: 11))
            }
            .foregroundColor(BunkerColors.accent)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(BunkerColors.accent.opacity(0.1))
            .cornerRadius(4)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Confidence Section
    private func confidenceSection(_ analysis: AIDecisionService.AIAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "gauge.with.needle")
                    .foregroundColor(confidenceColor(analysis.confidenceScore))
                Text("ANALYSIS CONFIDENCE")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(BunkerColors.textTertiary)
                Spacer()
                Text("\(Int(analysis.confidenceScore))%")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(confidenceColor(analysis.confidenceScore))
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(BunkerColors.surfaceSecondary)
                        .frame(height: 8)
                        .cornerRadius(4)
                    Rectangle()
                        .fill(confidenceColor(analysis.confidenceScore))
                        .frame(width: geo.size.width * (analysis.confidenceScore / 100.0), height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)

            Text(confidenceLabel(analysis.confidenceScore))
                .font(.system(size: 12))
                .foregroundColor(BunkerColors.textTertiary)
        }
        .padding(12)
        .background(BunkerColors.surfaceSecondary)
        .cornerRadius(8)
    }

    // MARK: - Scenarios Section
    private func scenariosSection(_ analysis: AIDecisionService.AIAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "square.stack.3d.up")
                    .foregroundColor(BunkerColors.primary)
                Text("POSSIBLE OUTCOMES")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(BunkerColors.primary)
                Spacer()
                Text("\(analysis.scenarios.count) scenarios")
                    .font(.system(size: 11))
                    .foregroundColor(BunkerColors.textTertiary)
            }

            if analysis.scenarios.isEmpty {
                Text("Score your criteria to generate outcome scenarios.")
                    .font(.system(size: 13))
                    .foregroundColor(BunkerColors.textTertiary)
                    .padding(.vertical, 8)
            } else {
                ForEach(Array(analysis.scenarios.enumerated()), id: \.offset) { index, scenario in
                    scenarioRow(scenario: scenario, rank: index)
                }
            }
        }
    }

    private func scenarioRow(scenario: AIDecisionService.Scenario, rank: Int) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                // Rank
                ZStack {
                    Circle()
                        .fill(rank == 0 ? BunkerColors.accent : BunkerColors.surfaceSecondary)
                        .frame(width: 28, height: 28)
                    Text("\(rank + 1)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(rank == 0 ? BunkerColors.textPrimary : BunkerColors.textSecondary)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(scenario.title)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(BunkerColors.textPrimary)
                        Spacer()
                        probabilityBadge(scenario.probability)
                    }

                    Text(scenario.outcome)
                        .font(.system(size: 12))
                        .foregroundColor(BunkerColors.textTertiary)
                        .lineLimit(2)
                }
            }
            .padding(12)
            .background(rank == 0 ? BunkerColors.accent.opacity(0.1) : BunkerColors.surfaceSecondary)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(rank == 0 ? BunkerColors.accent.opacity(0.3) : Color.clear, lineWidth: 1)
            )

            // Probability bar
            GeometryReader { geo in
                Rectangle()
                    .fill(probabilityGradient(for: rank))
                    .frame(width: geo.size.width * scenario.probability, height: 3)
                    .cornerRadius(1.5)
            }
            .frame(height: 3)
        }
    }

    private func probabilityBadge(_ probability: Double) -> some View {
        let pct = Int(probability * 100)
        return Text("\(pct)%")
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(probability > 0.6 ? BunkerColors.success : (probability > 0.4 ? BunkerColors.warning : BunkerColors.error))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                (probability > 0.6 ? BunkerColors.success : (probability > 0.4 ? BunkerColors.warning : BunkerColors.error))
                    .opacity(0.15)
            )
            .cornerRadius(4)
    }

    private func probabilityGradient(for rank: Int) -> Color {
        switch rank {
        case 0: return BunkerColors.accent
        case 1: return BunkerColors.primary
        case 2: return BunkerColors.warning
        default: return BunkerColors.textTertiary
        }
    }

    // MARK: - Risk Assessment Section
    private func riskSection(_ analysis: AIDecisionService.AIAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "exclamationmark.shield")
                    .foregroundColor(BunkerColors.warning)
                Text("RISK ASSESSMENT")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(BunkerColors.warning)
            }

            // Recommendation
            VStack(alignment: .leading, spacing: 6) {
                Text("Recommendation")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(BunkerColors.textTertiary)
                Text(analysis.recommendation)
                    .font(.system(size: 13))
                    .foregroundColor(BunkerColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(10)
            .background(BunkerColors.warning.opacity(0.1))
            .cornerRadius(6)

            // Risk factors
            if !analysis.blindSpots.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Risk Factors")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(BunkerColors.textTertiary)
                    ForEach(analysis.blindSpots.prefix(3), id: \.self) { spot in
                        HStack(alignment: .top, spacing: 6) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 10))
                                .foregroundColor(BunkerColors.warning)
                                .padding(.top, 2)
                            Text(spot)
                                .font(.system(size: 12))
                                .foregroundColor(BunkerColors.textSecondary)
                        }
                    }
                }
                .padding(10)
                .background(BunkerColors.surfaceSecondary)
                .cornerRadius(6)
            }

            // Missing info
            if !analysis.missingInfo.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Information Gaps")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(BunkerColors.textTertiary)
                    ForEach(analysis.missingInfo.prefix(3), id: \.self) { info in
                        HStack(alignment: .top, spacing: 6) {
                            Image(systemName: "questionmark.circle.fill")
                                .font(.system(size: 10))
                                .foregroundColor(BunkerColors.primary)
                                .padding(.top, 2)
                            Text(info)
                                .font(.system(size: 12))
                                .foregroundColor(BunkerColors.textSecondary)
                        }
                    }
                }
                .padding(10)
                .background(BunkerColors.surfaceSecondary)
                .cornerRadius(6)
            }

            // Overall risk badge
            overallRiskBadge(analysis)
        }
    }

    private func overallRiskBadge(_ analysis: AIDecisionService.AIAnalysis) -> some View {
        let riskLevel: String
        let riskColor: Color
        let riskIcon: String

        if analysis.confidenceScore >= 80 {
            riskLevel = "LOW RISK"
            riskColor = BunkerColors.success
            riskIcon = "checkmark.shield.fill"
        } else if analysis.confidenceScore >= 60 {
            riskLevel = "MODERATE RISK"
            riskColor = BunkerColors.warning
            riskIcon = "exclamationmark.shield.fill"
        } else if analysis.confidenceScore >= 40 {
            riskLevel = "ELEVATED RISK"
            riskColor = Color.orange
            riskIcon = "exclamationmark.triangle.fill"
        } else {
            riskLevel = "HIGH RISK"
            riskColor = BunkerColors.error
            riskIcon = "xmark.shield.fill"
        }

        return HStack {
            Image(systemName: riskIcon)
                .foregroundColor(riskColor)
            Text(riskLevel)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(riskColor)
            Text("— Based on \(analysis.blindSpots.count) blind spots and \(analysis.missingInfo.count) information gaps")
                .font(.system(size: 11))
                .foregroundColor(BunkerColors.textTertiary)
            Spacer()
        }
        .padding(10)
        .background(riskColor.opacity(0.1))
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(riskColor.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Helpers
    private func runSimulation() async {
        isSimulating = true
        try? await Task.sleep(nanoseconds: 600_000_000) // Simulate async work
        analysis = aiService.analyzeDecision(decision)
        isSimulating = false
    }

    private func confidenceColor(_ score: Double) -> Color {
        if score >= 80 { return BunkerColors.success }
        if score >= 60 { return BunkerColors.warning }
        return BunkerColors.error
    }

    private func confidenceLabel(_ score: Double) -> String {
        if score >= 80 { return "High confidence — good data for decision" }
        if score >= 60 { return "Moderate confidence — consider gathering more info" }
        if score >= 40 { return "Low confidence — seek more criteria or scoring" }
        return "Very low confidence — revisit your decision setup"
    }
}
