# Bunker R12 — Team Decisions

## Goal
Enable multi-user decision workflows with shared decision spaces, voting, and team analytics.

## Features

### Shared Decision Spaces
- Create shareable decision spaces with a 6-character share code
- SharePermission levels: View, Comment, Edit
- Invite via code (no account required for view/comment)
- Track view count and comment count per shared decision

### Team Comments
- Add comments to shared decisions (name + text)
- Comment thread per decision (flat, not nested)
- Flag comments as "pro" or "con" to weight them

### Team Dashboard
- View all shared decisions in a Team tab
- Team activity feed (recent comments, decisions)
- Simple voting: upvote/downvote outcomes per team member

### Data Model Additions
```
SharedDecision {
  id, decisionId, shareCode, permission, views, createdAt, expiresAt
}
Comment {
  id, sharedDecisionId, authorName, text, stance, createdAt
}
TeamVote {
  id, sharedDecisionId, outcomeId, voterId, vote
}
```

## Technical
- Store shared decisions locally with JSON export
- Share codes generated via `UUID` shortened to 6 chars
- No backend in R12 — sharing via export/import or local network via `Network.framework`

## Success Criteria
- A decision can be exported with a share code and imported by another user
- Comments and votes persist locally
