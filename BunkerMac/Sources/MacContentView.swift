import SwiftUI

// MARK: - Design Tokens
enum BunkerColors {
    static let background = Color(hex: "1E2530")
    static let surface = Color(hex: "283040")
    static let surfaceSecondary = Color(hex: "2F3B4A")
    static let primary = Color(hex: "4A90D9")
    static let accent = Color(hex: "38B2AC")
    static let textPrimary = Color(hex: "F0F4F8")
    static let textSecondary = Color(hex: "A0AEC0")
    static let textTertiary = Color(hex: "718096")
    static let error = Color(hex: "FC8181")
    static let success = Color(hex: "68D391")
    static let warning = Color(hex: "F6AD55")
    static let divider = Color(hex: "3D4A5C")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

struct MacContentView: View {
    @State private var decisions: [Decision] = []
    @State private var selectedDecision: Decision?
    @State private var showNewDecision = false
    @State private var showSettings = false
    @State private var isLoading = false
    @State private var searchText = ""

    private let service = DecisionService.shared

    var filteredDecisions: [Decision] {
        if searchText.isEmpty {
            return decisions
        }
        return decisions.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationSplitView {
            sidebarContent
        } detail: {
            detailContent
        }
        .background(BunkerColors.background)
        .task {
            await loadDecisions()
        }
        .onReceive(NotificationCenter.default.publisher(for: .newDecision)) { _ in
            showNewDecision = true
        }
        .sheet(isPresented: $showNewDecision) {
            MacNewDecisionView(decisions: $decisions, selectedDecision: $selectedDecision)
        }
        .sheet(isPresented: $showSettings) {
            MacSettingsView(decisions: $decisions)
        }
    }

    // MARK: - Sidebar
    private var sidebarContent: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Bunker")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(BunkerColors.textPrimary)
                    Text("\(decisions.count) decision\(decisions.count == 1 ? "" : "s")")
                        .font(.system(size: 12))
                        .foregroundColor(BunkerColors.textTertiary)
                }
                Spacer()
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape")
                        .foregroundColor(BunkerColors.textSecondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Settings")
                .accessibilityHint("Opens app settings")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(BunkerColors.surface)

            // Search
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(BunkerColors.textTertiary)
                    .font(.system(size: 13))
                TextField("Search decisions...", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13))
                    .foregroundColor(BunkerColors.textPrimary)
                    .accessibilityLabel("Search decisions")
                    .accessibilityHint("Filter the decision list by title or description")
            }
            .padding(8)
            .background(BunkerColors.surfaceSecondary)
            .cornerRadius(8)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            Divider()
                .background(BunkerColors.divider)

            // Decision List
            if filteredDecisions.isEmpty {
                Spacer()
                VStack(spacing: 8) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 32))
                        .foregroundColor(BunkerColors.textTertiary)
                    Text(searchText.isEmpty ? "No decisions yet" : "No results")
                        .font(.system(size: 14))
                        .foregroundColor(BunkerColors.textSecondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 4) {
                        ForEach(filteredDecisions) { decision in
                            MacDecisionRow(
                                decision: decision,
                                isSelected: selectedDecision?.id == decision.id
                            )
                            .onTapGesture {
                                selectedDecision = decision
                            }
                            .contextMenu {
                                Button("Delete") {
                                    Task { await deleteDecision(decision) }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                }
            }

            Divider()
                .background(BunkerColors.divider)

            // New Decision Button
            Button {
                showNewDecision = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(BunkerColors.accent)
                    Text("New Decision")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(BunkerColors.textPrimary)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(BunkerColors.surfaceSecondary)
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
            .padding(12)
            .accessibilityLabel("New Decision")
            .accessibilityHint("Creates a new decision")
        }
        .frame(minWidth: 260, idealWidth: 280, maxWidth: 320)
        .background(BunkerColors.surface)
    }

    // MARK: - Detail
    @ViewBuilder
    private var detailContent: some View {
        if let decision = selectedDecision {
            MacDecisionEditorView(decisionId: decision.id, allDecisions: $decisions)
        } else {
            VStack(spacing: 16) {
                Image(systemName: "commandcenter")
                    .font(.system(size: 56))
                    .foregroundColor(BunkerColors.textTertiary)
                Text("Select a decision")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(BunkerColors.textSecondary)
                Text("Or create a new one from the sidebar")
                    .font(.system(size: 13))
                    .foregroundColor(BunkerColors.textTertiary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(BunkerColors.background)
        }
    }

    private func loadDecisions() async {
        isLoading = true
        await service.loadDecisions()
        decisions = service.decisions
        isLoading = false
    }

    private func deleteDecision(_ decision: Decision) async {
        await service.deleteDecision(decision)
        decisions = service.decisions
        if selectedDecision?.id == decision.id {
            selectedDecision = nil
        }
    }
}

// MARK: - Decision Row
struct MacDecisionRow: View {
    let decision: Decision
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 10) {
            // Status indicator
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 2) {
                Text(decision.title.isEmpty ? "Untitled Decision" : decision.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(BunkerColors.textPrimary)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Text(decision.statusText)
                        .font(.system(size: 11))
                        .foregroundColor(BunkerColors.textTertiary)

                    Text("•")
                        .foregroundColor(BunkerColors.textTertiary)

                    Text("\(decision.criteria.count) criteria")
                        .font(.system(size: 11))
                        .foregroundColor(BunkerColors.textTertiary)

                    Text("•")
                        .foregroundColor(BunkerColors.textTertiary)

                    Text("\(decision.options.count) options")
                        .font(.system(size: 11))
                        .foregroundColor(BunkerColors.textTertiary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 11))
                .foregroundColor(BunkerColors.textTertiary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isSelected ? BunkerColors.primary.opacity(0.2) : Color.clear)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? BunkerColors.primary.opacity(0.5) : Color.clear, lineWidth: 1)
        )
    }

    private var statusColor: Color {
        switch decision.statusText {
        case "Succeeded": return BunkerColors.success
        case "Failed": return BunkerColors.error
        case "Ready": return BunkerColors.accent
        case "Scoring": return BunkerColors.warning
        case "Resolved": return BunkerColors.primary
        default: return BunkerColors.textTertiary
        }
    }
}
