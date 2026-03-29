# Bunker R13 — Polish & Launch

## Goal
Ship a polished, launch-ready macOS app with App Store assets and marketing.

## Features

### Polish
- **Animations** — Refine card transitions, sheet presentations, and score slider feedback
- **Keyboard shortcuts** — ⌘N new decision, ⌘⌫ delete, ⌘S save/simulate
- **Focus mode** — Hide sidebar, expand detail view (⌘⇧F)
- **Undo/Redo** — Support for decision edits via `UndoManager`
- **macOS menu bar** — File, Edit, Decision, Window, Help menus
- **Dark/Light mode** — Proper `ColorScheme` adaptation (dark is primary)

### Launch Assets
- **App Icon** — Bunker icon (shield/command center motif) at all required sizes
- **App Store screenshots** — 5 screenshots showing key workflows
- **Marketing copy** — "Where decisions go to get serious" tagline
- **Privacy policy** — On-device only, no data collection

### Entitlements
- App Sandbox enabled for Mac App Store
- Hardened Runtime enabled

### Build Configuration
- Release build with `CODE_SIGN_IDENTITY` set properly
- TestFlight provisioning for beta testing

## Success Criteria
- `xcodebuild -scheme BunkerMac -configuration Release build` succeeds
- App launches and core workflows function on a clean macOS install
- App Store Connect submission ready
