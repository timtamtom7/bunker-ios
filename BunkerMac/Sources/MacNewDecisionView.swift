import SwiftUI

struct MacNewDecisionView: View {
    @Binding var decisions: [Decision]
    @Binding var selectedDecision: Decision?
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var description = ""
    @State private var stake: StakeLevel = .medium
    @State private var reversibility: Reversibility = .moderate
    @State private var timeHorizon: TimeHorizon = .mediumTerm

    private let service = DecisionService.shared

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("New Decision")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(BunkerColors.textPrimary)
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

            // Form
            ScrollView {
                VStack(spacing: 20) {
                    // Title
                    VStack(alignment: .leading, spacing: 8) {
                        Text("TITLE")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(BunkerColors.primary)
                        TextField("What decision are you making?", text: $title)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(BunkerColors.surfaceSecondary)
                            .cornerRadius(8)
                            .accessibilityLabel("Decision title")
                            .accessibilityHint("Enter the title of your decision")
                    }

                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("DESCRIPTION")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(BunkerColors.primary)
                        TextField("Describe the context...", text: $description, axis: .vertical)
                            .textFieldStyle(.plain)
                            .lineLimit(3...5)
                            .padding(12)
                            .background(BunkerColors.surfaceSecondary)
                            .cornerRadius(8)
                            .accessibilityLabel("Decision description")
                            .accessibilityHint("Describe the context and background for this decision")
                    }

                    // Stake Level
                    VStack(alignment: .leading, spacing: 8) {
                        Text("STAKE LEVEL")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(BunkerColors.textTertiary)
                        Picker("Stake Level", selection: $stake) {
                            ForEach(StakeLevel.allCases, id: \.self) { level in
                                Text(level.rawValue).tag(level)
                            }
                        }
                        .pickerStyle(.segmented)
                        .accessibilityLabel("Stake level")
                        .accessibilityHint("How important is this decision?")
                    }

                    // Reversibility
                    VStack(alignment: .leading, spacing: 8) {
                        Text("REVERSIBILITY")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(BunkerColors.textTertiary)
                        Picker("Reversibility", selection: $reversibility) {
                            ForEach(Reversibility.allCases, id: \.self) { level in
                                Text(level.rawValue).tag(level)
                            }
                        }
                        .pickerStyle(.segmented)
                        .accessibilityLabel("Reversibility")
                        .accessibilityHint("How easily can this decision be reversed if needed?")
                    }

                    // Time Horizon
                    VStack(alignment: .leading, spacing: 8) {
                        Text("TIME HORIZON")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(BunkerColors.textTertiary)
                        Picker("Time Horizon", selection: $timeHorizon) {
                            ForEach(TimeHorizon.allCases, id: \.self) { level in
                                Text(level.rawValue).tag(level)
                            }
                        }
                        .pickerStyle(.segmented)
                        .accessibilityLabel("Time horizon")
                        .accessibilityHint("Over what time period will the effects of this decision be felt?")
                    }
                }
                .padding(20)
            }
            .background(BunkerColors.background)

            Divider()
                .background(BunkerColors.divider)

            // Actions
            HStack {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(BunkerColors.textSecondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(BunkerColors.surfaceSecondary)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Cancel")
                .accessibilityHint("Closes this sheet without creating a decision")

                Spacer()

                Button {
                    Task { await createDecision() }
                    dismiss()
                } label: {
                    Text("Create Decision")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(BunkerColors.textPrimary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(title.isEmpty ? BunkerColors.textTertiary : BunkerColors.primary)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .disabled(title.isEmpty)
                .accessibilityLabel("Create decision")
                .accessibilityHint("Creates a new decision with the entered details")
            }
            .padding(20)
            .background(BunkerColors.surface)
        }
        .frame(width: 480, height: 560)
        .background(BunkerColors.background)
    }

    // MARK: - Actions
    private func createDecision() async {
        let newDecision = Decision(
            title: title.trimmingCharacters(in: .whitespaces),
            description: description.trimmingCharacters(in: .whitespaces),
            stake: stake,
            reversibility: reversibility,
            timeHorizon: timeHorizon
        )
        await service.saveDecision(newDecision)
        decisions = service.decisions
        selectedDecision = newDecision
    }
}
