import SwiftUI

// MARK: - Empty State Views

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?

    init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.bunkerPrimary.opacity(0.1))
                    .frame(width: 120, height: 120)

                Circle()
                    .fill(Color.bunkerPrimary.opacity(0.05))
                    .frame(width: 160, height: 160)

                Image(systemName: icon)
                    .font(.system(size: 48))
                    .foregroundStyle(Color.bunkerPrimary)
            }

            VStack(spacing: Spacing.sm) {
                Text(title)
                    .font(.bunkerHeading2)
                    .foregroundStyle(Color.bunkerTextPrimary)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(.bunkerBody)
                    .foregroundStyle(Color.bunkerTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            if let actionTitle = actionTitle, let action = action {
                Button {
                    action()
                } label: {
                    Text(actionTitle)
                        .font(.bunkerHeading3)
                        .foregroundStyle(Color.bunkerBackground)
                        .padding(.horizontal, Spacing.xl)
                        .padding(.vertical, Spacing.sm)
                        .background(Color.bunkerPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.top, Spacing.sm)
            }

            Spacer()
        }
        .padding(Spacing.xl)
    }
}

// MARK: - Specific Empty States

struct NoDecisionsEmptyState: View {
    let onCreateDecision: () -> Void

    var body: some View {
        EmptyStateView(
            icon: "rectangle.stack.badge.plus",
            title: "No Decisions Yet",
            message: "High-stakes decisions deserve structure.\nCreate your first decision to get started.",
            actionTitle: "Create Decision",
            action: onCreateDecision
        )
    }
}

struct NoOutcomesEmptyState: View {
    var body: some View {
        EmptyStateView(
            icon: "chart.bar.xaxis",
            title: "No Outcomes Yet",
            message: "Simulate decisions to see outcome\nhistory and learn from patterns.",
            actionTitle: nil,
            action: nil
        )
    }
}

struct NoStatsEmptyState: View {
    var body: some View {
        EmptyStateView(
            icon: "chart.pie",
            title: "Not Enough Data",
            message: "Make more decisions to see\npersonal analytics and insights.",
            actionTitle: nil,
            action: nil
        )
    }
}

struct NoTemplatesEmptyState: View {
    let onCreateTemplate: () -> Void

    var body: some View {
        EmptyStateView(
            icon: "doc.on-doc",
            title: "No Templates Yet",
            message: "Save your decision frameworks as\ntemplates for faster future decisions.",
            actionTitle: "Create Template",
            action: onCreateTemplate
        )
    }
}

struct NoGroupsEmptyState: View {
    let onCreateGroup: () -> Void

    var body: some View {
        EmptyStateView(
            icon: "folder.badge.plus",
            title: "No Groups Yet",
            message: "Organize decisions by category\nlike Work, Personal, or Finance.",
            actionTitle: "Create Group",
            action: onCreateGroup
        )
    }
}

#Preview("No Decisions") {
    NoDecisionsEmptyState(onCreateDecision: {})
        .background(Color.bunkerBackground)
        .preferredColorScheme(.dark)
}
