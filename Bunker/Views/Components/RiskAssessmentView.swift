import SwiftUI

struct RiskAssessmentView: View {
    let decision: Decision
    @State private var riskScore: Double = 0
    @State private var riskFactors: [RiskFactor] = []
    @State private var isAnalyzing = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bunkerBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        overallRiskCard
                        riskFactorsSection
                    }
                    .padding(Spacing.md)
                }
            }
            .navigationTitle("Risk Assessment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Color.bunkerPrimary)
                }
            }
            .task {
                await analyzeRisks()
            }
        }
    }

    private var overallRiskCard: some View {
        VStack(spacing: Spacing.md) {
            ZStack {
                Circle()
                    .stroke(riskColor.opacity(0.2), lineWidth: 12)
                    .frame(width: 120, height: 120)

                Circle()
                    .trim(from: 0, to: riskScore / 100)
                    .stroke(riskColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.bunkerEaseOut, value: riskScore)

                VStack(spacing: 2) {
                    Text("\(Int(riskScore))")
                        .font(.bunkerDisplay)
                        .foregroundStyle(riskColor)
                    Text(riskLabel)
                        .font(.bunkerCaption)
                        .foregroundStyle(Color.bunkerTextSecondary)
                }
            }

            Text("Overall Risk Score")
                .font(.bunkerHeading3)
                .foregroundStyle(Color.bunkerTextPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.lg)
        .background(Color.bunkerSurfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var riskFactorsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Risk Factors")
                .font(.bunkerHeading3)
                .foregroundStyle(Color.bunkerTextPrimary)

            if isAnalyzing {
                HStack {
                    Spacer()
                    ProgressView()
                        .tint(Color.bunkerPrimary)
                    Spacer()
                }
                .padding(Spacing.lg)
            } else {
                ForEach(riskFactors) { factor in
                    riskFactorRow(factor)
                }
            }
        }
    }

    private func riskFactorRow(_ factor: RiskFactor) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: factor.icon)
                .font(.title3)
                .foregroundStyle(factor.color)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(factor.name)
                    .font(.bunkerBody)
                    .foregroundStyle(Color.bunkerTextPrimary)

                Text(factor.description)
                    .font(.bunkerCaption)
                    .foregroundStyle(Color.bunkerTextSecondary)
            }

            Spacer()

            Text(factor.severity)
                .font(.bunkerCaption)
                .foregroundStyle(factor.color)
                .padding(.horizontal, Spacing.xs)
                .padding(.vertical, 2)
                .background(factor.color.opacity(0.15))
                .clipShape(Capsule())
        }
        .padding(Spacing.sm)
        .background(Color.bunkerSurfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var riskLabel: String {
        switch riskScore {
        case 0..<25: return "Low Risk"
        case 25..<50: return "Moderate"
        case 50..<75: return "Elevated"
        default: return "High Risk"
        }
    }

    private var riskColor: Color {
        switch riskScore {
        case 0..<25: return Color.bunkerSuccess
        case 25..<50: return Color.bunkerWarning
        case 50..<75: return Color.orange
        default: return Color.bunkerError
        }
    }

    private func analyzeRisks() async {
        isAnalyzing = true

        // Analyze based on decision properties
        var factors: [RiskFactor] = []

        // Stake level risk
        switch decision.stake {
        case .low:
            factors.append(RiskFactor(name: "Stake Level", description: "Low-stakes decision, limited downside", severity: "Low", icon: "checkmark.shield", color: Color.bunkerSuccess))
        case .medium:
            factors.append(RiskFactor(name: "Stake Level", description: "Moderate impact on your life or work", severity: "Medium", icon: "exclamationmark.triangle", color: Color.bunkerWarning))
        case .high:
            factors.append(RiskFactor(name: "Stake Level", description: "Major life/work impact — proceed carefully", severity: "High", icon: "exclamationmark.triangle.fill", color: Color.orange))
        case .critical:
            factors.append(RiskFactor(name: "Stake Level", description: "Potentially irreversible, major consequences", severity: "Critical", icon: "flame.fill", color: Color.bunkerError))
        }

        // Reversibility risk
        switch decision.reversibility {
        case .easy:
            factors.append(RiskFactor(name: "Reversibility", description: "Can be undone if needed", severity: "Low", icon: "arrow.uturn.backward", color: Color.bunkerSuccess))
        case .moderate:
            factors.append(RiskFactor(name: "Reversibility", description: "Takes some effort to reverse", severity: "Medium", icon: "arrow.uturn.backward.circle", color: Color.bunkerWarning))
        case .difficult:
            factors.append(RiskFactor(name: "Reversibility", description: "Hard to reverse once committed", severity: "High", icon: "lock.fill", color: Color.orange))
        case .impossible:
            factors.append(RiskFactor(name: "Reversibility", description: "Cannot be undone — final commitment", severity: "Critical", icon: "lock.fill", color: Color.bunkerError))
        }

        // Time horizon risk
        switch decision.timeHorizon {
        case .shortTerm:
            factors.append(RiskFactor(name: "Time Horizon", description: "Short-term decision, days to weeks", severity: "Low", icon: "clock", color: Color.bunkerSuccess))
        case .mediumTerm:
            factors.append(RiskFactor(name: "Time Horizon", description: "Medium-term impact, months to a year", severity: "Medium", icon: "clock", color: Color.bunkerWarning))
        case .longTerm:
            factors.append(RiskFactor(name: "Time Horizon", description: "Long-term impact, several years", severity: "High", icon: "clock.badge.checkmark", color: Color.orange))
        case .permanent:
            factors.append(RiskFactor(name: "Time Horizon", description: "Permanent decision, no take-backs", severity: "Critical", icon: "clock.badge.exclamationmark", color: Color.bunkerError))
        }

        // Criteria count risk
        if decision.criteria.count < 3 {
            factors.append(RiskFactor(name: "Limited Criteria", description: "Fewer than 3 criteria may oversimplify", severity: "Medium", icon: "slider.horizontal.3", color: Color.bunkerWarning))
        } else if decision.criteria.count > 8 {
            factors.append(RiskFactor(name: "Analysis Paralysis Risk", description: "Many criteria may slow down decision", severity: "Low", icon: "tortoise", color: Color.bunkerSuccess))
        }

        // Options count risk
        if decision.options.count > 5 {
            factors.append(RiskFactor(name: "Many Options", description: "More options = harder to compare", severity: "Medium", icon: "square.stack.3d.up", color: Color.bunkerWarning))
        }

        // Deadline risk
        if decision.isOverdue {
            factors.append(RiskFactor(name: "Overdue", description: "Past deadline without resolution", severity: "High", icon: "exclamationmark.circle.fill", color: Color.bunkerError))
        }

        // Calculate overall risk score
        var score: Double = 0
        for factor in factors {
            switch factor.severity {
            case "Critical": score += 25
            case "High": score += 15
            case "Medium": score += 8
            case "Low": score += 3
            default: break
            }
        }
        score = min(100, score)

        try? await Task.sleep(nanoseconds: 800_000_000)

        await MainActor.run {
            riskFactors = factors
            riskScore = score
            isAnalyzing = false
        }
    }
}

struct RiskFactor: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let severity: String
    let icon: String
    let color: Color
}

#Preview {
    RiskAssessmentView(decision: .preview)
        .preferredColorScheme(.dark)
}
