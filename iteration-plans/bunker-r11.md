# Bunker R11 — AI Decision Advisor

## Goal
Strengthen the on-device AI capabilities to serve as a genuine decision advisor, not just a calculator.

## Features

### Enhanced AI Analysis
- **Decision Complexity Score** — Rate decisions by criteria count, outcome count, and weight variance
- **Criteria Health Check** — Flag criteria with very low or very high importance weights (possible blind spots)
- **Outcome Gap Analysis** — Identify when outcomes are too similar (low differentiation) to be useful
- **Risk Flags** — Highlight if the highest-weighted criteria all favor a single outcome

### AI Insight Templates
- Template-based natural language insights using `NLModel` for tone/sentiment
- Insight categories: Overview, Risk, Recommendation, Next Steps
- "Bunker Analysis" label clearly marks AI-generated content

### Decision Scoring Improvements
- Normalize scores per criteria (compare within-criteria across outcomes)
- Show relative ranking of each outcome per criteria (1st, 2nd, 3rd...)
- Weighted confidence: combine score confidence with criteria coverage

## Technical

- Use `NaturalLanguage` framework for sentiment analysis of decision descriptions
- Refine `AIAnalysisService` to return structured `AIInsight` objects
- Store `lastAnalyzedAt` timestamp on Decision model

## Success Criteria
- AI provides actionable insight for every decision with ≥2 criteria and ≥2 outcomes
- No generic or empty insight states
