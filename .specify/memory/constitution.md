<!-- Sync Impact Report
Version change: [undefined] → 1.0.0
Modified principles: None (initial adoption)
Added sections: All sections created from template
Removed sections: None
Templates requiring updates: 
  ✅ .specify/templates/plan-template.md (pending review)
  ✅ .specify/templates/spec-template.md (pending review)
  ✅ .specify/templates/tasks-template.md (pending review)
  ✅ .specify/templates/commands/*.md (pending review)
Follow-up TODOs: 
  - RATIFICATION_DATE marked as TODO (needs confirmation)
-->

# Monica iOS Client Constitution

## Project Vision

A lightweight, privacy-first iOS client for Monica CRM that allows users 
to browse, search, and view their personal relationship data and assets 
on the go, following iOS native conventions and patterns.

## Core Principles

### 1. Privacy & Security First
- User data stays private; no analytics on sensitive content
- All communication with Monica API over HTTPS
- Support both cloud (monicahq.com) and self-hosted instances
- Store minimal data locally; respect user privacy settings
- Never share data with third parties

### 2. Read-Only Simplicity (MVP Phase)
- MVP is read-only to reduce complexity and security surface
- Design architecture to be extensible for write operations in v2+
- Keep feature scope focused; say no to scope creep
- Defer offline-first, real-time sync, and macOS to v2+

### 3. Native iOS Experience
- Use SwiftUI and modern iOS conventions (List, NavigationStack, etc.)
- Leverage iOS share sheet and file handling for v2+ (not MVP)
- Respect system-level settings (dark mode, accessibility, dynamic type)
- Follow Apple's Human Interface Guidelines
- Support iOS 15+ (or define minimum version explicitly)

### 4. Clean Architecture
- MVVM or similar pattern for testability
- Separate API layer, data layer, and UI concerns
- Use Dependency Injection for testability
- Avoid massive view controllers or spaghetti logic

### 5. API-First Design
- Design around Monica's public API; no web scraping
- Handle API errors gracefully with user-friendly messages
- Cache appropriately; respect API rate limits
- Document API assumptions and version requirements

### 6. Performance & Responsiveness
- List views load quickly (lazy loading, pagination where needed)
- Search is instant or clearly shows loading state
- No janky animations or UI jank
- Profile app startup time; optimize critical paths

### 7. Testing Standards
- Unit tests for ViewModels and API logic (minimum 70% coverage for core logic)
- Integration tests for API layer
- No tests required for pure SwiftUI views (low ROI)
- Manual testing on device before each release

### 8. Code Quality
- Follow Swift style guide (clear naming, no abbreviations)
- No force unwraps (!) except in controlled contexts
- Prefer struct/enum over class for value types
- Use Result types for error handling, not exceptions

### 9. Documentation
- README: setup, API token, building locally
- Inline comments for non-obvious logic only
- Architecture diagram in docs/
- Changelog for each release

### 10. Decision-Making
- Decisions prioritize user experience over engineer preference
- When in doubt, choose simplicity over flexibility
- Use GitHub Issues for design discussions (not Slack)
- Require code review for all PRs before merge

## Success Metrics (MVP)

- App launches in < 2 seconds on average device
- Search returns results in < 500ms
- Zero crashes in testing (target 100% stability)
- Successfully displays contacts from real Monica instances
- Supports authentication (API token)

## Governance

- This constitution supersedes all other practices and conventions
- Amendments require documentation, approval from project lead, and migration plan for affected code
- All pull requests must verify compliance with core principles
- Technical debt that violates principles must be explicitly justified and tracked for resolution
- Use `.specify/` directory for project-specific runtime development guidance

**Version**: 1.0.0 | **Ratified**: TODO(RATIFICATION_DATE) | **Last Amended**: 2025-10-26