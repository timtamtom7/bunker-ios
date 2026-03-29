import SwiftUI

/// R12: Share decisions with trusted advisors for feedback and scoring
struct MacAdvisorShareView: View {
    let decision: Decision
    @State private var advisors: [Advisor] = []
    @State private var shares: [AdvisorShare] = []
    @State private var showAddAdvisor = false
    @State private var newAdvisorName = ""
    @State private var newAdvisorTitle = ""
    @State private var newAdvisorSpecialty = ""
    @State private var selectedAdvisorForShare: Advisor?
    @State private var showShareSheet = false
    @Environment(\.dismiss) private var dismiss

    private let shareService = AdvisorShareService.shared

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView

            Divider()
                .background(BunkerColors.divider)

            ScrollView {
                VStack(spacing: 24) {
                    // Decision Summary
                    decisionSummary

                    // Advisors Section
                    advisorsSection

                    // Shares / Feedback Section
                    feedbackSection
                }
                .padding(24)
            }
        }
        .background(BunkerColors.background)
        .sheet(isPresented: $showAddAdvisor) {
            addAdvisorSheet
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Share with Advisors")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(BunkerColors.textPrimary)

                Text("Get expert feedback on your decision")
                    .font(.system(size: 12))
                    .foregroundColor(BunkerColors.textSecondary)
            }

            Spacer()

            Button {
                showAddAdvisor = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                    Text("Add Advisor")
                }
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(BunkerColors.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(BunkerColors.primary.opacity(0.1))
                .cornerRadius(8)
            }
            .buttonStyle(.plain)

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .foregroundColor(BunkerColors.textSecondary)
                    .frame(width: 28, height: 28)
                    .background(BunkerColors.surfaceSecondary)
                    .cornerRadius(6)
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(BunkerColors.surface)
    }

    // MARK: - Decision Summary

    private var decisionSummary: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Decision")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(BunkerColors.textTertiary)
                .textCase(.uppercase)

            VStack(alignment: .leading, spacing: 8) {
                Text(decision.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(BunkerColors.textPrimary)

                if !decision.description.isEmpty {
                    Text(decision.description)
                        .font(.system(size: 13))
                        .foregroundColor(BunkerColors.textSecondary)
                        .lineLimit(2)
                }

                HStack(spacing: 12) {
                    Label("\(decision.criteria.count) criteria", systemImage: "list.bullet")
                    Label("\(decision.options.count) options", systemImage: "circle.grid.2x2")
                }
                .font(.system(size: 12))
                .foregroundColor(BunkerColors.textTertiary)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(BunkerColors.surface)
            .cornerRadius(12)
        }
    }

    // MARK: - Advisors Section

    private var advisorsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Your Advisors")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(BunkerColors.textTertiary)
                    .textCase(.uppercase)

                Spacer()

                if advisors.isEmpty {
                    Text("No advisors yet")
                        .font(.system(size: 12))
                        .foregroundColor(BunkerColors.textTertiary)
                }
            }

            if advisors.isEmpty {
                emptyAdvisorsState
            } else {
                VStack(spacing: 8) {
                    ForEach(advisors) { advisor in
                        advisorRow(advisor)
                    }
                }
            }
        }
    }

    private var emptyAdvisorsState: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.2.badge.gearshape")
                .font(.system(size: 32))
                .foregroundColor(BunkerColors.textTertiary)

            Text("Add trusted advisors")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(BunkerColors.textSecondary)

            Text("They can score and comment on your decisions")
                .font(.system(size: 12))
                .foregroundColor(BunkerColors.textTertiary)
                .multilineTextAlignment(.center)

            Button {
                showAddAdvisor = true
            } label: {
                Text("Add Your First Advisor")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(BunkerColors.primary)
                    .cornerRadius(8)
            }
            .buttonStyle(.plain)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(BunkerColors.surface)
        .cornerRadius(12)
    }

    private func advisorRow(_ advisor: Advisor) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(hex: advisor.avatarColor))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(String(advisor.name.prefix(1)).uppercased())
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(advisor.displayName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(BunkerColors.textPrimary)

                if let specialty = advisor.specialty {
                    Text(specialty)
                        .font(.system(size: 12))
                        .foregroundColor(BunkerColors.textTertiary)
                }
            }

            Spacer()

            Button {
                shareWithAdvisor(advisor)
            } label: {
                Text("Share")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(BunkerColors.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(BunkerColors.primary.opacity(0.1))
                    .cornerRadius(6)
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(BunkerColors.surface)
        .cornerRadius(10)
    }

    // MARK: - Feedback Section

    private var feedbackSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Advisor Feedback")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(BunkerColors.textTertiary)
                .textCase(.uppercase)

            if shares.isEmpty {
                emptyFeedbackState
            } else {
                VStack(spacing: 12) {
                    ForEach(shares) { share in
                        feedbackCard(share)
                    }
                }
            }
        }
    }

    private var emptyFeedbackState: some View {
        VStack(spacing: 8) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 28))
                .foregroundColor(BunkerColors.textTertiary)

            Text("No feedback yet")
                .font(.system(size: 13))
                .foregroundColor(BunkerColors.textSecondary)

            Text("Share your decision with advisors to get their input")
                .font(.system(size: 12))
                .foregroundColor(BunkerColors.textTertiary)
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(BunkerColors.surface)
        .cornerRadius(12)
    }

    private func feedbackCard(_ share: AdvisorShare) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color(hex: share.advisor.avatarColor))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Text(String(share.advisor.name.prefix(1)).uppercased())
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(share.advisor.displayName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(BunkerColors.textPrimary)

                    Text("Shared \(formatDate(share.sharedAt))")
                        .font(.system(size: 11))
                        .foregroundColor(BunkerColors.textTertiary)
                }

                Spacer()

                if let score = share.score {
                    scoreBadge(score)
                } else {
                    Text("Awaiting response")
                        .font(.system(size: 11))
                        .foregroundColor(BunkerColors.warning)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(BunkerColors.warning.opacity(0.1))
                        .cornerRadius(4)
                }
            }

            if let comments = share.comments, !comments.isEmpty {
                Text(comments)
                    .font(.system(size: 13))
                    .foregroundColor(BunkerColors.textSecondary)
                    .padding(12)
                    .background(BunkerColors.surfaceSecondary)
                    .cornerRadius(8)
            }
        }
        .padding(16)
        .background(BunkerColors.surface)
        .cornerRadius(12)
    }

    private func scoreBadge(_ score: Int) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .font(.system(size: 10))
                .foregroundColor(BunkerColors.warning)

            Text("\(score)/10")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(BunkerColors.textPrimary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(BunkerColors.warning.opacity(0.15))
        .cornerRadius(6)
    }

    // MARK: - Add Advisor Sheet

    private var addAdvisorSheet: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text("Add Advisor")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(BunkerColors.textPrimary)

                Spacer()

                Button {
                    showAddAdvisor = false
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(BunkerColors.textSecondary)
                }
                .buttonStyle(.plain)
            }

            Divider()
                .background(BunkerColors.divider)

            // Form
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Name")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(BunkerColors.textSecondary)

                    TextField("Dr. Jane Smith", text: $newAdvisorName)
                        .textFieldStyle(.plain)
                        .font(.system(size: 14))
                        .foregroundColor(BunkerColors.textPrimary)
                        .padding(12)
                        .background(BunkerColors.surfaceSecondary)
                        .cornerRadius(8)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Title (optional)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(BunkerColors.textSecondary)

                    TextField("Dr., Prof., Mr., Ms...", text: $newAdvisorTitle)
                        .textFieldStyle(.plain)
                        .font(.system(size: 14))
                        .foregroundColor(BunkerColors.textPrimary)
                        .padding(12)
                        .background(BunkerColors.surfaceSecondary)
                        .cornerRadius(8)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Specialty (optional)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(BunkerColors.textSecondary)

                    TextField("Finance, Technology, Medicine...", text: $newAdvisorSpecialty)
                        .textFieldStyle(.plain)
                        .font(.system(size: 14))
                        .foregroundColor(BunkerColors.textPrimary)
                        .padding(12)
                        .background(BunkerColors.surfaceSecondary)
                        .cornerRadius(8)
                }
            }

            Spacer()

            // Actions
            HStack(spacing: 12) {
                Button {
                    showAddAdvisor = false
                } label: {
                    Text("Cancel")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(BunkerColors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(BunkerColors.surfaceSecondary)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)

                Button {
                    addAdvisor()
                } label: {
                    Text("Add Advisor")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(newAdvisorName.isEmpty ? BunkerColors.textTertiary : BunkerColors.primary)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .disabled(newAdvisorName.isEmpty)
            }
        }
        .padding(24)
        .frame(width: 400, height: 420)
        .background(BunkerColors.background)
    }

    // MARK: - Helpers

    private func addAdvisor() {
        let advisor = Advisor(
            name: newAdvisorName,
            title: newAdvisorTitle.isEmpty ? nil : newAdvisorTitle,
            specialty: newAdvisorSpecialty.isEmpty ? nil : newAdvisorSpecialty
        )
        advisors.append(advisor)
        newAdvisorName = ""
        newAdvisorTitle = ""
        newAdvisorSpecialty = ""
        showAddAdvisor = false
    }

    private func shareWithAdvisor(_ advisor: Advisor) {
        let share = shareService.shareWithAdvisor(decisionId: decision.id, advisor: advisor)
        shares.append(share)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Preview

#Preview {
    MacAdvisorShareView(decision: .preview)
        .frame(width: 600, height: 700)
}
