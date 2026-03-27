import SwiftUI

struct DecisionDashboardView: View {
    let decision: Decision
    let outcomes: [Outcome]

    private var regretProbability: Double {
        calculateRegretProbability()
    }

    private var overallConfidence: Double {
        guard !outcomes.isEmpty else { return 0 }
        return outcomes.reduce(0) { $0 + $1.confidence } / Double(outcomes.count)
    }

    private var topOption: Outcome? {
        outcomes.first
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Decision Dashboard")
                .font(.bunkerHeading2)
                .foregroundStyle(Color.bunkerTextPrimary)

            // Gauge row
            HStack(spacing: Spacing.sm) {
                ConfidenceGaugeView(
                    confidence: overallConfidence,
                    title: "Confidence"
                )

                RegretMeterView(
                    probability: regretProbability,
                    title: "Regret Risk"
                )
            }

            // Timeline
            if decision.deadlineDate != nil {
                DecisionTimelineView(decision: decision)
            }

            // Pros/Cons weight chart
            if !decision.criteria.isEmpty {
                CriteriaWeightChartView(decision: decision)
            }

            // Option comparison summary
            if !outcomes.isEmpty {
                OptionComparisonView(outcomes: outcomes)
            }
        }
        .padding(Spacing.md)
        .background(Color.bunkerSurface.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.bunkerDivider, lineWidth: 1)
        )
    }

    private func calculateRegretProbability() -> Double {
        // Model regret as: probability of choosing wrong option
        // Based on gap between top 2 outcomes + reversibility + stakes
        guard outcomes.count >= 2,
              let top = outcomes.first,
              let second = outcomes.dropFirst().first else {
            // No clear second option — moderate regret risk
            return 30.0
        }

        let gap = top.weightedScore - second.weightedScore
        var baseRisk: Double

        if gap > 3 {
            baseRisk = 10.0 // Clear winner
        } else if gap > 1.5 {
            baseRisk = 25.0 // Moderate gap
        } else if gap > 0.5 {
            baseRisk = 45.0 // Narrow margin
        } else {
            baseRisk = 65.0 // Very close — high regret risk
        }

        // Adjust by reversibility
        switch decision.reversibility {
        case .easy:
            baseRisk *= 0.7
        case .moderate:
            baseRisk *= 1.0
        case .difficult:
            baseRisk *= 1.3
        case .impossible:
            baseRisk *= 1.5
        }

        // Adjust by stake
        switch decision.stake {
        case .low:
            baseRisk *= 0.8
        case .medium:
            baseRisk *= 1.0
        case .high:
            baseRisk *= 1.2
        case .critical:
            baseRisk *= 1.4
        }

        return min(95.0, max(5.0, baseRisk))
    }
}

// MARK: - Confidence Gauge

struct ConfidenceGaugeView: View {
    let confidence: Double
    let title: String

    var body: some View {
        VStack(spacing: Spacing.xs) {
            ZStack {
                Circle()
                    .stroke(Color.bunkerSecondary, lineWidth: 6)

                Circle()
                    .trim(from: 0, to: confidence / 100)
                    .stroke(
                        confidenceColor,
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.6), value: confidence)

                VStack(spacing: 1) {
                    Text("\(Int(confidence))%")
                        .font(.bunkerHeading3)
                        .foregroundStyle(confidenceColor)
                }
            }
            .frame(width: 72, height: 72)

            Text(title)
                .font(.bunkerCaption)
                .foregroundStyle(Color.bunkerTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.sm)
        .background(Color.bunkerSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var confidenceColor: Color {
        if confidence >= 75 {
            return Color.bunkerSuccess
        } else if confidence >= 50 {
            return Color.bunkerWarning
        } else {
            return Color.bunkerError
        }
    }
}

// MARK: - Regret Meter

struct RegretMeterView: View {
    let probability: Double
    let title: String

    var body: some View {
        VStack(spacing: Spacing.xs) {
            ZStack {
                Circle()
                    .stroke(Color.bunkerSecondary, lineWidth: 6)

                Circle()
                    .trim(from: 0, to: probability / 100)
                    .stroke(
                        regretColor,
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.6), value: probability)

                VStack(spacing: 1) {
                    Text("\(Int(probability))%")
                        .font(.bunkerHeading3)
                        .foregroundStyle(regretColor)
                }
            }
            .frame(width: 72, height: 72)

            Text(title)
                .font(.bunkerCaption)
                .foregroundStyle(Color.bunkerTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.sm)
        .background(Color.bunkerSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var regretColor: Color {
        if probability <= 20 {
            return Color.bunkerSuccess
        } else if probability <= 45 {
            return Color.bunkerWarning
        } else {
            return Color.bunkerError
        }
    }
}

// MARK: - Decision Timeline

struct DecisionTimelineView: View {
    let decision: Decision

    private var phases: [(label: String, date: Date?, isPast: Bool, isToday: Bool)] {
        [
            ("Created", decision.createdAt, decision.createdAt < Date(), false),
            ("Today", Date(), true, true),
            ("Deadline", decision.deadlineDate, decision.deadlineDate.map { $0 < Date() } ?? false, false)
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("Timeline")
                .font(.bunkerLabel)
                .foregroundStyle(Color.bunkerTextTertiary)

            HStack(spacing: 0) {
                ForEach(Array(phases.enumerated()), id: \.offset) { index, phase in
                    timelinePhase(phase, isLast: index == phases.count - 1)
                }
            }

            if let deadline = decision.daysUntilDeadline {
                HStack {
                    Image(systemName: deadline < 0 ? "exclamationmark.triangle.fill" : "clock")
                        .font(.bunkerCaption)
                        .foregroundStyle(deadline < 0 ? Color.bunkerError : Color.bunkerAccent)

                    Text(deadlineLabel(deadline))
                        .font(.bunkerCaption)
                        .foregroundStyle(deadline < 0 ? Color.bunkerError : Color.bunkerTextSecondary)
                }
            }
        }
        .padding(Spacing.sm)
        .background(Color.bunkerSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private func timelinePhase(_ phase: (label: String, date: Date?, isPast: Bool, isToday: Bool), isLast: Bool) -> some View {
        HStack(spacing: 0) {
            VStack(spacing: 4) {
                Circle()
                    .fill(phase.isToday ? Color.bunkerAccent : (phase.isPast ? Color.bunkerSuccess : Color.bunkerSecondary))
                    .frame(width: 10, height: 10)

                Text(phase.label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(phase.isToday ? Color.bunkerAccent : Color.bunkerTextSecondary)

                if let date = phase.date {
                    Text(date.formatted(date: .abbreviated, time: .omitted))
                        .font(.system(size: 11))
                        .foregroundStyle(Color.bunkerTextTertiary)
                }
            }

            if !isLast {
                Rectangle()
                    .fill(Color.bunkerDivider)
                    .frame(height: 2)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 20)
            }
        }
    }

    private func deadlineLabel(_ days: Int) -> String {
        if days < 0 {
            return "\(abs(days)) days overdue"
        } else if days == 0 {
            return "Deadline is today"
        } else if days == 1 {
            return "1 day until deadline"
        } else {
            return "\(days) days until deadline"
        }
    }
}

// MARK: - Criteria Weight Chart

struct CriteriaWeightChartView: View {
    let decision: Decision

    private var maxImportance: Int {
        decision.criteria.map(\.importance).max() ?? 10
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("Criteria Weights")
                .font(.bunkerLabel)
                .foregroundStyle(Color.bunkerTextTertiary)

            ForEach(decision.criteria) { criteria in
                HStack(spacing: Spacing.sm) {
                    Text(criteria.name)
                        .font(.bunkerCaption)
                        .foregroundStyle(Color.bunkerTextPrimary)
                        .frame(width: 100, alignment: .leading)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.bunkerSecondary)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(weightColor(for: criteria.importance))
                                .frame(width: geo.size.width * CGFloat(criteria.importance) / CGFloat(maxImportance))
                        }
                    }
                    .frame(height: 12)

                    Text("\(criteria.importance)")
                        .font(.bunkerCaption)
                        .foregroundStyle(Color.bunkerTextTertiary)
                        .frame(width: 20, alignment: .trailing)
                }
            }
        }
        .padding(Spacing.sm)
        .background(Color.bunkerSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func weightColor(for importance: Int) -> Color {
        if importance >= 8 {
            return Color.bunkerError
        } else if importance >= 6 {
            return Color.bunkerWarning
        } else {
            return Color.bunkerPrimary
        }
    }
}

// MARK: - Option Comparison

struct OptionComparisonView: View {
    let outcomes: [Outcome]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("Option Summary")
                .font(.bunkerLabel)
                .foregroundStyle(Color.bunkerTextTertiary)

            ForEach(Array(outcomes.prefix(3).enumerated()), id: \.element.id) { index, outcome in
                HStack {
                    Text("#\(index + 1)")
                        .font(.bunkerLabel)
                        .foregroundStyle(index == 0 ? Color.bunkerSuccess : Color.bunkerTextTertiary)
                        .frame(width: 24)

                    Text(outcome.option)
                        .font(.bunkerBodySmall)
                        .foregroundStyle(Color.bunkerTextPrimary)
                        .lineLimit(1)

                    Spacer()

                    Text(String(format: "%.1f", outcome.weightedScore))
                        .font(.bunkerBodySmall)
                        .foregroundStyle(index == 0 ? Color.bunkerPrimary : Color.bunkerTextSecondary)

                    if index == 0 {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.bunkerCaption)
                            .foregroundStyle(Color.bunkerSuccess)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .padding(Spacing.sm)
        .background(Color.bunkerSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    DecisionDashboardView(decision: .preview, outcomes: [])
        .padding()
        .background(Color.bunkerBackground)
        .preferredColorScheme(.dark)
}
