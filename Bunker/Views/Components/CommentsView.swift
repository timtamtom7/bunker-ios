import SwiftUI

struct CommentsView: View {
    let decisionId: UUID
    @State private var comments: [DecisionComment] = []
    @State private var newComment = ""
    @State private var isLoading = true

    var body: some View {
        VStack(spacing: 0) {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if comments.isEmpty {
                emptyState
            } else {
                commentsList
            }

            Divider()
                .background(Color.bunkerDivider)

            commentInput
        }
        .background(Color.bunkerBackground)
        .task {
            await loadComments()
        }
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.sm) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 40))
                .foregroundStyle(Color.bunkerTextTertiary)

            Text("No comments yet")
                .font(.bunkerHeading3)
                .foregroundStyle(Color.bunkerTextPrimary)

            Text("Discuss this decision with collaborators.")
                .font(.bunkerCaption)
                .foregroundStyle(Color.bunkerTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Spacing.lg)
    }

    private var commentsList: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.md) {
                ForEach(comments) { comment in
                    CommentRow(comment: comment)
                }
            }
            .padding(Spacing.md)
        }
    }

    private var commentInput: some View {
        HStack(spacing: Spacing.sm) {
            TextField("Add a comment...", text: $newComment)
                .textFieldStyle(.plain)
                .padding(Spacing.sm)
                .background(Color.bunkerSurfaceCard)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .foregroundStyle(Color.bunkerTextPrimary)

            Button {
                submitComment()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundStyle(newComment.isEmpty ? Color.bunkerTextTertiary : Color.bunkerPrimary)
            }
            .disabled(newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(Spacing.md)
    }

    private func loadComments() async {
        isLoading = true
        defer { isLoading = false }

        // Load from local storage (placeholder for real implementation)
        try? await Task.sleep(nanoseconds: 300_000_000)
        // In production: load from Firebase/RealtimeDB
    }

    private func submitComment() {
        guard !newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let comment = DecisionComment(
            decisionId: decisionId,
            authorId: UUID(), // Current user
            authorName: "You",
            content: newComment
        )

        comments.append(comment)
        newComment = ""
    }
}

struct CommentRow: View {
    let comment: DecisionComment

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack {
                Circle()
                    .fill(Color.bunkerPrimary)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text(String(comment.authorName.prefix(1)))
                            .font(.bunkerCaption)
                            .foregroundStyle(Color.bunkerBackground)
                    )

                VStack(alignment: .leading, spacing: 0) {
                    Text(comment.authorName)
                        .font(.bunkerBodySmall)
                        .foregroundStyle(Color.bunkerTextPrimary)

                    Text(comment.formattedDate)
                        .font(.bunkerCaption)
                        .foregroundStyle(Color.bunkerTextTertiary)
                }

                Spacer()
            }

            Text(comment.content)
                .font(.bunkerBody)
                .foregroundStyle(Color.bunkerTextSecondary)
                .padding(.leading, 40)
        }
        .padding(Spacing.sm)
        .background(Color.bunkerSurfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    CommentsView(decisionId: UUID())
        .preferredColorScheme(.dark)
}
