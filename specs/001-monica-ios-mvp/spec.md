# Feature Specification: Monica iOS Client MVP

**Feature Branch**: `001-monica-ios-mvp`  
**Created**: 2025-10-26  
**Status**: Draft  
**Input**: User description: "Monica iOS Client - MVP Specification: Build an iOS app that allows users to view and search their Monica contacts and related information (activities, notes, tasks, gifts) in a read-only format. The app prioritizes simplicity, privacy, and native iOS experience."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Authentication & API Configuration (Priority: P1)

As a Monica user (cloud or self-hosted), I want to configure my API endpoint and authenticate with my API token so that I can access my private contact data from any Monica instance.

**Why this priority**: Authentication is the foundational requirement - without it, no other functionality can work. Users must be able to connect to their Monica instance before accessing any data.

**Independent Test**: Can be fully tested by configuring API endpoint and token, then verifying successful connection to Monica instance. Delivers immediate value by establishing secure access to user's data.

**Acceptance Scenarios**:

1. **Given** app is launched for the first time, **When** user selects "Cloud (monicahq.com)", **Then** endpoint auto-fills to `https://app.monicahq.com/api` and user can enter API token
2. **Given** app is launched for the first time, **When** user selects "Self-Hosted", **Then** user can enter custom endpoint URL and API token
3. **Given** valid endpoint and token are entered, **When** user submits credentials, **Then** app validates token and advances to contact list
4. **Given** invalid token is entered, **When** validation fails, **Then** user sees "This API token is invalid or expired" message
5. **Given** user is authenticated, **When** app is relaunched, **Then** user is automatically logged in using stored credentials
6. **Given** user is logged in, **When** user selects logout from Settings, **Then** all credentials are cleared and user returns to onboarding

---

### User Story 2 - Browse & Paginate Contacts (Priority: P1)

As a Monica user, I want to see a list of all my contacts with pagination so that I can find someone without loading thousands of contacts at once.

**Why this priority**: Core functionality - viewing contacts is the primary purpose of the app. Without this, the app provides no value even if authenticated.

**Independent Test**: After authentication, user can immediately see their contact list paginated at 50 per page, with ability to load more and pull to refresh.

**Acceptance Scenarios**:

1. **Given** user is authenticated, **When** main screen loads, **Then** first 50 contacts are displayed with name, nickname, and last interaction
2. **Given** contact list is displayed, **When** user scrolls to bottom, **Then** "Load More" button appears or infinite scroll triggers
3. **Given** contact list is displayed, **When** user pulls down to refresh, **Then** latest data loads from Monica API
4. **Given** user has no contacts, **When** contact list loads, **Then** empty state message is displayed
5. **Given** contact list has 500+ items, **When** user scrolls, **Then** list maintains smooth 60fps performance

---

### User Story 3 - Search Contacts (Priority: P2)

As a Monica user, I want to search for a contact by name, company, or other attributes so that I can quickly find someone without scrolling.

**Why this priority**: Essential for users with many contacts, but app is still functional without it through browsing.

**Independent Test**: User can type in search bar and see filtered results appear within 500ms, with ability to clear search and return to full list.

**Acceptance Scenarios**:

1. **Given** contact list is displayed, **When** user types in search bar, **Then** results filter in real-time with 200-500ms debounce
2. **Given** search is active, **When** user taps clear button, **Then** search resets and full contact list returns
3. **Given** search term matches no contacts, **When** results load, **Then** "No contacts found" message appears
4. **Given** search term is "John", **When** results appear, **Then** contacts with "John", "Jon", or similar variations are shown

---

### User Story 4 - View Contact Details (Priority: P2)

As a Monica user, I want to tap a contact to see their full details so that I can view all information about them in one place.

**Why this priority**: Core value proposition - users need to access detailed information, but basic contact list still provides value for quick lookups.

**Independent Test**: Tap any contact from list to see full details including contact info, relationships, dates, activities, notes, and tasks.

**Acceptance Scenarios**:

1. **Given** contact list is displayed, **When** user taps a contact, **Then** detail screen shows all available information
2. **Given** contact has email address, **When** user taps email, **Then** Mail app opens with address pre-filled
3. **Given** contact has phone number, **When** user taps number, **Then** Phone app opens with number pre-filled
4. **Given** contact has relationships, **When** user taps related contact, **Then** navigation occurs to that contact's details
5. **Given** detail screen is displayed, **When** user swipes back, **Then** return to contact list at previous position

---

### User Story 5 - View Contact Activities & Timeline (Priority: P3)

As a Monica user, I want to see a timeline of my interactions with a contact so that I can remember our history and important moments.

**Why this priority**: Valuable for relationship management but not essential for basic contact viewing functionality.

**Independent Test**: On contact detail screen, expand Activities section to see chronological list of all interactions with pagination for large lists.

**Acceptance Scenarios**:

1. **Given** contact detail is displayed, **When** user expands Activities section, **Then** activities load sorted by date (newest first)
2. **Given** contact has 50+ activities, **When** section expands, **Then** first 10 load with "Load More" option
3. **Given** activity mentions other contacts, **When** displayed, **Then** related contacts are shown and tappable

---

### User Story 6 - View Related Contacts & Relationships (Priority: P3)

As a Monica user, I want to see who is related to a contact (family, friends, colleagues) so that I can navigate between related people.

**Why this priority**: Enhances navigation but core functionality works without it.

**Independent Test**: View relationships section on any contact with family/friends to see connections and navigate between them.

**Acceptance Scenarios**:

1. **Given** contact has relationships, **When** Relationships section is viewed, **Then** all related contacts show with relationship type
2. **Given** related contact is displayed, **When** user taps it, **Then** navigation occurs to that contact's details
3. **Given** contact has no relationships, **When** section is viewed, **Then** "No relationships" message appears

---

### User Story 7 - View Notes & Tasks (Priority: P3)

As a Monica user, I want to see notes and tasks associated with each contact so that I can remember important information and pending work.

**Why this priority**: Additional context that enriches the contact viewing experience but not critical for MVP.

**Independent Test**: Expand Notes and Tasks sections on contact detail to view all associated items with proper formatting and status.

**Acceptance Scenarios**:

1. **Given** contact has notes, **When** Notes section expands, **Then** all notes display with body text and dates
2. **Given** contact has tasks, **When** Tasks section expands, **Then** tasks show with title, status, and completion date
3. **Given** tasks are displayed, **When** sorted, **Then** incomplete tasks appear before completed ones

---

### User Story 8 - View Tags & Organization (Priority: P4)

As a Monica user, I want to see tags and how contacts are organized so that I can understand how I've categorized my relationships.

**Why this priority**: Nice-to-have organizational feature but doesn't block core functionality.

**Independent Test**: View tags on any tagged contact and potentially filter by tags.

**Acceptance Scenarios**:

1. **Given** contact has tags, **When** Tags section is viewed, **Then** all tags display as colored badges
2. **Given** contact has no tags, **When** section is viewed, **Then** "No tags" message appears

---

### User Story 9 - Handle API Errors Gracefully (Priority: P1)

As a user, I want to see helpful error messages when something goes wrong so that I understand what happened and what to do.

**Why this priority**: Critical for user experience and app reliability - poor error handling makes app unusable.

**Independent Test**: Trigger various error conditions (network off, invalid token, rate limits) and verify appropriate user-friendly messages appear.

**Acceptance Scenarios**:

1. **Given** network is unavailable, **When** API call fails, **Then** "Cannot connect. Check your internet and try again" message appears with retry option
2. **Given** API returns 401, **When** error occurs, **Then** "Your session expired. Please log in again" message appears and user is logged out
3. **Given** API returns 429, **When** rate limit hit, **Then** "Too many requests. Please wait a moment" message appears
4. **Given** API returns 500, **When** server error occurs, **Then** "Monica is having trouble. Please try again" message appears with retry

---

### User Story 10 - Manage Settings (Priority: P2)

As a Monica user, I want to configure app settings and manage my account so that I can customize my experience and switch instances.

**Why this priority**: Important for account management and instance switching but app functions without extensive settings.

**Independent Test**: Access Settings to view/update API token, clear cache, switch instances, or logout.

**Acceptance Scenarios**:

1. **Given** user is logged in, **When** Settings accessed, **Then** current instance URL and masked token are displayed
2. **Given** Settings displayed, **When** user taps "Switch Instance", **Then** logout occurs and onboarding screen appears
3. **Given** Settings displayed, **When** user taps "Clear Cache", **Then** all cached data is removed
4. **Given** Settings displayed, **When** user taps "Log Out", **Then** credentials cleared and login screen appears

---

### Edge Cases

- What happens when Monica API is down or unreachable?
- How does the app handle expired or revoked API tokens mid-session?
- What if a contact has thousands of activities or notes?
- How does the app behave with very slow network connections?
- What happens if the user's Monica instance has no contacts at all?
- How are malformed API responses handled?
- What if pagination links are missing from API response?
- How does the app handle contacts with missing required fields?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST authenticate users via Bearer token against Monica API endpoints
- **FR-002**: System MUST support both cloud (monicahq.com) and self-hosted Monica instances
- **FR-003**: System MUST store API tokens securely in iOS Keychain, never in UserDefaults
- **FR-004**: System MUST display paginated contact lists with 50 contacts per page by default
- **FR-005**: System MUST provide search functionality across contact names, nicknames, companies, and emails
- **FR-006**: System MUST display full contact details including all related data (activities, notes, tasks, relationships, tags, gifts)
- **FR-007**: System MUST handle all API error states with user-friendly messages
- **FR-008**: System MUST use HTTPS exclusively for all API communication
- **FR-009**: System MUST provide pull-to-refresh on contact list for latest data
- **FR-010**: System MUST allow navigation between related contacts
- **FR-011**: System MUST integrate with iOS native apps (Mail, Phone, Safari) for contact actions
- **FR-012**: System MUST automatically logout on 401 Unauthorized responses
- **FR-013**: System MUST provide settings for token management, cache clearing, and instance switching
- **FR-014**: System MUST respect iOS system settings (dark mode, dynamic type, accessibility)
- **FR-015**: System MUST maintain smooth 60fps scrolling performance with 500+ contacts
- **FR-016**: Users MUST be able to browse contacts without network after initial load (basic caching)
- **FR-017**: System MUST validate API tokens before allowing access to main interface
- **FR-018**: System MUST show relative dates (e.g., "2 days ago") for better readability

### Key Entities *(include if feature involves data)*

- **Contact**: Core entity representing a person with attributes like name, nickname, email, phone, addresses, and relationships
- **Activity**: Interaction or event related to a contact with date, type, summary, and description
- **Note**: Text content associated with a contact, can be favorited
- **Task**: Todo item linked to a contact with title, description, and completion status
- **Gift**: Gift idea or given gift for a contact with name, URL, value, and status
- **Tag**: Label for categorizing contacts
- **Relationship**: Connection between two contacts with relationship type (spouse, child, friend, etc.)

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: App launches in under 2 seconds on average iPhone (12 or newer)
- **SC-002**: Contact search returns results in under 500ms from typing
- **SC-003**: Contact list loads initial 50 contacts in under 2 seconds
- **SC-004**: Contact detail screen loads in under 1 second after tap
- **SC-005**: System maintains 100% stability (zero crashes) during normal use
- **SC-006**: System successfully authenticates with both cloud and self-hosted Monica instances
- **SC-007**: 90% of users can complete authentication on first attempt
- **SC-008**: Scrolling maintains consistent 60fps with 500+ contacts loaded
- **SC-009**: All API errors display user-friendly messages within 1 second
- **SC-010**: System handles 10-second API timeout gracefully with retry option

## Assumptions

- Users already have Monica accounts and API tokens from their web interface
- Monica API follows v4.x specification or higher
- Users primarily access the app on iPhone (iPad optimization deferred)
- Network connectivity is generally available (offline-first deferred to v2)
- Monica API rate limits are reasonable for mobile usage patterns
- Users understand the read-only nature of the MVP
- Contact photos/avatars are not available via current Monica API

## Constraints

- **iOS Version**: Minimum iOS 15+ support required
- **Device Support**: iPhone 12 and newer as primary target
- **Read-Only**: No write operations in MVP phase
- **API Compliance**: Must strictly follow Monica OpenAPI v1.0 specification
- **Security**: Keychain storage mandatory for sensitive data
- **Performance**: 60fps scrolling non-negotiable
- **Privacy**: No analytics on user's personal data

## Out of Scope

- Write operations (create, edit, delete contacts or related data)
- Offline-first architecture with sync
- Real-time notifications or live updates
- macOS, iPadOS, or watchOS versions
- Contact photos or avatar display
- Advanced filtering beyond basic search
- Share sheet integration
- App extensions or widgets
- Siri shortcuts
- Multiple account support simultaneously