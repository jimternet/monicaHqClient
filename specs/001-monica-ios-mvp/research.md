# Research: Monica iOS Client MVP Technical Implementation

**Date**: 2025-10-26  
**Feature**: Monica iOS Client MVP  
**Purpose**: Resolve technical decisions and validate architectural choices

## Technology Stack Research

### SwiftUI + MVVM Architecture Decision

**Decision**: Use SwiftUI with MVVM pattern for iOS 15+ application

**Rationale**:
- **Native Performance**: SwiftUI provides optimal performance for iOS 15+ with declarative UI patterns
- **Modern Async Support**: Built-in support for async/await with @StateObject and @Published properties
- **Accessibility**: Automatic VoiceOver and Dynamic Type support aligns with constitutional accessibility requirements
- **Testing**: MVVM with dependency injection enables comprehensive unit testing of business logic
- **Maintenance**: Declarative approach reduces complexity vs UIKit imperative programming

**Alternatives Considered**:
- UIKit + MVVM: Rejected due to increased verbosity and complexity for MVP
- SwiftUI + Redux: Rejected as overkill for read-only application without complex state management needs

### Monica API Integration Architecture

**Decision**: URLSession-based API client with Codable models matching OpenAPI specification

**Rationale**:
- **Zero Dependencies**: Aligns with constitutional principle of simplicity
- **API Compliance**: Direct mapping to Monica OpenAPI v1.0 specification found in docs/monica-api-openapi.yaml
- **Security**: Built-in URLSession provides proper HTTPS enforcement and certificate validation
- **Performance**: Native URLSession with async/await offers optimal performance for REST API calls

**Key API Endpoints for MVP** (from OpenAPI spec):
- `GET /contacts?query={search}&page={page}&limit={limit}` - Contact list with search and pagination
- `GET /contacts/{id}` - Individual contact details
- `GET /activities` - Activities list  
- `GET /notes` - Notes list
- `GET /tasks` - Tasks list
- `GET /gifts` - Gifts list
- `GET /tags` - Tags list

**Authentication**: Bearer token via `Authorization: Bearer {token}` header

### Data Models Architecture

**Decision**: Codable structs directly matching Monica API response format

**Rationale**:
- **Type Safety**: Swift's type system prevents runtime errors with structured data
- **API Compatibility**: Direct mapping to OpenAPI schema ensures compatibility
- **Performance**: No transformation overhead between API and domain models for read-only MVP
- **Maintainability**: Single source of truth for data structure definitions

**Core Models** (from OpenAPI spec):
```swift
struct Contact: Codable, Identifiable {
    let id: Int
    let first_name: String
    let last_name: String?
    let nickname: String?
    let gender_id: Int?
    let is_partial: Bool
    let is_dead: Bool
    let created_at: Date
    let updated_at: Date
}

struct Activity: Codable, Identifiable {
    let id: Int
    let activity_type_id: Int
    let summary: String
    let description: String?
    let happened_at: Date
    let contacts: [Int]
}

struct APIResponse<T: Codable>: Codable {
    let data: T
    let meta: PaginationMeta?
    let links: PaginationLinks?
}

struct PaginationMeta: Codable {
    let total: Int
    let current_page: Int
    let per_page: Int
}

struct PaginationLinks: Codable {
    let first: String?
    let last: String?
    let prev: String?
    let next: String?
}
```

### Storage & Security Architecture

**Decision**: Keychain for API tokens, in-memory caching for contact data

**Rationale**:
- **Security**: Keychain provides encrypted storage meeting constitutional privacy requirements
- **Simplicity**: No complex persistence layer needed for read-only MVP
- **Performance**: In-memory caching provides instant UI updates while respecting memory constraints
- **Privacy**: No local database reduces data exposure risk

**Storage Strategy**:
- API tokens → iOS Keychain (encrypted)
- App settings → UserDefaults (non-sensitive only)
- Contact cache → In-memory arrays with 5-minute TTL
- No CoreData/SQLite to reduce complexity

### Error Handling Strategy

**Decision**: Three-tier error handling with domain-specific error types

**Rationale**:
- **User Experience**: User-friendly error messages aligned with constitutional UX principles
- **Debugging**: Structured error logging for development without exposing PII
- **Reliability**: Graceful degradation and retry strategies for network issues

**Error Architecture**:
```swift
enum MonicaAPIError: LocalizedError {
    case invalidToken
    case networkUnavailable
    case contactNotFound(id: Int)
    case rateLimitExceeded
    case serverError(statusCode: Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidToken:
            return "Your API token is invalid or expired. Please log in again."
        case .networkUnavailable:
            return "Cannot connect. Check your internet connection and try again."
        case .contactNotFound(let id):
            return "Contact #\(id) was not found."
        case .rateLimitExceeded:
            return "Too many requests. Please wait a moment and try again."
        case .serverError(let code):
            return "Monica is having trouble (Error \(code)). Please try again later."
        }
    }
}
```

### Performance Optimization Strategy

**Decision**: Lazy loading with pagination and fixed-height list rows

**Rationale**:
- **Constitutional Requirement**: Must maintain 60fps scrolling with 10,000+ contacts
- **Memory Efficiency**: Batch loading prevents memory issues on older devices
- **User Experience**: Immediate feedback with skeleton loaders during data fetching

**Implementation Approach**:
- Default pagination: 50 contacts per page
- Fixed row heights for optimal List performance
- AsyncImage with proper placeholder handling
- Search debouncing (300ms) to reduce API calls
- Background queue for non-UI data processing

### Testing Strategy

**Decision**: XCTest with MockURLSession and protocol-based dependency injection

**Rationale**:
- **Constitutional Requirement**: 70%+ test coverage for core logic
- **Reliability**: Mock-based testing ensures predictable test execution
- **CI/CD Ready**: XCTest integrates with Xcode Cloud and GitHub Actions

**Testing Architecture**:
- Unit Tests: ViewModels, API client, storage services
- Integration Tests: End-to-end API flows with mock responses
- UI Tests: Critical user journeys (auth, contact browsing, search)
- Mock Services: Protocol-based mocks for all external dependencies

## Architecture Validation

### Constitutional Compliance Check

✅ **Privacy & Security First**: Keychain storage, HTTPS-only, no analytics  
✅ **Read-Only Simplicity**: API client focused only on GET operations  
✅ **Native iOS Experience**: SwiftUI + iOS 15+, system setting respect  
✅ **Clean Architecture**: MVVM + DI, clear separation of concerns  
✅ **API-First Design**: Direct OpenAPI spec compliance, graceful error handling  
✅ **Performance & Responsiveness**: 60fps scrolling, <2s load times  
✅ **Testing Standards**: XCTest with 70%+ coverage target  
✅ **Code Quality**: Swift conventions, no force unwraps, Result types  

### Risk Mitigation

**Risk**: Monica API rate limiting  
**Mitigation**: Implement exponential backoff and request deduplication

**Risk**: Large contact datasets impacting performance  
**Mitigation**: Pagination with 50-item batches and lazy loading

**Risk**: Network connectivity issues  
**Mitigation**: Offline graceful degradation with cached data display

**Risk**: API token expiration during use  
**Mitigation**: Automatic token validation and re-authentication flow

## Decision Summary

All technical decisions align with constitutional principles and MVP requirements. The chosen stack (SwiftUI + URLSession + Keychain + XCTest) provides:

1. **Zero external dependencies** - Constitutional simplicity requirement
2. **Native iOS experience** - SwiftUI + iOS 15+ alignment  
3. **Security by design** - Keychain storage + HTTPS enforcement
4. **Testable architecture** - DI + protocols enable comprehensive testing
5. **Performance at scale** - Pagination + caching for 10,000+ contacts
6. **API compliance** - Direct mapping to Monica OpenAPI specification

**Ready for Phase 1**: Data modeling and API contract implementation