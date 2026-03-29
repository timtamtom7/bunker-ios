import SwiftUI
import AppKit

// MARK: - Menu Bar Extra
struct BunkerMenuBar: View {
    @State private var decisions: [Decision] = []
    @State private var showNewDecision = false
    @State private var showMainWindow = false

    private let service = DecisionService.shared

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "commandcenter.fill")
                    .font(.system(size: 14))
                    .foregroundColor(BunkerColors.accent)
                Text("Bunker")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(BunkerColors.textPrimary)
                Spacer()
                Button {
                    NSApp.terminate(nil)
                } label: {
                    Image(systemName: "xmark.circle")
                        .font(.system(size: 12))
                        .foregroundColor(BunkerColors.textTertiary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(BunkerColors.surface)

            Divider()
                .background(BunkerColors.divider)

            // Quick Actions
            VStack(spacing: 2) {
                Button {
                    showNewDecision = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(BunkerColors.accent)
                        Text("New Decision")
                            .font(.system(size: 13))
                            .foregroundColor(BunkerColors.textPrimary)
                        Spacer()
                        Text("⌘N")
                            .font(.system(size: 11))
                            .foregroundColor(BunkerColors.textTertiary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.plain)

                Button {
                    showMainWindow = true
                } label: {
                    HStack {
                        Image(systemName: "macwindow")
                            .foregroundColor(BunkerColors.primary)
                        Text("Open Bunker")
                            .font(.system(size: 13))
                            .foregroundColor(BunkerColors.textPrimary)
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
            }

            if !decisions.isEmpty {
                Divider()
                    .background(BunkerColors.divider)

                // Recent Decisions
                VStack(alignment: .leading, spacing: 4) {
                    Text("RECENT")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(BunkerColors.textTertiary)
                        .padding(.horizontal, 12)
                        .padding(.top, 8)

                    ForEach(decisions.prefix(5)) { decision in
                        Button {
                            // Open decision
                        } label: {
                            HStack {
                                Circle()
                                    .fill(statusColor(for: decision))
                                    .frame(width: 6, height: 6)
                                Text(decision.title.isEmpty ? "Untitled" : decision.title)
                                    .font(.system(size: 12))
                                    .foregroundColor(BunkerColors.textSecondary)
                                    .lineLimit(1)
                                Spacer()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            Divider()
                .background(BunkerColors.divider)

            // Quit
            Button {
                NSApp.terminate(nil)
            } label: {
                HStack {
                    Image(systemName: "power")
                        .foregroundColor(BunkerColors.error.opacity(0.7))
                    Text("Quit Bunker")
                        .font(.system(size: 13))
                        .foregroundColor(BunkerColors.textSecondary)
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
        }
        .frame(width: 260)
        .background(BunkerColors.background)
        .task {
            await loadDecisions()
        }
        .sheet(isPresented: $showNewDecision) {
            MacNewDecisionView(decisions: $decisions, selectedDecision: .constant(nil))
        }
    }

    private func loadDecisions() async {
        await service.loadDecisions()
        decisions = service.decisions
    }

    private func statusColor(for decision: Decision) -> Color {
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

// MARK: - Menu Bar Controller
@MainActor
class BunkerMenuBarController: NSObject {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!

    override init() {
        super.init()
        setupStatusItem()
        setupPopover()
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "commandcenter.fill", accessibilityDescription: "Bunker")
            button.image?.isTemplate = true
            button.action = #selector(togglePopover)
            button.target = self
        }
    }

    private func setupPopover() {
        popover = NSPopover()
        popover.contentSize = NSSize(width: 260, height: 400)
        popover.behavior = .transient
        let hostingController = NSHostingController(rootView: BunkerMenuBar())
        popover.contentViewController = hostingController
    }

    @objc private func togglePopover() {
        if popover.isShown {
            popover.performClose(nil)
        } else {
            if let button = statusItem.button {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }
}

// MARK: - App Delegate for Menu Bar
class BunkerMacAppDelegate: NSObject, NSApplicationDelegate {
    var menuBarController: BunkerMenuBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // For menu bar extra mode, uncomment below:
        // menuBarController = BunkerMenuBarController()
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            // Show window
        }
        return true
    }
}
