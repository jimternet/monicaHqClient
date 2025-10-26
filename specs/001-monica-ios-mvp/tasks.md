# Tasks: Monica iOS Client MVP

**Input**: Design documents from `/specs/001-monica-ios-mvp/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: The examples below include test tasks. Tests are OPTIONAL - only include them if explicitly requested in the feature specification.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **iOS Project**: `MonicaClient/MonicaClient/` at repository root
- **Tests**: `MonicaClient/MonicaClientTests/`
- Paths shown below assume iOS project structure from plan.md

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [ ] T001 Create iOS project with name "MonicaClient" in Xcode with SwiftUI interface, iOS 15.0 deployment target
- [ ] T002 Configure project settings: Bundle identifier, capabilities (Keychain Sharing), and Info.plist
- [ ] T003 [P] Create folder structure in MonicaClient/MonicaClient/ according to plan.md architecture
- [ ] T004 [P] Create test target structure in MonicaClient/MonicaClientTests/ with UnitTests, IntegrationTests, and Mocks folders
- [ ] T005 [P] Create Assets.xcassets with app icon placeholders and color sets for branding

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T006 Create APIResponse struct in MonicaClient/Models/APIResponse.swift with generic data, meta, and links properties
- [ ] T007 [P] Create MonicaAPIError enum in MonicaClient/Services/API/APIError.swift with LocalizedError conformance
- [ ] T008 [P] Create Contact model in MonicaClient/Models/Contact.swift with Codable and Identifiable conformance
- [ ] T009 [P] Create Activity model in MonicaClient/Models/Activity.swift with Codable and Identifiable conformance
- [ ] T010 [P] Create Note model in MonicaClient/Models/Note.swift with Codable and Identifiable conformance
- [ ] T011 [P] Create Task model in MonicaClient/Models/Task.swift with Codable and Identifiable conformance
- [ ] T012 [P] Create Gift model in MonicaClient/Models/Gift.swift with Codable and Identifiable conformance
- [ ] T013 [P] Create Tag model in MonicaClient/Models/Tag.swift with Codable and Identifiable conformance
- [ ] T014 Create MonicaAPIClientProtocol in MonicaClient/Services/API/MonicaAPIClient.swift with all required methods
- [ ] T015 [P] Create KeychainService in MonicaClient/Services/Storage/KeychainService.swift for secure token storage
- [ ] T016 [P] Create UserDefaultsService in MonicaClient/Services/Storage/UserDefaultsService.swift for app settings
- [ ] T017 [P] Create CacheService in MonicaClient/Services/Storage/CacheService.swift for in-memory contact caching
- [ ] T018 [P] Create Constants file in MonicaClient/Utilities/Constants.swift with API endpoints and configuration
- [ ] T019 [P] Create Extensions file in MonicaClient/Utilities/Extensions.swift with common UI and data extensions
- [ ] T020 [P] Create DateFormatting utility in MonicaClient/Utilities/DateFormatting.swift for relative date display

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Authentication & API Configuration (Priority: P1) 🎯 MVP

**Goal**: Enable users to configure API endpoint and authenticate with Monica instances

**Independent Test**: Configure cloud or self-hosted endpoint with API token, verify successful authentication and storage of credentials

### Implementation for User Story 1

- [ ] T021 [P] [US1] Create AuthCredentials model in MonicaClient/Features/Authentication/Models/AuthCredentials.swift
- [ ] T022 [P] [US1] Create OnboardingView in MonicaClient/Features/Authentication/Views/OnboardingView.swift with cloud/self-hosted selection
- [ ] T023 [P] [US1] Create LoginView in MonicaClient/Features/Authentication/Views/LoginView.swift with endpoint and token inputs
- [ ] T024 [US1] Create AuthenticationViewModel in MonicaClient/Features/Authentication/ViewModels/AuthenticationViewModel.swift (depends on T021)
- [ ] T025 [US1] Implement MonicaAPIClient class with authentication methods in MonicaClient/Services/API/MonicaAPIClient.swift
- [ ] T026 [US1] Integrate Keychain storage for credentials in AuthenticationViewModel
- [ ] T027 [US1] Add token validation and error handling to AuthenticationViewModel
- [ ] T028 [US1] Update MonicaClientApp.swift to show authentication flow based on stored credentials
- [ ] T029 [US1] Add authentication state management and auto-login functionality

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently

---

## Phase 4: User Story 2 - Browse & Paginate Contacts (Priority: P1)

**Goal**: Display paginated list of contacts with pull-to-refresh functionality

**Independent Test**: After authentication, see contact list with 50 contacts per page, pull-to-refresh, and smooth scrolling

### Implementation for User Story 2

- [ ] T030 [P] [US2] Create ContactRowView in MonicaClient/Features/ContactList/Views/ContactRowView.swift with contact display
- [ ] T031 [P] [US2] Create ContactListView in MonicaClient/Features/ContactList/Views/ContactListView.swift with List and navigation
- [ ] T032 [US2] Create ContactListViewModel in MonicaClient/Features/ContactList/ViewModels/ContactListViewModel.swift (depends on T030, T031)
- [ ] T033 [US2] Implement listContacts method in MonicaAPIClient with pagination support
- [ ] T034 [US2] Add contact caching logic to CacheService for performance optimization
- [ ] T035 [US2] Integrate pull-to-refresh functionality in ContactListView
- [ ] T036 [US2] Add infinite scroll or "Load More" functionality for pagination
- [ ] T037 [US2] Add empty state handling for users with no contacts
- [ ] T038 [US2] Optimize contact list performance for 500+ contacts with fixed row heights

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently

---

## Phase 5: User Story 9 - Handle API Errors Gracefully (Priority: P1)

**Goal**: Provide user-friendly error messages for all API failure scenarios

**Independent Test**: Trigger various error conditions (network off, invalid token, server errors) and verify appropriate messages appear with retry options

### Implementation for User Story 9

- [ ] T039 [P] [US9] Enhance MonicaAPIError enum with all error cases and user-friendly descriptions
- [ ] T040 [P] [US9] Create NetworkMonitor service in MonicaClient/Services/NetworkMonitor.swift for connectivity checks
- [ ] T041 [US9] Add comprehensive error handling to MonicaAPIClient with retry logic
- [ ] T042 [US9] Implement error presentation in ContactListViewModel with retry callbacks
- [ ] T043 [US9] Add error alerts and retry buttons to ContactListView
- [ ] T044 [US9] Implement automatic logout on 401 errors with credential cleanup
- [ ] T045 [US9] Add network connectivity checks before API calls
- [ ] T046 [US9] Add error logging for debugging without exposing PII

**Checkpoint**: At this point, error handling should be robust across all implemented features

---

## Phase 6: User Story 3 - Search Contacts (Priority: P2)

**Goal**: Enable real-time contact search with debouncing and clear functionality

**Independent Test**: Type in search bar, see filtered results within 500ms, clear search to return to full list

### Implementation for User Story 3

- [ ] T047 [P] [US3] Add search functionality to MonicaAPIClient listContacts method with query parameter
- [ ] T048 [US3] Add search state management to ContactListViewModel with debouncing
- [ ] T049 [US3] Integrate searchable modifier in ContactListView with 300ms debounce
- [ ] T050 [US3] Add search result handling and "no results" state to ContactListView
- [ ] T051 [US3] Implement search result caching to avoid duplicate API calls
- [ ] T052 [US3] Add search clear functionality to reset to full contact list

**Checkpoint**: At this point, contact search should work independently alongside browsing

---

## Phase 7: User Story 4 - View Contact Details (Priority: P2)

**Goal**: Display comprehensive contact information with navigation and system integration

**Independent Test**: Tap contact to see full details including all sections, tap email/phone to open system apps, navigate back to list

### Implementation for User Story 4

- [ ] T053 [P] [US4] Create ContactDetailView in MonicaClient/Features/ContactDetail/Views/ContactDetailView.swift with comprehensive layout
- [ ] T054 [P] [US4] Create ActivitySection view component for displaying contact activities
- [ ] T055 [P] [US4] Create NotesSection view component for displaying contact notes
- [ ] T056 [P] [US4] Create TasksSection view component for displaying contact tasks
- [ ] T057 [US4] Create ContactDetailViewModel in MonicaClient/Features/ContactDetail/ViewModels/ContactDetailViewModel.swift
- [ ] T058 [US4] Implement getContact method in MonicaAPIClient for detailed contact data
- [ ] T059 [US4] Add navigation from ContactListView to ContactDetailView with contact parameter
- [ ] T060 [US4] Implement email and phone tap handlers to open system Mail and Phone apps
- [ ] T061 [US4] Add loading states and error handling to ContactDetailView
- [ ] T062 [US4] Add back navigation functionality to return to contact list at previous position

**Checkpoint**: At this point, contact details should be fully accessible and integrated with system apps

---

## Phase 8: User Story 10 - Manage Settings (Priority: P2)

**Goal**: Provide settings for account management, cache control, and app configuration

**Independent Test**: Access settings, view current instance info, clear cache, logout, and switch instances

### Implementation for User Story 10

- [ ] T063 [P] [US10] Create SettingsView in MonicaClient/Features/Settings/Views/SettingsView.swift with all settings options
- [ ] T064 [US10] Create SettingsViewModel in MonicaClient/Features/Settings/ViewModels/SettingsViewModel.swift
- [ ] T065 [US10] Add settings navigation to main app interface (tab bar or menu)
- [ ] T066 [US10] Implement logout functionality with credential clearing and navigation reset
- [ ] T067 [US10] Add cache management features (display size, clear cache functionality)
- [ ] T068 [US10] Implement instance switching functionality to return to onboarding
- [ ] T069 [US10] Add app version and about information display
- [ ] T070 [US10] Add API token management (display masked token, update functionality)

**Checkpoint**: At this point, settings should provide complete account and app management

---

## Phase 9: User Story 5 - View Contact Activities & Timeline (Priority: P3)

**Goal**: Display chronological activity timeline with pagination for large lists

**Independent Test**: Expand Activities section on contact detail to see timeline sorted by date with "Load More" for 50+ activities

### Implementation for User Story 5

- [ ] T071 [P] [US5] Implement listActivities method in MonicaAPIClient with contactId filtering
- [ ] T072 [US5] Add activity loading to ContactDetailViewModel with pagination support
- [ ] T073 [US5] Create ActivityTimelineView in MonicaClient/Features/ContactDetail/Views/ActivityTimelineView.swift
- [ ] T074 [US5] Integrate activity timeline into ContactDetailView as collapsible section
- [ ] T075 [US5] Add activity detail display with related contacts and tappable links
- [ ] T076 [US5] Implement "Load More" functionality for contacts with 50+ activities
- [ ] T077 [US5] Add activity type handling and appropriate icons/styling

**Checkpoint**: At this point, activity timeline should enhance contact details independently

---

## Phase 10: User Story 6 - View Related Contacts & Relationships (Priority: P3)

**Goal**: Display contact relationships with navigation between related contacts

**Independent Test**: View relationships section showing family/friends with relationship types, tap to navigate to related contact details

### Implementation for User Story 6

- [ ] T078 [P] [US6] Add relationship data handling to Contact model and API responses
- [ ] T079 [P] [US6] Create relationship display component in ContactDetailView
- [ ] T080 [US6] Implement relationship navigation to other contact details
- [ ] T081 [US6] Add relationship type display (spouse, child, friend, colleague, etc.)
- [ ] T082 [US6] Handle "no relationships" state with appropriate messaging
- [ ] T083 [US6] Add back navigation handling for relationship browsing

**Checkpoint**: At this point, relationship navigation should work independently

---

## Phase 11: User Story 7 - View Notes & Tasks (Priority: P3)

**Goal**: Display notes and tasks with proper formatting and status indicators

**Independent Test**: Expand Notes and Tasks sections to view content with creation dates, completion status, and proper text formatting

### Implementation for User Story 7

- [ ] T084 [P] [US7] Implement listNotes method in MonicaAPIClient with contactId filtering
- [ ] T085 [P] [US7] Implement listTasks method in MonicaAPIClient with contactId filtering
- [ ] T086 [US7] Add notes and tasks loading to ContactDetailViewModel
- [ ] T087 [US7] Enhance NotesSection with proper text formatting and favorited status
- [ ] T088 [US7] Enhance TasksSection with completion status and sorting (incomplete first)
- [ ] T089 [US7] Add pagination support for contacts with many notes/tasks
- [ ] T090 [US7] Add collapsible section functionality with expand/collapse states

**Checkpoint**: At this point, notes and tasks should provide rich context for contacts

---

## Phase 12: User Story 8 - View Tags & Organization (Priority: P4)

**Goal**: Display contact tags as visual badges with potential filtering capability

**Independent Test**: View tags section showing colored badges for contact categorization

### Implementation for User Story 8

- [ ] T091 [P] [US8] Implement listTags method in MonicaAPIClient for available tags
- [ ] T092 [P] [US8] Add tag display to ContactDetailView as colored badges
- [ ] T093 [US8] Add tag data to Contact model and API integration
- [ ] T094 [US8] Implement "no tags" state handling
- [ ] T095 [US8] Add tag color and styling for visual distinction
- [ ] T096 [US8] Add optional tag filtering functionality for future enhancement

**Checkpoint**: At this point, all user stories should be independently functional

---

## Phase 13: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] T097 [P] Add app launch performance optimization and memory usage monitoring
- [ ] T098 [P] Implement accessibility improvements (VoiceOver, Dynamic Type, High Contrast)
- [ ] T099 [P] Add proper dark mode support across all views and components
- [ ] T100 [P] Implement comprehensive logging system without PII exposure
- [ ] T101 [P] Add performance monitoring for 60fps scrolling and load times
- [ ] T102 [P] Create comprehensive README.md with setup instructions and API token guidance
- [ ] T103 [P] Add architecture documentation in docs/ folder
- [ ] T104 Add end-to-end manual testing across all user stories
- [ ] T105 Add final performance testing with 10,000+ contacts
- [ ] T106 Run comprehensive security audit on API token handling and storage

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
  - Authentication (US1) must complete before any other user stories
  - Browse Contacts (US2) and Error Handling (US9) should complete before other features
  - Remaining user stories can proceed in priority order or in parallel
- **Polish (Phase 13)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1) - Authentication**: Can start after Foundational - No dependencies on other stories
- **User Story 2 (P1) - Browse Contacts**: Can start after Authentication - Independent of other features
- **User Story 9 (P1) - Error Handling**: Can start after Authentication - Enhances all other features
- **User Story 3 (P2) - Search**: Can start after Browse Contacts - Independent addition to contact list
- **User Story 4 (P2) - Contact Details**: Can start after Browse Contacts - Independent detail view
- **User Story 10 (P2) - Settings**: Can start after Authentication - Independent settings management
- **User Story 5 (P3) - Activities**: Can start after Contact Details - Enhances detail view
- **User Story 6 (P3) - Relationships**: Can start after Contact Details - Enhances detail view
- **User Story 7 (P3) - Notes & Tasks**: Can start after Contact Details - Enhances detail view
- **User Story 8 (P4) - Tags**: Can start after Contact Details - Enhances detail view

### Within Each User Story

- Models before ViewModels
- Views before ViewModels (for UI-dependent logic)
- API client methods before ViewModels that use them
- Core functionality before integrations and enhancements
- Story complete before moving to next priority

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel
- All Foundational tasks marked [P] can run in parallel (within Phase 2)
- Once Authentication (US1) completes, US2 and US9 can start in parallel
- Once Browse Contacts (US2) completes, all detail-view stories (US4-US8) can start in parallel
- Models within different stories marked [P] can run in parallel
- Different user stories can be worked on in parallel by different team members

---

## Parallel Example: User Story 1 (Authentication)

```bash
# Launch foundational models together:
Task: "Create AuthCredentials model in MonicaClient/Features/Authentication/Models/AuthCredentials.swift"
Task: "Create OnboardingView in MonicaClient/Features/Authentication/Views/OnboardingView.swift with cloud/self-hosted selection"
Task: "Create LoginView in MonicaClient/Features/Authentication/Views/LoginView.swift with endpoint and token inputs"

# Then implement ViewModel that depends on them:
Task: "Create AuthenticationViewModel in MonicaClient/Features/Authentication/ViewModels/AuthenticationViewModel.swift"
```

---

## Implementation Strategy

### MVP First (User Stories 1, 2, 9 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1 (Authentication)
4. Complete Phase 4: User Story 2 (Browse Contacts)
5. Complete Phase 5: User Story 9 (Error Handling)
6. **STOP and VALIDATE**: Test these three stories independently
7. Deploy/demo if ready - this provides core value

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add Authentication → Test independently → Deploy/Demo (Login MVP!)
3. Add Browse Contacts + Error Handling → Test independently → Deploy/Demo (Core MVP!)
4. Add Search → Test independently → Deploy/Demo
5. Add Contact Details → Test independently → Deploy/Demo
6. Add Settings → Test independently → Deploy/Demo
7. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Authentication is done:
   - Developer A: User Story 2 (Browse Contacts)
   - Developer B: User Story 9 (Error Handling)
3. Once core stories complete:
   - Developer A: User Story 3 (Search) + User Story 4 (Contact Details)
   - Developer B: User Story 10 (Settings) + User Story 5 (Activities)
   - Developer C: User Stories 6, 7, 8 (Detail enhancements)
4. Stories complete and integrate independently

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence
- All file paths are absolute and match the project structure from plan.md
- Testing is optional per constitutional requirements - focus on manual testing and user validation