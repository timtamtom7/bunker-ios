import SwiftUI

struct DecisionStatsView: View {
    @State private var stats: DecisionStats?
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            Color.bunkerBackground.ignoresSafeArea()
            
            if isLoading {
                ProgressView()
                    .tint(Color.bunkerPrimary)
            } else if let stats = stats {
                statsContent(stats)
            }
        }
        .navigationTitle("Statistics")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await loadStats()
        }
    }
    
    private func statsContent(_ stats: DecisionStats) -> some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Overview card
                VStack(spacing: Spacing.md) {
                    HStack(spacing: Spacing.xl) {
                        statItem(title: "Total", value: "\(stats.totalDecisions)", icon: "rectangle.stack.fill")
                        statItem(title: "Completed", value: "\(stats.completedDecisions)", icon: "checkmark.circle.fill")
                        statItem(title: "Pending", value: "\(stats.pendingDecisions)", icon: "clock.fill")
                    }
                    
                    // Completion rate
                    VStack(spacing: Spacing.xs) {
                        HStack {
                            Text("Completion Rate")
                                .font(.bunkerBodySmall)
                                .foregroundStyle(Color.bunkerTextSecondary)
                            Spacer()
                            Text("\(Int(stats.completionRate * 100))%")
                                .font(.bunkerBodySmall)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.bunkerPrimary)
                        }
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.bunkerDivider)
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.bunkerPrimary)
                                    .frame(width: geometry.size.width * stats.completionRate)
                            }
                        }
                        .frame(height: 8)
                    }
                }
                .padding(Spacing.lg)
                .background(Color.bunkerSurfaceCard)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                // Averages card
                VStack(spacing: Spacing.md) {
                    HStack(spacing: Spacing.xl) {
                        VStack(spacing: 4) {
                            Text(String(format: "%.1f", stats.averageCriteriaPerDecision))
                                .font(.bunkerHeading1)
                                .foregroundStyle(Color.bunkerTextPrimary)
                            Text("Avg Criteria")
                                .font(.bunkerCaption)
                                .foregroundStyle(Color.bunkerTextSecondary)
                        }
                        
                        Divider().frame(height: 48)
                        
                        VStack(spacing: 4) {
                            Text(String(format: "%.1f", stats.averageOptionsPerDecision))
                                .font(.bunkerHeading1)
                                .foregroundStyle(Color.bunkerTextPrimary)
                            Text("Avg Options")
                                .font(.bunkerCaption)
                                .foregroundStyle(Color.bunkerTextSecondary)
                        }
                    }
                }
                .padding(Spacing.lg)
                .frame(maxWidth: .infinity)
                .background(Color.bunkerSurfaceCard)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                // Top criteria
                if !stats.topCriteria.isEmpty {
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Most Used Criteria")
                            .font(.bunkerHeading3)
                            .foregroundStyle(Color.bunkerTextSecondary)
                        
                        ForEach(Array(stats.topCriteria.enumerated()), id: \.offset) { index, criteria in
                            HStack {
                                Text("\(index + 1).")
                                    .font(.bunkerCaption)
                                    .foregroundStyle(Color.bunkerTextTertiary)
                                    .frame(width: 24, alignment: .leading)
                                
                                Text(criteria)
                                    .font(.bunkerBody)
                                    .foregroundStyle(Color.bunkerTextPrimary)
                                
                                Spacer()
                            }
                            .padding(Spacing.sm)
                            .background(Color.bunkerSurfaceCard)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .padding(Spacing.lg)
                    .background(Color.bunkerSurfaceCard)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
            .padding(Spacing.md)
        }
    }
    
    private func statItem(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(Color.bunkerPrimary)
            Text(value)
                .font(.bunkerHeading1)
                .foregroundStyle(Color.bunkerTextPrimary)
            Text(title)
                .font(.bunkerCaption)
                .foregroundStyle(Color.bunkerTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func loadStats() async {
        isLoading = true
        defer { isLoading = false }
        
        await DecisionService.shared.loadDecisions()
        let decisions = DecisionService.shared.decisions
        
        var topCriteria: [String: Int] = [:]
        var totalCriteriaCount = 0
        var totalOptionsCount = 0
        var completed = 0
        
        for decision in decisions {
            totalCriteriaCount += decision.criteria.count
            totalOptionsCount += decision.options.count
            if !decision.criteria.isEmpty && !decision.options.isEmpty {
                completed += 1
            }
            
            for criteria in decision.criteria {
                topCriteria[criteria.name, default: 0] += 1
            }
        }
        
        let sortedCriteria = topCriteria.sorted { $0.value > $1.value }
        
        stats = DecisionStats(
            totalDecisions: decisions.count,
            completedDecisions: completed,
            pendingDecisions: decisions.count - completed,
            averageCriteriaPerDecision: decisions.isEmpty ? 0 : Double(totalCriteriaCount) / Double(decisions.count),
            averageOptionsPerDecision: decisions.isEmpty ? 0 : Double(totalOptionsCount) / Double(decisions.count),
            topCriteria: Array(sortedCriteria.prefix(5).map { $0.key }),
            mostActiveGroup: nil
        )
    }
}

#Preview {
    NavigationStack {
        DecisionStatsView()
    }
    .preferredColorScheme(.dark)
}
