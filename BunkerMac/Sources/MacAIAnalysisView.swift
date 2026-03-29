import SwiftUI

struct MacAIAnalysisView: View {
    let decision: Decision
    @Environment(\.dismiss) private var dismiss

    @State private var analysisResult = ""
    @State private var isAnalyzing = false
    @State private var challengeQuestions: [String] = []
    @State private var blindSpots: [String] = []
    @State private var counterArguments: [String] = []

    private let aiService = AIDecisionService.shared

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Deep AI Analysis")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(BunkerColors.textPrimary)
                    Text("Challenging your assumptions")
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
                    // Analysis Result
                    if !analysisResult.isEmpty {
                        analysisResultSection
                    }

                    // Challenge Questions
                    if !challengeQuestions.isEmpty {
                        challengeSection
                    }

                    // Blind Spots
                    if !blindSpots.isEmpty {
                        blindSpotsSection
                    }

                    // Counter Arguments
                    if !counterArguments.isEmpty {
                        counterArgumentsSection
                    }
                }
                .padding(20)
            }
            .background(BunkerColors.background)

            Divider()
                .background(BunkerColors.divider)

            // Run Analysis Button
            HStack {
                Button {
                    Task { await runAnalysis() }
                } label: {
                    HStack(spacing: 8) {
                        if isAnalyzing {
                            ProgressView()
                                .scaleEffect(0.7)
                                .tint(BunkerColors.textPrimary)
                        } else {
                            Image(systemName: "brain")
                        }
                        Text(isAnalyzing ? "Analyzing..." : "Run AI Analysis")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(BunkerColors.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(isAnalyzing ? BunkerColors.textTertiary : BunkerColors.accent)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .disabled(isAnalyzing)
            }
            .padding(20)
            .background(BunkerColors.surface)
        }
        .frame(width: 560, height: 600)
        .background(BunkerColors.background)
        .onAppear {
            challengeQuestions = generateChallengeQuestions()
            blindSpots = generateBlindSpots()
            counterArguments = generateCounterArguments()
        }
    }

    // MARK: - Sections
    private var analysisResultSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(BunkerColors.warning)
                Text("AI INSIGHT")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(BunkerColors.warning)
            }

            Text(analysisResult)
                .font(.system(size: 13))
                .foregroundColor(BunkerColors.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(BunkerColors.warning.opacity(0.1))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(BunkerColors.warning.opacity(0.3), lineWidth: 1)
                )
        }
    }

    private var challengeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "questionmark.circle.fill")
                    .foregroundColor(BunkerColors.primary)
                Text("CHALLENGE QUESTIONS")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(BunkerColors.primary)
            }

            VStack(alignment: .leading, spacing: 8) {
                ForEach(challengeQuestions, id: \.self) { question in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "arrow.right.circle")
                            .font(.system(size: 12))
                            .foregroundColor(BunkerColors.primary)
                            .padding(.top, 2)
                        Text(question)
                            .font(.system(size: 13))
                            .foregroundColor(BunkerColors.textSecondary)
                    }
                }
            }
            .padding(12)
            .background(BunkerColors.surfaceSecondary)
            .cornerRadius(8)
        }
    }

    private var blindSpotsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "eye.slash.fill")
                    .foregroundColor(BunkerColors.error)
                Text("POTENTIAL BLIND SPOTS")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(BunkerColors.error)
            }

            VStack(alignment: .leading, spacing: 8) {
                ForEach(blindSpots, id: \.self) { spot in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 12))
                            .foregroundColor(BunkerColors.error)
                            .padding(.top, 2)
                        Text(spot)
                            .font(.system(size: 13))
                            .foregroundColor(BunkerColors.textSecondary)
                    }
                }
            }
            .padding(12)
            .background(BunkerColors.error.opacity(0.1))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(BunkerColors.error.opacity(0.3), lineWidth: 1)
            )
        }
    }

    private var counterArgumentsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "arrow.counterclockwise.circle.fill")
                    .foregroundColor(BunkerColors.accent)
                Text("COUNTER-ARGUMENTS")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(BunkerColors.accent)
            }

            VStack(alignment: .leading, spacing: 8) {
                ForEach(counterArguments, id: \.self) { arg in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "minus.circle")
                            .font(.system(size: 12))
                            .foregroundColor(BunkerColors.accent)
                            .padding(.top, 2)
                        Text(arg)
                            .font(.system(size: 13))
                            .foregroundColor(BunkerColors.textSecondary)
                    }
                }
            }
            .padding(12)
            .background(BunkerColors.accent.opacity(0.1))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(BunkerColors.accent.opacity(0.3), lineWidth: 1)
            )
        }
    }

    // MARK: - Analysis
    private func runAnalysis() async {
        isAnalyzing = true
        analysisResult = await aiService.generateAdvice(for: decision)
        challengeQuestions = generateChallengeQuestions()
        blindSpots = generateBlindSpots()
        counterArguments = generateCounterArguments()
        isAnalyzing = false
    }

    // MARK: - Generators
    private func generateChallengeQuestions() -> [String] {
        var questions: [String] = []

        if decision.options.count < 2 {
            questions.append("You're comparing fewer than 2 options. Are you sure you've explored all alternatives?")
        }
        if decision.criteria.count < 3 {
            questions.append("Only \(decision.criteria.count) criteria defined. What other factors might matter?")
        }
        if decision.stake == .critical {
            questions.append("This is a critical decision. Have you slept on it? What would you tell a friend in your position?")
        }
        if decision.reversibility == .impossible {
            questions.append("This is irreversible. What would the 'best version of yourself' choose? And the 'worst'?")
        }

        let criteriaText = decision.criteria.map { $0.name.lowercased() }.joined(separator: " ")
        if !criteriaText.contains("risk") && !criteriaText.contains("downside") {
            questions.append("No risk-related criteria detected. What could go wrong with each option?")
        }
        if !criteriaText.contains("cost") && !criteriaText.contains("budget") {
            questions.append("No cost/budget criteria. Is this decision sensitive to financial constraints?")
        }

        questions.append("If you made this decision 5 years from now instead of today, would you choose differently?")
        questions.append("What's the opportunity cost of not choosing your second-ranked option?")
        questions.append("Would you recommend this same choice to someone you deeply care about?")

        return Array(questions.prefix(5))
    }

    private func generateBlindSpots() -> [String] {
        var spots: [String] = []

        let criteriaText = decision.criteria.map { $0.name.lowercased() }.joined(separator: " ")
        if !criteriaText.contains("cost") && !criteriaText.contains("value") && !criteriaText.contains("benefit") {
            spots.append("You're not explicitly weighing costs against benefits. Money matters — include it.")
        }
        if !criteriaText.contains("time") && !criteriaText.contains("duration") {
            spots.append("Time investment isn't captured. How much time does each option require?")
        }
        if decision.options.count > 4 {
            spots.append("You have \(decision.options.count) options — this might indicate scope creep. Can you narrow it down to 2-3 strong candidates?")
        }
        if decision.deadlineDate == nil {
            spots.append("No deadline set. Without a time constraint, decisions can drag on indefinitely.")
        }

        return Array(spots.prefix(4))
    }

    private func generateCounterArguments() -> [String] {
        var args: [String] = []

        if let topOption = decision.options.first {
            args.append("Are you sure '\(topOption)' is the best choice? What if your assumptions about it are wrong?")
        }

        if decision.stake == .high || decision.stake == .critical {
            args.append("High-stakes decisions often suffer from analysis paralysis. You might be overthinking this.")
        }

        args.append("Your criteria weights might be biased by recent events or emotions. Are you thinking clearly?")

        if decision.options.allSatisfy({ $0.count < 10 }) {
            args.append("Your options seem brief. Are you being specific enough to make a meaningful comparison?")
        }

        return Array(args.prefix(4))
    }
}
