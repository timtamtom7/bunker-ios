import SwiftUI

struct NewDecisionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var options: [String] = []
    @State private var newOption = ""

    let onSave: (Decision) -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
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
                            options: options
                        )
                        onSave(decision)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty || options.count < 2)
                }
            }
        }
    }
}

#Preview {
    NewDecisionView { _ in }
        .preferredColorScheme(.dark)
}
