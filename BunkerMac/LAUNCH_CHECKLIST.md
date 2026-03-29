# BunkerMac — Launch Checklist

## Pre-Submission (R13 Complete)

### App Store Listing ✅
- [x] Tagline: "Every big decision, clearly."
- [x] Description written
- [x] Keywords researched
- [x] Screenshots specified (5 dark-mode screenshots needed)
- [x] Category selected

### Dark Mode Audit ✅
- [x] All colors use `BunkerColors` theme tokens
- [x] Background: `#1E2530` (BunkerColors.background)
- [x] Surface: `#283040` (BunkerColors.surface)
- [x] Surface Secondary: `#2F3B4A` (BunkerColors.surfaceSecondary)
- [x] Primary: `#4A90D9` (BunkerColors.primary)
- [x] Accent: `#38B2AC` (BunkerColors.accent)
- [x] All divider lines use `BunkerColors.divider`
- [x] Fixed: `Color.orange` → `BunkerColors.warning` in MacDecisionEditorView (stakeColor for .high)
- [x] Fixed: `Color.orange` → `BunkerColors.warning` in MacOutcomeSimulatorView (elevated risk badge)

### Accessibility Audit ✅
- [x] All interactive elements have `.accessibilityLabel`
- [x] All buttons have `.accessibilityHint` where helpful
- [x] Keyboard shortcuts documented (see below)
- [x] Fixed: MacCriteriaRow expand/collapse button (accessibilityLabel added)
- [x] Fixed: MacOptionRow expand/collapse button (accessibilityLabel added)
- [x] Fixed: MacDecisionEditorView save button (accessibilityLabel added)
- [x] Fixed: MacDecisionEditorView settings button (accessibilityLabel added)
- [x] Fixed: MacDecisionRow delete via context menu (accessibilityLabel on "Delete" button)
- [x] Fixed: MacNewDecisionView cancel/create buttons (accessibilityLabels added)

### Keyboard Shortcuts
| Shortcut | Action |
|----------|--------|
| `⌘N` | New Decision |
| `⌘S` | Save Decision (via standard save) |
| `⌘,` | Open Settings |
| `⌘W` | Close Window |
| `⌘Q` | Quit BunkerMac |
| `⌘F` | Search decisions |

---

## Build & Code Signing

### Local Build ✅
- [x] `xcodegen generate` succeeds
- [x] `xcodebuild -scheme BunkerMac -configuration Release` succeeds
- [x] No errors or warnings in release build

### App Store Connect Setup
- [ ] Create App Store Connect account (if not already done)
- [ ] Create new app entry for BunkerMac
- [ ] Bundle ID: `com.bunker.macos`
- [ ] SKU: `BUNKERMAC001`
- [ ] Upload build via Xcode Organizer (or Transporter)

### Required Before Upload
- [ ] Privacy Policy URL (required for App Store)
- [ ] Support URL
- [ ] App Store screenshots (5× macOS screenshots in dark mode)
- [ ] App icon (1024×1024 App Store icon)
- [ ] Review trademark/legal (Bunker name — ensure clearance)

---

## App Store Review

### Meta & Assets
- [ ] App name: BunkerMac
- [ ] Subtitle: AI-Powered Decision Command Center
- [ ] Description (see APPSTORE.md)
- [ ] Keywords
- [ ] Category: Productivity
- [ ] Pricing: $4.99 (or Free with IAP — TBD)
- [ ] 5 Screenshots (dark mode, 16:10 aspect ratio)
- [ ] App Icon (all required sizes)
- [ ] Preview video (optional but recommended)

### Legal
- [ ] Privacy Policy URL hosted
- [ ] Terms of Service (if applicable)
- [ ] Export Compliance (if any networking/crypto — likely No)

### Review Notes
- "BunkerMac uses local storage only for decision data"
- "No personal data is collected or transmitted"
- "Built with SwiftUI for macOS 15+"

---

## Post-Launch

- [ ] Monitor App Store Connect for review status
- [ ] Respond to any Apple review feedback
- [ ] Announce launch (if applicable)
- [ ] Set up TestFlight for beta (optional)
- [ ] Create home page / landing page (optional)

---

## Version History

| Version | Date | Notes |
|---------|------|-------|
| 1.0.0 R13 | 2026-03-29 | App Store listing, accessibility audit, dark aesthetic audit, launch checklist |
| 1.0.0 R12 | Prior | Decision Rooms, Advisor Sharing, AI Analysis, Outcome Simulator |
| 0.9 | Prior | Menu bar, core decision editor, criteria & options scoring |
