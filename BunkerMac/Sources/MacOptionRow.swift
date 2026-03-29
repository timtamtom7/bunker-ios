import SwiftUI

struct MacOptionRow: View {
    let option: String
    let criteria: [Criteria]
    let decisionId: UUID
    let optionIndex: Int
    let onScoreChange: (Int, Int) -> Void
    let onDelete: () -> Void

    @State private var showScores = false

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                // Option indicator
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(BunkerColors.primary.opacity(0.2))
                        .frame(width: 32, height: 32)
                    Text("\(optionIndex + 1)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(BunkerColors.primary)
                }

                Text(option)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(BunkerColors.textPrimary)

                Spacer()

                // Score summary
                if !criteria.isEmpty {
                    HStack(spacing: 3) {
                        ForEach(criteria.prefix(4)) { crit in
                            let score = scoreForOption(criteria: crit)
                            Circle()
                                .fill(scoreColor(score))
                                .frame(width: 6, height: 6)
                        }
                        if criteria.count > 4 {
                            Text("+\(criteria.count - 4)")
                                .font(.system(size: 10))
                                .foregroundColor(BunkerColors.textTertiary)
                        }
                    }
                }

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showScores.toggle()
                    }
                } label: {
                    Image(systemName: showScores ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(BunkerColors.textTertiary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(showScores ? "Collapse criteria scores" : "Expand criteria scores")
                .accessibilityHint("Shows or hides per-criterion scoring for this option")

                Button {
                    onDelete()
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 12))
                        .foregroundColor(BunkerColors.error.opacity(0.7))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Delete option")
                .accessibilityHint("Removes this option from the decision")
            }
            .padding(12)
            .background(showScores ? BunkerColors.surfaceSecondary : BunkerColors.surface)

            // Expanded scores
            if showScores && !criteria.isEmpty {
                VStack(spacing: 6) {
                    ForEach(Array(criteria.enumerated()), id: \.element.id) { critIdx, criterion in
                        HStack {
                            Text(criterion.name)
                                .font(.system(size: 12))
                                .foregroundColor(BunkerColors.textSecondary)
                                .frame(width: 100, alignment: .leading)

                            Slider(
                                value: Binding(
                                    get: { Double(scoreForOption(criteria: criterion)) },
                                    set: { onScoreChange(critIdx, Int($0)) }
                                ),
                                in: 1...10,
                                step: 1
                            )
                            .accentColor(BunkerColors.primary)

                            Text("\(scoreForOption(criteria: criterion))")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(BunkerColors.primary)
                                .frame(width: 20)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
                .background(BunkerColors.surfaceSecondary.opacity(0.5))
            }
        }
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(BunkerColors.divider.opacity(0.5), lineWidth: 1)
        )
    }

    private func scoreForOption(criteria: Criteria) -> Int {
        let optionId = UUID(uuidString: "\(decisionId.uuidString)-\(optionIndex)") ?? UUID()
        return criteria.score(for: optionId)
    }

    private func scoreColor(_ score: Int) -> Color {
        if score == 0 {
            return BunkerColors.textTertiary
        } else if score >= 8 {
            return BunkerColors.success
        } else if score >= 5 {
            return BunkerColors.primary
        } else {
            return BunkerColors.warning
        }
    }
}
