import SwiftUI

struct DecisionListView: View {
    @State private var viewModel = DecisionListViewModel()
    @State private var searchText = ""

    var filteredDecisions: [Decision] {
        if searchText.isEmpty {
            return viewModel.decisions
        }
        return viewModel.decisions.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bunkerBackground
                    .ignoresSafeArea()

                if viewModel.isLoading && viewModel.decisions.isEmpty {
                    ProgressView()
                        .tint(Color.bunkerPrimary)
                } else if filteredDecisions.isEmpty {
                    emptyState
                } else {
                    decisionList
                }

                // FAB
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            viewModel.showNewDecision = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundStyle(Color.bunkerBackground)
                                .frame(width: 56, height: 56)
                                .background(Color.bunkerPrimary)
                                .clipShape(Circle())
                                .shadow(color: .bunkerPrimary.opacity(0.4), radius: 8, x: 0, y: 4)
                        }
                        .padding(.trailing, Spacing.lg)
                        .padding(.bottom, Spacing.lg)
                    }
                }
            }
            .navigationTitle("Bunker")
            .searchable(text: $searchText, prompt: "Search decisions")
            .refreshable {
                await viewModel.refresh()
            }
            .sheet(isPresented: $viewModel.showNewDecision) {
                NewDecisionView { newDecision in
                    Task {
                        await DecisionService.shared.saveDecision(newDecision)
                        await viewModel.load()
                    }
                }
            }
            .task {
                await viewModel.load()
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "rectangle.stack.badge.plus")
                .font(.system(size: 56))
                .foregroundStyle(Color.bunkerTextTertiary)

            Text("No decisions yet")
                .font(.bunkerHeading2)
                .foregroundStyle(Color.bunkerTextPrimary)

            Text("Every choice starts here.\nMake your first decision.")
                .font(.bunkerBody)
                .foregroundStyle(Color.bunkerTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(Spacing.xl)
    }

    private var decisionList: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.sm) {
                ForEach(filteredDecisions) { decision in
                    NavigationLink(destination: DecisionDetailView(decision: decision)) {
                        DecisionCard(decision: decision)
                    }
                    .buttonStyle(.plain)
                }
                .onDelete { indexSet in
                    Task {
                        await viewModel.delete(at: indexSet)
                    }
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.sm)
        }
    }
}

struct DecisionCard: View {
    let decision: Decision

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack {
                Text(decision.title)
                    .font(.bunkerHeading3)
                    .foregroundStyle(Color.bunkerTextPrimary)
                    .lineLimit(1)

                Spacer()

                statusPill
            }

            if !decision.description.isEmpty {
                Text(decision.description)
                    .font(.bunkerCaption)
                    .foregroundStyle(Color.bunkerTextSecondary)
                    .lineLimit(2)
            }

            HStack(spacing: Spacing.md) {
                Label("\(decision.criteria.count)", systemImage: "slider.horizontal.3")
                    .font(.bunkerLabel)
                    .foregroundStyle(Color.bunkerTextTertiary)

                Label("\(decision.options.count)", systemImage: "square.stack.3d.up")
                    .font(.bunkerLabel)
                    .foregroundStyle(Color.bunkerTextTertiary)

                Spacer()

                Text(decision.updatedAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.bunkerCaption)
                    .foregroundStyle(Color.bunkerTextTertiary)
            }
        }
        .padding(Spacing.md)
        .background(Color.bunkerSurfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.bunkerDivider, lineWidth: 1)
        )
    }

    private var statusPill: some View {
        Group {
            if decision.allCriteriaScored {
                Text("Ready")
                    .font(.bunkerLabel)
                    .foregroundStyle(Color.bunkerBackground)
                    .padding(.horizontal, Spacing.xs)
                    .padding(.vertical, Spacing.xxs)
                    .background(Color.bunkerSuccess)
                    .clipShape(Capsule())
            } else if decision.isComplete {
                Text("Scoring")
                    .font(.bunkerLabel)
                    .foregroundStyle(Color.bunkerTextPrimary)
                    .padding(.horizontal, Spacing.xs)
                    .padding(.vertical, Spacing.xxs)
                    .background(Color.bunkerWarning.opacity(0.2))
                    .clipShape(Capsule())
            } else {
                Text("Draft")
                    .font(.bunkerLabel)
                    .foregroundStyle(Color.bunkerTextTertiary)
                    .padding(.horizontal, Spacing.xs)
                    .padding(.vertical, Spacing.xxs)
                    .background(Color.bunkerSecondary)
                    .clipShape(Capsule())
            }
        }
    }
}

#Preview {
    DecisionListView()
        .preferredColorScheme(.dark)
}
