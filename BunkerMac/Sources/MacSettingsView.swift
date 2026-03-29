import SwiftUI
import AppKit

struct MacSettingsView: View {
    @Binding var decisions: [Decision]
    @Environment(\.dismiss) private var dismiss

    @State private var showClearConfirmation = false
    @State private var exportMessage = ""
    @State private var showExportSuccess = false

    private let service = DecisionService.shared
    private let exportService = MacExportService.shared

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Settings")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(BunkerColors.textPrimary)
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(BunkerColors.textTertiary)
                }
                .buttonStyle(.plain)
            }
            .padding(20)
            .background(BunkerColors.surface)

            Divider()
                .background(BunkerColors.divider)

            // Settings List
            ScrollView {
                VStack(spacing: 16) {
                    // Data Management
                    sectionHeader("DATA MANAGEMENT")

                    settingsRow(icon: "square.and.arrow.up", title: "Export All Decisions", subtitle: "Save as JSON file") {
                        exportDecisions()
                    }

                    settingsRow(icon: "doc.text", title: "Export All Decisions (PDF)", subtitle: "Save as PDF file") {
                        exportDecisionsPDF()
                    }

                    settingsRow(icon: "trash", title: "Clear All Decisions", subtitle: "Delete all decisions permanently", isDestructive: true) {
                        showClearConfirmation = true
                    }

                    Divider()
                        .background(BunkerColors.divider)

                    // Statistics
                    sectionHeader("STATISTICS")

                    statsCard

                    Divider()
                        .background(BunkerColors.divider)

                    // About
                    sectionHeader("ABOUT")

                    aboutRow(title: "BunkerMac", value: "Version 1.0.0")
                    aboutRow(title: "Build", value: "1")
                    aboutRow(title: "Framework", value: "SwiftUI")
                }
                .padding(20)
            }
            .background(BunkerColors.background)

            // Success message
            if showExportSuccess {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(BunkerColors.success)
                    Text(exportMessage)
                        .font(.system(size: 13))
                        .foregroundColor(BunkerColors.success)
                }
                .padding(12)
                .background(BunkerColors.success.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
            }
        }
        .frame(width: 480, height: 560)
        .background(BunkerColors.background)
        .alert("Clear All Decisions?", isPresented: $showClearConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete All", role: .destructive) {
                Task { await clearAllDecisions() }
            }
        } message: {
            Text("This will permanently delete all \(decisions.count) decisions. This action cannot be undone.")
        }
    }

    // MARK: - Section Header
    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(BunkerColors.primary)
            Spacer()
        }
    }

    // MARK: - Settings Row
    private func settingsRow(icon: String, title: String, subtitle: String, isDestructive: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(isDestructive ? BunkerColors.error : BunkerColors.primary)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(isDestructive ? BunkerColors.error : BunkerColors.textPrimary)
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(BunkerColors.textTertiary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(BunkerColors.textTertiary)
            }
            .padding(12)
            .background(BunkerColors.surfaceSecondary)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Stats Card
    private var statsCard: some View {
        VStack(spacing: 12) {
            HStack {
                statItem(title: "Total", value: "\(decisions.count)", color: BunkerColors.primary)
                statItem(title: "Resolved", value: "\(decisions.filter { $0.isResolved }.count)", color: BunkerColors.success)
                statItem(title: "Pending", value: "\(decisions.filter { !$0.isResolved }.count)", color: BunkerColors.warning)
            }

            HStack {
                statItem(title: "Avg Criteria", value: String(format: "%.1f", avgCriteria), color: BunkerColors.accent)
                statItem(title: "Avg Options", value: String(format: "%.1f", avgOptions), color: BunkerColors.accent)
                statItem(title: "Total Outcomes", value: "\(totalOutcomes)", color: BunkerColors.primary)
            }
        }
        .padding(12)
        .background(BunkerColors.surfaceSecondary)
        .cornerRadius(8)
    }

    private func statItem(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(color)
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(BunkerColors.textTertiary)
        }
        .frame(maxWidth: .infinity)
    }

    private var avgCriteria: Double {
        guard !decisions.isEmpty else { return 0 }
        return Double(decisions.reduce(0) { $0 + $1.criteria.count }) / Double(decisions.count)
    }

    private var avgOptions: Double {
        guard !decisions.isEmpty else { return 0 }
        return Double(decisions.reduce(0) { $0 + $1.options.count }) / Double(decisions.count)
    }

    private var totalOutcomes: Int {
        decisions.reduce(0) { $0 + $1.criteria.count * $1.options.count }
    }

    // MARK: - About Row
    private func aboutRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(BunkerColors.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 13))
                .foregroundColor(BunkerColors.textTertiary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    // MARK: - Actions
    private func exportDecisions() {
        guard let data = exportService.exportToJSON(decisions: decisions) else {
            exportMessage = "Export failed"
            showExportSuccess = true
            return
        }

        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.nameFieldStringValue = "BunkerDecisions.json"
        panel.title = "Export Decisions"

        if panel.runModal() == .OK, let url = panel.url {
            do {
                try data.write(to: url)
                exportMessage = "Exported \(decisions.count) decisions to \(url.lastPathComponent)"
                showExportSuccess = true
            } catch {
                exportMessage = "Export failed: \(error.localizedDescription)"
                showExportSuccess = true
            }
        }
    }

    private func exportDecisionsPDF() {
        guard let firstDecision = decisions.first else {
            exportMessage = "No decisions to export"
            showExportSuccess = true
            return
        }

        guard let data = exportService.exportToPDF(decision: firstDecision, outcomes: []) else {
            exportMessage = "PDF export failed"
            showExportSuccess = true
            return
        }

        let panel = NSSavePanel()
        panel.allowedContentTypes = [.pdf]
        panel.nameFieldStringValue = "BunkerDecision.pdf"
        panel.title = "Export Decision as PDF"

        if panel.runModal() == .OK, let url = panel.url {
            do {
                try data.write(to: url)
                exportMessage = "Exported PDF to \(url.lastPathComponent)"
                showExportSuccess = true
            } catch {
                exportMessage = "PDF export failed: \(error.localizedDescription)"
                showExportSuccess = true
            }
        }
    }

    private func clearAllDecisions() async {
        for decision in decisions {
            await service.deleteDecision(decision)
        }
        decisions = []
        dismiss()
    }
}
