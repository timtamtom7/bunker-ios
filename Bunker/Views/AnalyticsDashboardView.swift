import SwiftUI
import Charts

struct AnalyticsDashboardView: View {
    @State private var decisions: [Decision] = []
    @State private var isLoading = true

    var body: some View {
        ZStack {
            Color.bunkerBackground.ignoresSafeArea()

            if isLoading {
                ProgressView()
                    .tint(Color.bunkerPrimary)
            } else {
                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        summaryCards
                        decisionsOverTimeChart
                        stakeDistributionChart
                        criteriaFrequencyChart
                        topCriteriaSection
                    }
                    .padding(Spacing.md)
                }
            }
        }
        .navigationTitle("Analytics")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadData()
        }
    }

    // MARK: - Summary Cards

    private var summaryCards: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.md) {
            summaryCard(
                title: "Total Decisions",
                value: "\(decisions.count)",
                icon: "rectangle.stack.fill",
                color: Color.bunkerPrimary
            )
            summaryCard(
                title: "This Month",
                value: "\(decisionsThisMonth)",
                icon: "calendar",
                color: Color.bunkerAccent
            )
            summaryCard(
                title: "Avg Criteria",
                value: String(format: "%.1f", averageCriteria),
                icon: "slider.horizontal.3",
                color: Color.bunkerSuccess
            )
            summaryCard(
                title: "High Stake",
                value: "\(highStakeCount)",
                icon: "exclamationmark.triangle.fill",
                color: Color.orange
            )
        }
    }

    private func summaryCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
                Spacer()
            }

            Text(value)
                .font(.bunkerDisplay)
                .foregroundStyle(Color.bunkerTextPrimary)

            Text(title)
                .font(.bunkerCaption)
                .foregroundStyle(Color.bunkerTextSecondary)
        }
        .padding(Spacing.md)
        .background(Color.bunkerSurfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Decisions Over Time

    private var decisionsOverTimeChart: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Decisions Over Time")
                .font(.bunkerHeading3)
                .foregroundStyle(Color.bunkerTextPrimary)

            if #available(iOS 26.0, *) {
                Chart {
                    ForEach(decisionsByMonth, id: \.month) { item in
                        BarMark(
                            x: .value("Month", item.month),
                            y: .value("Count", item.count)
                        )
                        .foregroundStyle(Color.bunkerPrimary.gradient)
                        .cornerRadius(4)
                    }
                }
                .frame(height: 180)
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisValueLabel()
                            .foregroundStyle(Color.bunkerTextSecondary)
                    }
                }
                .chartYAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisGridLine()
                            .foregroundStyle(Color.bunkerDivider)
                        AxisValueLabel()
                            .foregroundStyle(Color.bunkerTextSecondary)
                    }
                }
            } else {
                // Fallback for older iOS
                Text("Chart available on iOS 26+")
                    .font(.bunkerCaption)
                    .foregroundStyle(Color.bunkerTextTertiary)
                    .frame(height: 180)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(Spacing.md)
        .background(Color.bunkerSurfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Stake Distribution

    private var stakeDistributionChart: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Decision Stakes")
                .font(.bunkerHeading3)
                .foregroundStyle(Color.bunkerTextPrimary)

            HStack(spacing: Spacing.lg) {
                ForEach(StakeLevel.allCases, id: \.self) { level in
                    let count = decisions.filter { $0.stake == level }.count
                    let percent = decisions.isEmpty ? 0 : Double(count) / Double(decisions.count)

                    VStack(spacing: 4) {
                        ZStack {
                            Circle()
                                .stroke(Color.bunkerDivider, lineWidth: 6)
                                .frame(width: 56, height: 56)

                            Circle()
                                .trim(from: 0, to: percent)
                                .stroke(stakeColor(level), style: StrokeStyle(lineWidth: 6, lineCap: .round))
                                .frame(width: 56, height: 56)
                                .rotationEffect(.degrees(-90))

                            Text("\(Int(percent * 100))%")
                                .font(.bunkerCaption)
                                .foregroundStyle(Color.bunkerTextPrimary)
                        }

                        Text(level.rawValue)
                            .font(.bunkerCaption)
                            .foregroundStyle(Color.bunkerTextSecondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.bunkerSurfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func stakeColor(_ level: StakeLevel) -> Color {
        switch level {
        case .low: return Color.bunkerSuccess
        case .medium: return Color.bunkerPrimary
        case .high: return Color.orange
        case .critical: return Color.bunkerError
        }
    }

    // MARK: - Criteria Frequency

    private var criteriaFrequencyChart: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Top Criteria")
                .font(.bunkerHeading3)
                .foregroundStyle(Color.bunkerTextPrimary)

            ForEach(topCriteria.prefix(5), id: \.name) { item in
                HStack {
                    Text(item.name)
                        .font(.bunkerBody)
                        .foregroundStyle(Color.bunkerTextPrimary)

                    Spacer()

                    GeometryReader { geometry in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.bunkerPrimary.opacity(0.3))
                            .frame(width: geometry.size.width * item.percent, height: 8)
                    }
                    .frame(width: 100, height: 8)

                    Text("\(item.count)")
                        .font(.bunkerCaption)
                        .foregroundStyle(Color.bunkerTextSecondary)
                        .frame(width: 30, alignment: .trailing)
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.bunkerSurfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var topCriteriaSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Recent Decisions")
                .font(.bunkerHeading3)
                .foregroundStyle(Color.bunkerTextPrimary)

            ForEach(decisions.prefix(5)) { decision in
                HStack {
                    Circle()
                        .fill(Color.bunkerPrimary)
                        .frame(width: 8, height: 8)

                    Text(decision.title)
                        .font(.bunkerBody)
                        .foregroundStyle(Color.bunkerTextPrimary)
                        .lineLimit(1)

                    Spacer()

                    Text(decision.stake.rawValue)
                        .font(.bunkerCaption)
                        .foregroundStyle(stakeColor(decision.stake))
                }
                .padding(Spacing.sm)
                .background(Color.bunkerSurface)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(Spacing.md)
        .background(Color.bunkerSurfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Computed Stats

    private var decisionsThisMonth: Int {
        let month = Calendar.current.component(.month, from: Date())
        let year = Calendar.current.component(.year, from: Date())
        return decisions.filter {
            let dMonth = Calendar.current.component(.month, from: $0.createdAt)
            let dYear = Calendar.current.component(.year, from: $0.createdAt)
            return dMonth == month && dYear == year
        }.count
    }

    private var averageCriteria: Double {
        guard !decisions.isEmpty else { return 0 }
        let total = decisions.reduce(0) { $0 + $1.criteria.count }
        return Double(total) / Double(decisions.count)
    }

    private var highStakeCount: Int {
        decisions.filter { $0.stake == .high || $0.stake == .critical }.count
    }

    private var decisionsByMonth: [(month: String, count: Int)] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"

        var byMonth: [String: Int] = [:]
        for decision in decisions {
            let month = formatter.string(from: decision.createdAt)
            byMonth[month, default: 0] += 1
        }

        return byMonth.map { ($0.key, $0.value) }.sorted { $0.month < $1.month }
    }

    private var topCriteria: [(name: String, count: Int, percent: Double)] {
        var criteriaCount: [String: Int] = [:]
        for decision in decisions {
            for criteria in decision.criteria {
                criteriaCount[criteria.name, default: 0] += 1
            }
        }

        let maxCount = criteriaCount.values.max() ?? 1
        return criteriaCount
            .map { (name: $0.key, count: $0.value, percent: Double($0.value) / Double(maxCount)) }
            .sorted { $0.count > $1.count }
    }

    // MARK: - Data Loading

    private func loadData() async {
        isLoading = true
        defer { isLoading = false }

        await DecisionService.shared.loadDecisions()
        decisions = DecisionService.shared.decisions
    }
}

#Preview {
    NavigationStack {
        AnalyticsDashboardView()
    }
    .preferredColorScheme(.dark)
}
