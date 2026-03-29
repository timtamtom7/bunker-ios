import SwiftUI

/// R12: Team Decision Room View for collaborative voting on decisions
struct DecisionRoomView: View {
    let room: DecisionRoom
    @State private var selectedOptionIndex: Int?
    @State private var hasVoted = false
    @State private var showResults = false
    @Environment(\.dismiss) private var dismiss

    // Mock current user (in real app, this comes from auth)
    private let currentUser = Participant(name: "You", avatarColor: "4A90D9")

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView

            Divider()
                .background(BunkerColors.divider)

            ScrollView {
                VStack(spacing: 24) {
                    // Decision Info
                    decisionInfoSection

                    // Participants
                    participantsSection

                    // Voting or Results
                    if room.isClosed || hasVoted {
                        resultsSection
                    } else {
                        votingSection
                    }

                    // Invite Others
                    inviteSection
                }
                .padding(24)
            }
        }
        .background(BunkerColors.background)
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Decision Room")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(BunkerColors.textPrimary)

                HStack(spacing: 8) {
                    Circle()
                        .fill(room.isClosed ? BunkerColors.textTertiary : BunkerColors.success)
                        .frame(width: 8, height: 8)

                    Text(room.isClosed ? "Voting Closed" : "Voting Open")
                        .font(.system(size: 12))
                        .foregroundColor(BunkerColors.textSecondary)

                    Text("•")
                        .foregroundColor(BunkerColors.textTertiary)

                    Text("\(room.participants.count) participant\(room.participants.count == 1 ? "" : "s")")
                        .font(.system(size: 12))
                        .foregroundColor(BunkerColors.textSecondary)
                }
            }

            Spacer()

            if !room.isClosed && !hasVoted {
                Button {
                    submitVote()
                } label: {
                    Text("Submit Vote")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(selectedOptionIndex != nil ? BunkerColors.primary : BunkerColors.textTertiary)
                        .cornerRadius(8)
                }
                .disabled(selectedOptionIndex == nil)
            }

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

    // MARK: - Decision Info

    private var decisionInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Decision")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(BunkerColors.textTertiary)
                .textCase(.uppercase)

            VStack(alignment: .leading, spacing: 8) {
                Text(room.decision.title)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(BunkerColors.textPrimary)

                if !room.decision.description.isEmpty {
                    Text(room.decision.description)
                        .font(.system(size: 14))
                        .foregroundColor(BunkerColors.textSecondary)
                        .lineLimit(3)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(BunkerColors.surface)
            .cornerRadius(12)
        }
    }

    // MARK: - Participants

    private var participantsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Participants")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(BunkerColors.textTertiary)
                .textCase(.uppercase)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(room.participants) { participant in
                        participantAvatar(participant)
                    }

                    // Empty slots for anticipated participants
                    ForEach(0..<max(0, 5 - room.participants.count), id: \.self) { _ in
                        emptyAvatarSlot
                    }
                }
            }
        }
    }

    private func participantAvatar(_ participant: Participant) -> some View {
        VStack(spacing: 6) {
            Circle()
                .fill(Color(hex: participant.avatarColor))
                .frame(width: 44, height: 44)
                .overlay(
                    Text(String(participant.name.prefix(1)).uppercased())
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                )

            Text(participant.name.split(separator: " ").first.map(String.init) ?? participant.name)
                .font(.system(size: 11))
                .foregroundColor(BunkerColors.textSecondary)
                .lineLimit(1)

            // Vote status
            if room.isClosed || hasVoted {
                Image(systemName: room.hasVoted(participantId: participant.id) ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 10))
                    .foregroundColor(room.hasVoted(participantId: participant.id) ? BunkerColors.success : BunkerColors.textTertiary)
            }
        }
    }

    private var emptyAvatarSlot: some View {
        VStack(spacing: 6) {
            Circle()
                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [4]))
                .foregroundColor(BunkerColors.divider)
                .frame(width: 44, height: 44)

            Text("?")
                .font(.system(size: 11))
                .foregroundColor(BunkerColors.textTertiary)
        }
    }

    // MARK: - Voting Section

    private var votingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cast Your Vote")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(BunkerColors.textTertiary)
                .textCase(.uppercase)

            VStack(spacing: 8) {
                ForEach(Array(room.decision.options.enumerated()), id: \.offset) { index, option in
                    optionVoteButton(option: option, index: index)
                }
            }
        }
    }

    private func optionVoteButton(option: String, index: Int) -> some View {
        Button {
            selectedOptionIndex = index
        } label: {
            HStack {
                Circle()
                    .strokeBorder(selectedOptionIndex == index ? BunkerColors.primary : BunkerColors.divider, lineWidth: 2)
                    .background(Circle().fill(selectedOptionIndex == index ? BunkerColors.primary : Color.clear))
                    .frame(width: 22, height: 22)
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .opacity(selectedOptionIndex == index ? 1 : 0)
                    )

                Text(option)
                    .font(.system(size: 15))
                    .foregroundColor(BunkerColors.textPrimary)

                Spacer()

                Text("Option \(index + 1)")
                    .font(.system(size: 12))
                    .foregroundColor(BunkerColors.textTertiary)
            }
            .padding(14)
            .background(selectedOptionIndex == index ? BunkerColors.primary.opacity(0.1) : BunkerColors.surface)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(selectedOptionIndex == index ? BunkerColors.primary : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Results Section

    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Results")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(BunkerColors.textTertiary)
                    .textCase(.uppercase)

                Spacer()

                if room.isClosed {
                    Text("Final")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(BunkerColors.success)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(BunkerColors.success.opacity(0.15))
                        .cornerRadius(4)
                }
            }

            VStack(spacing: 12) {
                ForEach(Array(room.decision.options.enumerated()), id: \.offset) { index, option in
                    resultBar(option: option, index: index)
                }
            }
            .padding(16)
            .background(BunkerColors.surface)
            .cornerRadius(12)

            // Winner announcement
            if let winnerIndex = room.winningOptionIndex, room.isClosed {
                HStack {
                    Image(systemName: "trophy.fill")
                        .foregroundColor(BunkerColors.warning)

                    Text("Winner: \(room.decision.options[winnerIndex])")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(BunkerColors.textPrimary)
                }
                .padding(12)
                .frame(maxWidth: .infinity)
                .background(BunkerColors.warning.opacity(0.1))
                .cornerRadius(10)
            }
        }
    }

    private func resultBar(option: String, index: Int) -> some View {
        let count = room.voteTallies[index] ?? 0
        let totalVotes = room.participants.count
        let percentage = totalVotes > 0 ? Double(count) / Double(totalVotes) : 0
        let isWinner = room.winningOptionIndex == index

        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(option)
                    .font(.system(size: 14, weight: isWinner ? .semibold : .regular))
                    .foregroundColor(isWinner ? BunkerColors.textPrimary : BunkerColors.textSecondary)

                Spacer()

                Text("\(count) vote\(count == 1 ? "" : "s")")
                    .font(.system(size: 12))
                    .foregroundColor(BunkerColors.textTertiary)

                Text("\(Int(percentage * 100))%")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isWinner ? BunkerColors.primary : BunkerColors.textSecondary)
                    .frame(width: 40, alignment: .trailing)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(BunkerColors.surfaceSecondary)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(isWinner ? BunkerColors.primary : BunkerColors.accent)
                        .frame(width: geo.size.width * percentage)
                }
            }
            .frame(height: 8)
        }
    }

    // MARK: - Invite Section

    private var inviteSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Invite Others")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(BunkerColors.textTertiary)
                .textCase(.uppercase)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Join Code")
                        .font(.system(size: 12))
                        .foregroundColor(BunkerColors.textSecondary)

                    Text(room.inviteCode)
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(BunkerColors.primary)
                }

                Spacer()

                Button {
                    copyJoinCode()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "doc.on.doc")
                        Text("Copy")
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(BunkerColors.primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(BunkerColors.primary.opacity(0.1))
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            .background(BunkerColors.surface)
            .cornerRadius(12)

            Text("Expires \(formattedExpires(room.inviteExpiresAt))")
                .font(.system(size: 11))
                .foregroundColor(BunkerColors.textTertiary)
        }
    }

    // MARK: - Actions

    private func submitVote() {
        guard let optionIndex = selectedOptionIndex else { return }
        DecisionRoomService.shared.vote(
            roomId: room.id,
            participantId: currentUser.id,
            optionIndex: optionIndex
        )
        hasVoted = true
    }

    private func copyJoinCode() {
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(room.inviteCode, forType: .string)
        #endif
    }

    private func formattedExpires(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Preview

#Preview {
    DecisionRoomView(
        room: DecisionRoom(
            id: UUID(),
            decision: .preview,
            participants: [
                Participant(name: "Alice", avatarColor: "4A90D9"),
                Participant(name: "Bob", avatarColor: "38B2AC"),
                Participant(name: "Charlie", avatarColor: "68D391")
            ],
            votes: [:],
            createdAt: Date(),
            inviteCode: "ABC123",
            inviteExpiresAt: Date().addingTimeInterval(24 * 60 * 60)
        )
    )
    .frame(width: 600, height: 700)
}
