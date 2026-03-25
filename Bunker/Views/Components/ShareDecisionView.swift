import SwiftUI

struct ShareDecisionView: View {
    let decision: Decision
    let outcomes: [Outcome]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    // Header
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text(decision.title)
                            .font(.bunkerHeading1)
                            .foregroundStyle(Color.bunkerTextPrimary)

                        if !decision.description.isEmpty {
                            Text(decision.description)
                                .font(.bunkerBody)
                                .foregroundStyle(Color.bunkerTextSecondary)
                        }

                        HStack {
                            Label(decision.stake.rawValue, systemImage: "exclamationmark.triangle")
                                .font(.bunkerLabel)
                                .foregroundStyle(Color(hex: decision.stake.color))

                            Label(decision.reversibility.rawValue, systemImage: "arrow.uturn.backward")
                                .font(.bunkerLabel)
                                .foregroundStyle(Color.bunkerTextTertiary)

                            Label(decision.timeHorizon.rawValue, systemImage: "clock")
                                .font(.bunkerLabel)
                                .foregroundStyle(Color.bunkerTextTertiary)
                        }
                        .padding(.top, Spacing.xs)
                    }

                    Divider()
                        .background(Color.bunkerDivider)

                    // Criteria
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Criteria")
                            .font(.bunkerHeading2)
                            .foregroundStyle(Color.bunkerTextPrimary)

                        ForEach(decision.criteria) { criteria in
                            HStack {
                                Text(criteria.name)
                                    .font(.bunkerBody)
                                    .foregroundStyle(Color.bunkerTextPrimary)

                                Spacer()

                                Text("Weight: \(criteria.importance)")
                                    .font(.bunkerCaption)
                                    .foregroundStyle(Color.bunkerPrimary)
                            }
                            .padding(Spacing.sm)
                            .background(Color.bunkerSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }

                    // Options
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Options")
                            .font(.bunkerHeading2)
                            .foregroundStyle(Color.bunkerTextPrimary)

                        ForEach(decision.options, id: \.self) { option in
                            HStack {
                                Image(systemName: "square.stack.3d.up.fill")
                                    .font(.bunkerCaption)
                                    .foregroundStyle(Color.bunkerPrimary)

                                Text(option)
                                    .font(.bunkerBody)
                                    .foregroundStyle(Color.bunkerTextPrimary)

                                Spacer()
                            }
                            .padding(Spacing.sm)
                            .background(Color.bunkerSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }

                    // Outcomes if available
                    if !outcomes.isEmpty {
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("Recommendation")
                                .font(.bunkerHeading2)
                                .foregroundStyle(Color.bunkerTextPrimary)

                            if let top = outcomes.first {
                                HStack {
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundStyle(Color.bunkerSuccess)

                                    Text(top.option)
                                        .font(.bunkerHeading3)
                                        .foregroundStyle(Color.bunkerTextPrimary)

                                    Spacer()

                                    Text("Score: \(String(format: "%.1f", top.weightedScore))")
                                        .font(.bunkerBody)
                                        .foregroundStyle(Color.bunkerPrimary)
                                }
                                .padding(Spacing.md)
                                .background(Color.bunkerSuccess.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.bunkerSuccess.opacity(0.3), lineWidth: 1)
                                )
                            }
                        }
                    }

                    Spacer(minLength: Spacing.xl)
                }
                .padding(Spacing.md)
            }
            .background(Color.bunkerBackground)
            .navigationTitle("Share Decision")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(
                        item: shareText,
                        subject: Text("Decision: \(decision.title)"),
                        message: Text("Check out my decision framework")
                    ) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
    }

    private var shareText: String {
        var text = "📋 \(decision.title)\n"
        if !decision.description.isEmpty {
            text += "\(decision.description)\n"
        }
        text += "\n🎯 Criteria:\n"
        for criteria in decision.criteria {
            text += "• \(criteria.name) (weight: \(criteria.importance))\n"
        }
        text += "\n📊 Options:\n"
        for option in decision.options {
            text += "• \(option)\n"
        }
        if let top = outcomes.first {
            text += "\n✅ Recommended: \(top.option) (score: \(String(format: "%.1f", top.weightedScore)))\n"
        }
        text += "\nMade with Bunker"
        return text
    }
}

#Preview {
    ShareDecisionView(decision: .preview, outcomes: [])
        .preferredColorScheme(.dark)
}
