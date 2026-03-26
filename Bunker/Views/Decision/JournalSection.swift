import SwiftUI

/// Journal section for adding timestamped notes to a decision
struct JournalSection: View {
    @Bindable var viewModel: DecisionDetailViewModel

    @State private var newEntryText: String = ""
    @State private var isEditing: Bool = false
    @FocusState private var isInputFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            headerRow

            if viewModel.decision.journalEntries.isEmpty {
                emptyState
            } else {
                journalList
            }

            inputRow
        }
    }

    private var headerRow: some View {
        HStack {
            Image(systemName: "book.closed.fill")
                .foregroundStyle(Color.bunkerAccent)
            Text("Decision Journal")
                .font(.bunkerHeading2)
                .foregroundStyle(Color.bunkerTextPrimary)

            Spacer()

            Text("\(viewModel.decision.journalEntries.count) entries")
                .font(.bunkerCaption)
                .foregroundStyle(Color.bunkerTextTertiary)
        }
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.xs) {
            Text("No journal entries yet")
                .font(.bunkerBodySmall)
                .foregroundStyle(Color.bunkerTextTertiary)

            Text("Capture your thoughts, reasoning, and observations as you work through this decision.")
                .font(.bunkerCaption)
                .foregroundStyle(Color.bunkerTextTertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.lg)
        .background(Color.bunkerSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var journalList: some View {
        VStack(spacing: 2) {
            ForEach(Array(viewModel.decision.journalEntries.sorted { $0.createdAt > $1.createdAt }.enumerated()), id: \.element.id) { index, entry in
                JournalEntryRow(entry: entry, onDelete: {
                    deleteEntry(entry)
                })
            }
        }
    }

    private var inputRow: some View {
        HStack(spacing: Spacing.sm) {
            TextField("Add a journal note...", text: $newEntryText)
                .font(.bunkerBody)
                .foregroundStyle(Color.bunkerTextPrimary)
                .padding(Spacing.sm)
                .background(Color.bunkerSurface)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .focused($isInputFocused)

            Button {
                addEntry()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundStyle(newEntryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.bunkerTextTertiary : Color.bunkerPrimary)
            }
            .disabled(newEntryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }

    private func addEntry() {
        let text = newEntryText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        let entry = JournalEntry(content: text)
        viewModel.decision.journalEntries.append(entry)
        newEntryText = ""
        isInputFocused = false

        Task {
            await viewModel.save()
        }
    }

    private func deleteEntry(_ entry: JournalEntry) {
        viewModel.decision.journalEntries.removeAll { $0.id == entry.id }
        Task {
            await viewModel.save()
        }
    }
}

// MARK: - Journal Entry Row

struct JournalEntryRow: View {
    let entry: JournalEntry
    let onDelete: () -> Void

    @State private var showDeleteConfirm = false

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            VStack(spacing: 2) {
                Circle()
                    .fill(Color.bunkerAccent)
                    .frame(width: 8, height: 8)

                Rectangle()
                    .fill(Color.bunkerDivider)
                    .frame(width: 1)
            }

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(entry.content)
                    .font(.bunkerBody)
                    .foregroundStyle(Color.bunkerTextPrimary)

                HStack(spacing: Spacing.xs) {
                    Image(systemName: "clock")
                        .font(.system(size: 10))
                    Text(formattedDate)
                        .font(.bunkerCaption)
                }
                .foregroundStyle(Color.bunkerTextTertiary)
            }

            Spacer()

            Button(role: .destructive) {
                showDeleteConfirm = true
            } label: {
                Image(systemName: "trash")
                    .font(.bunkerCaption)
                    .foregroundStyle(Color.bunkerError.opacity(0.7))
            }
        }
        .padding(.vertical, Spacing.xs)
        .padding(.horizontal, Spacing.sm)
        .background(Color.bunkerSurface)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .confirmationDialog("Delete Entry?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive, action: onDelete)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This journal entry will be permanently deleted.")
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Journal entry from \(formattedDate): \(entry.content)")
        .accessibilityHint("Double tap to delete")
    }

    private var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: entry.createdAt, relativeTo: Date())
    }
}

#Preview {
    JournalSection(viewModel: DecisionDetailViewModel(decision: .preview))
        .padding()
        .background(Color.bunkerBackground)
        .preferredColorScheme(.dark)
}
