import SwiftUI

struct MacCriteriaRow: View {
    let criteria: Criteria
    let options: [String]
    let decisionId: UUID
    let criteriaIndex: Int
    let onScoreChange: (Int, Int) -> Void
    let onDelete: () -> Void

    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            // Main Row
            HStack(spacing: 12) {
                // Importance indicator
                importanceBadge

                VStack(alignment: .leading, spacing: 2) {
                    Text(criteria.name)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(BunkerColors.textPrimary)
                    Text("Weight: \(criteria.importance)/10")
                        .font(.system(size: 11))
                        .foregroundColor(BunkerColors.textTertiary)
                }

                Spacer()

                // Quick score display
                if !options.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(0..<min(options.count, 5), id: \.self) { optIdx in
                            let score = criteriaScore(for: optIdx)
                            Text(score > 0 ? "\(score)" : "-")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(score > 0 ? BunkerColors.accent : BunkerColors.textTertiary)
                                .frame(width: 20)
                        }
                    }
                }

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isExpanded.toggle()
                    }
                } label: {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(BunkerColors.textTertiary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isExpanded ? "Collapse scoring details" : "Expand scoring details")
                .accessibilityHint("Shows or hides per-option scoring for this criterion")

                Button {
                    onDelete()
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 12))
                        .foregroundColor(BunkerColors.error.opacity(0.7))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Delete criterion")
                .accessibilityHint("Removes this criterion from the decision")
            }
            .padding(12)
            .background(isExpanded ? BunkerColors.surfaceSecondary : BunkerColors.surface)

            // Expanded scoring view
            if isExpanded && !options.isEmpty {
                VStack(spacing: 8) {
                    ForEach(Array(options.enumerated()), id: \.offset) { optIdx, option in
                        HStack {
                            Text(option)
                                .font(.system(size: 13))
                                .foregroundColor(BunkerColors.textSecondary)
                                .frame(width: 120, alignment: .leading)

                            Slider(
                                value: Binding(
                                    get: { Double(criteriaScore(for: optIdx)) },
                                    set: { onScoreChange(optIdx, Int($0)) }
                                ),
                                in: 1...10,
                                step: 1
                            )
                            .accentColor(BunkerColors.accent)

                            Text("\(criteriaScore(for: optIdx))")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(BunkerColors.accent)
                                .frame(width: 24)
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

    private var importanceBadge: some View {
        ZStack {
            Circle()
                .fill(importanceColor.opacity(0.2))
                .frame(width: 32, height: 32)
            Text("\(criteria.importance)")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(importanceColor)
        }
    }

    private var importanceColor: Color {
        if criteria.importance >= 8 {
            return BunkerColors.error
        } else if criteria.importance >= 6 {
            return BunkerColors.warning
        } else if criteria.importance >= 4 {
            return BunkerColors.primary
        } else {
            return BunkerColors.textTertiary
        }
    }

    private func criteriaScore(for optionIndex: Int) -> Int {
        let optionId = UUID(uuidString: "\(decisionId.uuidString)-\(optionIndex)") ?? UUID()
        return criteria.score(for: optionId)
    }
}
