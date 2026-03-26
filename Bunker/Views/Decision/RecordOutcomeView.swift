import SwiftUI

/// View for recording the actual outcome of a decision after it has been resolved
struct RecordOutcomeView: View {
    @Bindable var viewModel: DecisionDetailViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var selectedOption: String?
    @State private var isGoodOutcome: Bool?
    @State private var reflection: String = ""
    @State private var showDiscardAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bunkerBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Spacing.xl) {
                        headerSection
                        optionSection
                        outcomeSection
                        reflectionSection
                        Spacer(minLength: Spacing.xxl)
                    }
                    .padding(Spacing.md)
                }
            }
            .navigationTitle("Record Outcome")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        if viewModel.decision.isResolved {
                            dismiss()
                        } else {
                            showDiscardAlert = true
                        }
                    }
                    .foregroundStyle(Color.bunkerTextSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveOutcome()
                        dismiss()
                    }
                    .foregroundStyle(Color.bunkerPrimary)
                    .disabled(selectedOption == nil || isGoodOutcome == nil)
                }
            }
            .alert("Discard Outcome?", isPresented: $showDiscardAlert) {
                Button("Discard", role: .destructive) {
                    clearOutcome()
                    dismiss()
                }
                Button("Keep Editing", role: .cancel) {}
            } message: {
                Text("Your recorded outcome will be discarded.")
            }
            .onAppear {
                loadExisting()
            }
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Image(systemName: "checkmark.seal.fill")
                    .font(.title)
                    .foregroundStyle(Color.bunkerSuccess)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Close the Loop")
                        .font(.bunkerHeading2)
                        .foregroundStyle(Color.bunkerTextPrimary)
                    Text("Record what you decided and how it turned out.")
                        .font(.bunkerBodySmall)
                        .foregroundStyle(Color.bunkerTextSecondary)
                }
            }
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.bunkerSuccess.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.bunkerSuccess.opacity(0.3), lineWidth: 1)
        )
    }

    private var optionSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("What did you decide?")
                .font(.bunkerHeading3)
                .foregroundStyle(Color.bunkerTextPrimary)

            Text("Select the option you went with.")
                .font(.bunkerCaption)
                .foregroundStyle(Color.bunkerTextTertiary)

            ForEach(viewModel.decision.options, id: \.self) { option in
                Button {
                    selectedOption = option
                } label: {
                    HStack {
                        Image(systemName: selectedOption == option ? "checkmark.circle.fill" : "circle")
                            .font(.body)
                            .foregroundStyle(selectedOption == option ? Color.bunkerPrimary : Color.bunkerTextTertiary)

                        Text(option)
                            .font(.bunkerBody)
                            .foregroundStyle(Color.bunkerTextPrimary)

                        Spacer()

                        if let index = viewModel.decision.options.firstIndex(of: option),
                           let outcome = viewModel.outcomes.first(where: { $0.option == option }) {
                            Text("Score: \(String(format: "%.1f", outcome.weightedScore))")
                                .font(.bunkerCaption)
                                .foregroundStyle(Color.bunkerTextTertiary)
                        }
                    }
                    .padding(Spacing.sm)
                    .background(selectedOption == option ? Color.bunkerPrimary.opacity(0.1) : Color.bunkerSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(selectedOption == option ? Color.bunkerPrimary.opacity(0.3) : Color.clear, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var outcomeSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("How did it turn out?")
                .font(.bunkerHeading3)
                .foregroundStyle(Color.bunkerTextPrimary)

            Text("Be honest — this helps calibrate your future decisions.")
                .font(.bunkerCaption)
                .foregroundStyle(Color.bunkerTextTertiary)

            HStack(spacing: Spacing.md) {
                outcomeButton(
                    emoji: "✅",
                    label: "Good",
                    isSelected: isGoodOutcome == true
                ) {
                    isGoodOutcome = true
                }

                outcomeButton(
                    emoji: "❌",
                    label: "Bad",
                    isSelected: isGoodOutcome == false
                ) {
                    isGoodOutcome = false
                }
            }
        }
    }

    private func outcomeButton(emoji: String, label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: Spacing.sm) {
                Text(emoji)
                    .font(.system(size: 32))
                Text(label)
                    .font(.bunkerBodySmall)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(Spacing.lg)
            .background(isSelected ? Color.bunkerSuccess.opacity(0.15) : Color.bunkerSurface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.bunkerSuccess.opacity(0.4) : Color.bunkerDivider, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var reflectionSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Reflection (optional)")
                .font(.bunkerHeading3)
                .foregroundStyle(Color.bunkerTextPrimary)

            Text("What did you learn? Would you make the same decision again?")
                .font(.bunkerCaption)
                .foregroundStyle(Color.bunkerTextTertiary)

            TextEditor(text: $reflection)
                .font(.bunkerBody)
                .foregroundStyle(Color.bunkerTextPrimary)
                .scrollContentBackground(.hidden)
                .padding(Spacing.sm)
                .frame(minHeight: 120)
                .background(Color.bunkerSurface)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    Group {
                        if reflection.isEmpty {
                            Text("Write your thoughts...")
                                .font(.bunkerBody)
                                .foregroundStyle(Color.bunkerTextTertiary)
                                .padding(Spacing.md)
                                .allowsHitTesting(false)
                        }
                    },
                    alignment: .topLeading
                )
        }
    }

    // MARK: - Actions

    private func loadExisting() {
        if let existing = viewModel.decision.resolvedOption {
            selectedOption = existing
        }
        isGoodOutcome = viewModel.decision.isGoodOutcome
        reflection = viewModel.decision.outcomeReflection ?? ""
    }

    private func saveOutcome() {
        guard let option = selectedOption, let good = isGoodOutcome else { return }
        viewModel.decision.resolvedOption = option
        viewModel.decision.isGoodOutcome = good
        viewModel.decision.resolvedAt = Date()
        viewModel.decision.outcomeReflection = reflection.isEmpty ? nil : reflection
        Task {
            await viewModel.save()
        }
    }

    private func clearOutcome() {
        viewModel.decision.resolvedOption = nil
        viewModel.decision.isGoodOutcome = nil
        viewModel.decision.resolvedAt = nil
        viewModel.decision.outcomeReflection = nil
    }
}

#Preview {
    RecordOutcomeView(viewModel: DecisionDetailViewModel(decision: .preview))
        .preferredColorScheme(.dark)
}
