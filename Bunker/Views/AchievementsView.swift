import SwiftUI

struct AchievementsView: View {
    @State private var achievements: [AchievementService.Achievement] = []
    @State private var totalAchievements = 0
    @State private var tierStats: [AchievementService.BadgeTier: Int] = [:]

    var body: some View {
        ZStack {
            Color.bunkerBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: Spacing.lg) {
                    progressHeader
                    tierSection
                    allAchievementsSection
                }
                .padding(Spacing.md)
            }
        }
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            loadAchievements()
        }
    }

    private var progressHeader: some View {
        VStack(spacing: Spacing.md) {
            HStack(spacing: Spacing.lg) {
                statBox(value: "\(totalAchievements)", label: "Earned", color: Color.bunkerPrimary)
                statBox(value: "\(AchievementService.AchievementType.allCases.count - totalAchievements)", label: "Remaining", color: Color.bunkerTextTertiary)
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.bunkerDivider)
                        .frame(height: 12)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [Color.bunkerPrimary, Color.bunkerAccent],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progressPercent, height: 12)
                }
            }
            .frame(height: 12)

            Text("\(Int(progressPercent * 100))% complete")
                .font(.bunkerCaption)
                .foregroundStyle(Color.bunkerTextSecondary)
        }
        .padding(Spacing.md)
        .background(Color.bunkerSurfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func statBox(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.bunkerDisplay)
                .foregroundStyle(color)
            Text(label)
                .font(.bunkerCaption)
                .foregroundStyle(Color.bunkerTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var tierSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Badge Collection")
                .font(.bunkerHeading3)
                .foregroundStyle(Color.bunkerTextPrimary)

            HStack(spacing: Spacing.md) {
                ForEach([AchievementService.BadgeTier.platinum, .gold, .silver, .bronze], id: \.self) { tier in
                    tierBadge(tier)
                }
            }
        }
    }

    private func tierBadge(_ tier: AchievementService.BadgeTier) -> some View {
        let count = tierStats[tier] ?? 0
        let tierAchievements = AchievementService.AchievementType.allCases.filter { $0.tier == tier }
        let total = tierAchievements.count

        return VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(tierColor(tier))
                    .frame(width: 56, height: 56)

                Image(systemName: tierIcon(tier))
                    .font(.title2)
                    .foregroundStyle(.white)
            }

            Text("\(count)/\(total)")
                .font(.bunkerCaption)
                .foregroundStyle(Color.bunkerTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func tierColor(_ tier: AchievementService.BadgeTier) -> Color {
        switch tier {
        case .bronze: return Color(hex: "#CD7F32")
        case .silver: return Color(hex: "#C0C0C0")
        case .gold: return Color(hex: "#FFD700")
        case .platinum: return Color(hex: "#E5E4E2")
        }
    }

    private func tierIcon(_ tier: AchievementService.BadgeTier) -> String {
        switch tier {
        case .bronze: return "medal.fill"
        case .silver: return "medal.fill"
        case .gold: return "crown.fill"
        case .platinum: return "star.fill"
        }
    }

    private var allAchievementsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("All Achievements")
                .font(.bunkerHeading3)
                .foregroundStyle(Color.bunkerTextPrimary)

            ForEach(AchievementService.AchievementType.allCases, id: \.self) { type in
                achievementRow(type)
            }
        }
    }

    private func achievementRow(_ type: AchievementService.AchievementType) -> some View {
        let isUnlocked = achievements.contains { $0.type == type }
        let achievement = achievements.first { $0.type == type }

        return HStack(spacing: Spacing.md) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? tierColor(type.tier) : Color.bunkerDivider)
                    .frame(width: 48, height: 48)

                Image(systemName: type.icon)
                    .font(.title3)
                    .foregroundStyle(isUnlocked ? .white : Color.bunkerTextTertiary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(type.title)
                    .font(.bunkerBody)
                    .foregroundStyle(isUnlocked ? Color.bunkerTextPrimary : Color.bunkerTextTertiary)

                Text(type.description)
                    .font(.bunkerCaption)
                    .foregroundStyle(Color.bunkerTextSecondary)

                if let achievement = achievement, isUnlocked {
                    Text("Earned \(achievement.earnedAt.formatted(date: .abbreviated, time: .omitted))")
                        .font(.bunkerCaption)
                        .foregroundStyle(Color.bunkerTextTertiary)
                }
            }

            Spacer()

            if isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color.bunkerSuccess)
            } else {
                Image(systemName: "lock.fill")
                    .foregroundStyle(Color.bunkerTextTertiary)
            }
        }
        .padding(Spacing.sm)
        .background(Color.bunkerSurfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .opacity(isUnlocked ? 1.0 : 0.6)
    }

    private var progressPercent: Double {
        guard AchievementService.AchievementType.allCases.count > 0 else { return 0 }
        return Double(totalAchievements) / Double(AchievementService.AchievementType.allCases.count)
    }

    private func loadAchievements() {
        achievements = AchievementService.shared.getUnlockedAchievements()
        totalAchievements = achievements.count
        tierStats = AchievementService.shared.achievementsByTier()
    }
}

#Preview {
    NavigationStack {
        AchievementsView()
    }
    .preferredColorScheme(.dark)
}
