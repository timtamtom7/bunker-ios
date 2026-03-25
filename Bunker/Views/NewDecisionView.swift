import SwiftUI

struct NewDecisionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var options: [String] = []
    @State private var newOption = ""
    @State private var stake: StakeLevel = .medium
    @State private var reversibility: Reversibility = .moderate
    @State private var timeHorizon: TimeHorizon = .mediumTerm
    @State private var showTemplatePicker = false

    let onSave: (Decision) -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    // Template picker
                    Button {
                        showTemplatePicker = true
                    } label: {
                        HStack {
                            Image(systemName: "doc.on.doc.fill")
                                .foregroundStyle(Color.bunkerAccent)
                            Text("Use a Template")
                                .font(.bunkerBodySmall)
                                .foregroundStyle(Color.bunkerAccent)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.bunkerCaption)
                                .foregroundStyle(Color.bunkerTextTertiary)
                        }
                        .padding(Spacing.sm)
                        .background(Color.bunkerAccent.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.bunkerAccent.opacity(0.3), lineWidth: 1)
                        )
                    }

                    // Title
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("What decision are you facing?")
                            .font(.bunkerHeading2)
                            .foregroundStyle(Color.bunkerTextPrimary)

                        TextField("e.g., Which city to move to", text: $title)
                            .font(.bunkerBody)
                            .textFieldStyle(.plain)
                            .padding(Spacing.sm)
                            .background(Color.bunkerSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    // Description
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Context (optional)")
                            .font(.bunkerHeading3)
                            .foregroundStyle(Color.bunkerTextPrimary)

                        TextField("Describe the situation and why this matters...", text: $description, axis: .vertical)
                            .font(.bunkerBody)
                            .textFieldStyle(.plain)
                            .lineLimit(3...6)
                            .padding(Spacing.sm)
                            .background(Color.bunkerSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    // Stake Framework
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Decision Context")
                            .font(.bunkerHeading3)
                            .foregroundStyle(Color.bunkerTextPrimary)

                        Text("Help AI give better advice by setting the stakes")
                            .font(.bunkerCaption)
                            .foregroundStyle(Color.bunkerTextTertiary)

                        // Stake Level
                        VStack(alignment: .leading, spacing: Spacing.xxs) {
                            HStack {
                                Text("Stake Level")
                                    .font(.bunkerLabel)
                                    .foregroundStyle(Color.bunkerTextSecondary)
                                Spacer()
                                Text(stake.rawValue)
                                    .font(.bunkerLabel)
                                    .foregroundStyle(Color(hex: stake.color))
                            }
                            Picker("Stake", selection: $stake) {
                                ForEach(StakeLevel.allCases, id: \.self) { level in
                                    Text(level.rawValue).tag(level)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding(Spacing.sm)
                        .background(Color.bunkerSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                        // Reversibility
                        VStack(alignment: .leading, spacing: Spacing.xxs) {
                            HStack {
                                Text("Reversibility")
                                    .font(.bunkerLabel)
                                    .foregroundStyle(Color.bunkerTextSecondary)
                                Spacer()
                                Text(reversibility.rawValue)
                                    .font(.bunkerLabel)
                                    .foregroundStyle(Color.bunkerTextSecondary)
                            }
                            Picker("Reversibility", selection: $reversibility) {
                                ForEach(Reversibility.allCases, id: \.self) { level in
                                    Text(level.rawValue).tag(level)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding(Spacing.sm)
                        .background(Color.bunkerSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                        // Time Horizon
                        VStack(alignment: .leading, spacing: Spacing.xxs) {
                            HStack {
                                Text("Time Horizon")
                                    .font(.bunkerLabel)
                                    .foregroundStyle(Color.bunkerTextSecondary)
                                Spacer()
                                Text(timeHorizon.rawValue)
                                    .font(.bunkerLabel)
                                    .foregroundStyle(Color.bunkerTextSecondary)
                            }
                            Picker("TimeHorizon", selection: $timeHorizon) {
                                ForEach(TimeHorizon.allCases, id: \.self) { level in
                                    Text(level.rawValue).tag(level)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding(Spacing.sm)
                        .background(Color.bunkerSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    // Options
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("What are your options?")
                            .font(.bunkerHeading2)
                            .foregroundStyle(Color.bunkerTextPrimary)

                        Text("Add at least 2 options to compare")
                            .font(.bunkerCaption)
                            .foregroundStyle(Color.bunkerTextTertiary)

                        ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                            HStack {
                                Image(systemName: "square.stack.3d.up.fill")
                                    .font(.bunkerCaption)
                                    .foregroundStyle(Color.bunkerPrimary)

                                Text(option)
                                    .font(.bunkerBody)
                                    .foregroundStyle(Color.bunkerTextPrimary)

                                Spacer()

                                Button {
                                    options.remove(at: index)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(Color.bunkerTextTertiary)
                                }
                            }
                            .padding(Spacing.sm)
                            .background(Color.bunkerSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }

                        HStack {
                            TextField("Add an option...", text: $newOption)
                                .font(.bunkerBody)
                                .textFieldStyle(.plain)
                                .padding(Spacing.sm)
                                .background(Color.bunkerSurface)
                                .clipShape(RoundedRectangle(cornerRadius: 8))

                            Button {
                                let trimmed = newOption.trimmingCharacters(in: .whitespaces)
                                if !trimmed.isEmpty {
                                    options.append(trimmed)
                                    newOption = ""
                                }
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundStyle(Color.bunkerPrimary)
                            }
                            .disabled(newOption.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                    }

                    Spacer(minLength: Spacing.xl)
                }
                .padding(Spacing.md)
            }
            .background(Color.bunkerBackground)
            .navigationTitle("New Decision")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        let decision = Decision(
                            title: title.trimmingCharacters(in: .whitespaces),
                            description: description.trimmingCharacters(in: .whitespaces),
                            options: options,
                            stake: stake,
                            reversibility: reversibility,
                            timeHorizon: timeHorizon
                        )
                        onSave(decision)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty || options.count < 2)
                }
            }
            .sheet(isPresented: $showTemplatePicker) {
                TemplatePickerView { template in
                    applyTemplate(template)
                }
            }
        }
    }

    private func applyTemplate(_ template: DecisionTemplate) {
        title = ""
        description = ""
        options = template.options
        stake = template.stake
        reversibility = template.reversibility
        timeHorizon = template.timeHorizon
    }
}

#Preview {
    NewDecisionView { _ in }
        .preferredColorScheme(.dark)
}
