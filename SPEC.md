# Bunker — AI-Powered Decision Workspace

## 1. Concept & Vision

Bunker is where decisions go to get serious. Not a list app, not a notes app — a structured thinking environment for when stakes are high and clarity is hard to find. It feels like having a sharp, calm analyst in your corner: you lay out the decision, weight what matters, simulate what might happen, and walk away with genuine confidence. The vibe is focused and serious without being cold — like a well-designed command center for your own judgment.

## 2. Design Language

### Aesthetic Direction
**Command center clarity.** Dark, focused, tool-like. Think Bloomberg Terminal meets a premium notes app — information-dense but never cluttered. Every element earns its place. Glass/liquid surfaces for modals and cards, flat surfaces for content areas.

### Color Palette
| Role | Color | Hex |
|------|-------|-----|
| Primary | Steel Blue | #4A90D9 |
| Secondary | Slate | #2D3748 |
| Accent | Electric Teal | #38B2AC |
| Background | Deep Slate | #1E2530 |
| Surface | Elevated Slate | #283040 |
| Surface Secondary | Card | #2F3B4A |
| Text Primary | Off-White | #F0F4F8 |
| Text Secondary | Muted Steel | #A0AEC0 |
| Text Tertiary | Dim | #718096 |
| Error | Coral Red | #FC8181 |
| Success | Mint | #68D391 |
| Warning | Amber | #F6AD55 |
| Divider | Border | #3D4A5C |

### Typography
| Role | Font | Weight | Size |
|------|------|--------|------|
| Display | SF Pro Display | Bold | 34pt |
| Heading 1 | SF Pro Display | Semibold | 28pt |
| Heading 2 | SF Pro Display | Medium | 22pt |
| Heading 3 | SF Pro Text | Semibold | 18pt |
| Body | SF Pro Text | Regular | 17pt |
| Body Small | SF Pro Text | Regular | 15pt |
| Caption | SF Pro Text | Regular | 13pt |
| Label | SF Pro Text | Medium | 12pt |

### Spacing System (8pt Grid)
| Name | Value |
|------|-------|
| xxs | 4pt |
| xs | 8pt |
| sm | 12pt |
| md | 16pt |
| lg | 24pt |
| xl | 32pt |
| xxl | 48pt |

### Motion Philosophy
Motion is purposeful and restrained — communicates state, not decoration.
| Animation | Duration | Curve |
|-----------|----------|-------|
| Screen transition | 350ms | easeInOut |
| Card appear | 250ms | spring(0.75) |
| Button press | 100ms | easeOut |
| Sheet present | 400ms | spring(0.8) |
| Delete/sweep | 250ms | easeIn |
| Value change | 200ms | easeInOut |

## 3. Layout & Structure

### App Structure
```
TabView
├── Decisions (NavigationStack)
│   ├── Decision List
│   └── Decision Detail
│       ├── Criteria Scoring
│       ├── Outcome Simulation
│       └── AI Insights
├── Outcomes (NavigationStack)
│   ├── Outcome History
│   └── Outcome Detail
└── Settings
```

### Screen Breakdown
1. **Decision List** — All decisions as cards, FAB to create new
2. **Decision Detail** — Title, description, criteria list, simulate button
3. **New Decision** — Sheet: title, description, initial criteria
4. **Criteria Scoring** — Inline or sheet: weight + score per criteria
5. **Outcome View** — Simulated outcomes with confidence scores
6. **Settings** — Theme toggle, about

## 4. Features & Interactions

### Core Features (R1)
- **Decision Cards** — Create, view, edit, delete decisions with title + description
- **Criteria Management** — Add criteria with importance weights (1-10) to each decision
- **Criteria Scoring** — Score each option against criteria (1-10 scale)
- **Outcome Simulation** — Weighted scoring algorithm produces ranked outcomes with confidence %
- **AI Insights** — On-device analysis summarizes decision state (natural language, no external API)
- **Local Persistence** — All data stored via SQLite

### Interactions
- **Swipe to delete** on decision cards and criteria
- **Pull to refresh** on lists (re-analyzes)
- **Long press** on criteria to reorder
- **Tap criteria row** to score
- **FAB** (floating action button) for new decision
- **Sheet** for new decision flow, criteria scoring, outcome detail

### Empty States
- **No decisions:** "Every choice starts here. Make your first decision."
- **No criteria:** "Add what matters to this decision."
- **No outcomes yet:** "Score your criteria to simulate outcomes."

### Error States
- Failed save: toast + retry
- Missing required field: inline validation message

## 5. Component Inventory

### DecisionCard
- Surface background with subtle border
- Title (Heading 3), description snippet (Caption, 2 lines max)
- Criteria count badge, status pill
- States: default, pressed (scale 0.98), swiping (delete reveal)

### CriteriaRow
- Label + weight badge
- Score slider or segmented control when editing
- Checkmark when scored
- States: unscored (muted), scored (normal), editing (highlighted)

### OutcomeCard
- Rank number, outcome label, confidence %
- Weighted score bar
- Expandable details
- States: default, expanded

### FloatingActionButton
- Circular, primary color, shadow
- Plus icon, scale animation on tap

### EmptyStateView
- Centered icon (SF Symbol), title, subtitle, optional CTA

### ScoreSlider
- Custom 1-10 track with tick marks
- Thumb shows current value
- Accent color for filled track

## 6. Technical Approach

### Stack
- **SwiftUI** (iOS 26)
- **XcodeGen** for project generation
- **SQLite.swift** for local persistence
- **No external dependencies** beyond SQLite.swift

### Architecture: MVVM + Services
```
Views (SwiftUI)
    ↓ binds to
ViewModels (@Observable)
    ↓ calls
Services (DatabaseService, DecisionService, AIAnalysisService)
    ↓ uses
Models (Decision, Criteria, Outcome)
```

### Models
```swift
struct Decision: Identifiable, Codable
struct Criteria: Identifiable, Codable
struct Outcome: Identifiable, Codable
struct CriteriaScore: Identifiable, Codable
```

### Services
- **DatabaseService** — SQLite.swift wrapper, CRUD operations
- **DecisionService** — Business logic, weighted scoring algorithm
- **AIAnalysisService** — On-device NaturalLanguage analysis for insight generation

### Data
- SQLite database in Application Support directory
- Schema migrations handled via version tracking
- No CloudKit in R1

### AI Insights (On-Device)
- Use `NLModel` for sentiment/tone analysis of decision text
- Generate natural language summaries using template-based composition
- Label clearly as "Bunker Analysis" — no external AI

---

## 7. Build Targets

- **Bunker** — iOS 26.0, iPhone + iPad
- No watchOS in R1
- No Widgets in R1

## R7 — Advanced Features, Polish & Organization

### Decision Templates
- DecisionTemplate model: name, description, criteria templates with guidance
- CriteriaTemplate: name, importance (weight), guidance hint for scoring
- 4 default templates: Career Move, Major Purchase, Relocation, Partnership
- TemplatesView: browse, create, manage templates
- CreateTemplateSheet: create custom templates with criteria
- TemplateDetailSheet: view template details
- Templates accessible from Settings

### Decision Groups
- DecisionGroup model: name, icon, color, decision IDs
- 10 predefined icons: folder, briefcase, house, dollarsign.circle, heart, book, airplane, graduationcap, house.circle, cart
- GroupsView: manage decision groups
- CreateGroupSheet: create groups with icon and color picker
- GroupDetailSheet: view group and its decisions
- Groups accessible from Settings

### Decision Statistics
- DecisionStats model: total, completed, pending decisions; avg criteria/options, top criteria
- DecisionStatsView: visual dashboard with completion rate, averages, top criteria

### R7 Additional Features
- Empty state views for templates and groups
- Settings updated to show R10 round indicator
- Color extension adds Color(hex:) initializer

## R8 — Advanced AI, Integrations

### AI Decision Coach
- AIAnalysisService: enhanced on-device analysis with NLModel for decision tone
- AIDecisionService: structured decision advice based on criteria weights
- AI-generated "what-if" scenario analysis
- Risk assessment based on confidence scores

### Third-Party Integrations
- ExportService: export decisions as JSON/PDF
- ShareDecision via share code (6-char alphanumeric)
- SharePermission levels: view, comment, edit
- SharedDecision model with expiry, views tracking

### Advanced Analytics
- Decision pattern analysis over time
- Criteria effectiveness tracking (which criteria lead to good decisions)
- Outcome confidence correlation analysis

## R9 — Community, Subscriptions

### Subscription Tiers
- Free: 5 decisions, 3 criteria per decision, basic simulation
- Pro ($4.99/mo): unlimited decisions, AI coach, templates, groups, export
- Team ($9.99/mo): Pro + shared decision spaces, team analytics

### Community Features
- Anonymous decision benchmarking (how does your criteria compare)
- "Bunker Pro" achievement badges
- Shared decision feed (opt-in, anonymized)

## R10 — Launch, Marketing, Platform

### App Store
- Full App Store listing with screenshots
- Feature highlights: AI insights, weighted criteria, outcome simulation
- Privacy policy, parental guidance
- Marketing video demonstrating decision workflow

### Marketing
- bunker.app marketing site
- SEO: "decision making app", "AI decision coach", "criteria weighted decisions"
- Blog: decision science, case studies

### Platform
- iPad optimized (already done)
- watchOS companion for decision reminders
- Android app (Flutter)
