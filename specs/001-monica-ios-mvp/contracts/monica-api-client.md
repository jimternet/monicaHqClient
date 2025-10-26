# Monica API Client Contract

**Date**: 2025-10-26  
**Feature**: Monica iOS Client MVP  
**Source**: Monica OpenAPI specification docs/monica-api-openapi.yaml

## API Client Interface

### MonicaAPIClientProtocol

```swift
protocol MonicaAPIClientProtocol {
    // Authentication
    func validateToken() async throws -> Bool
    
    // Contacts
    func listContacts(
        page: Int,
        limit: Int, 
        query: String?
    ) async throws -> APIResponse<[Contact]>
    
    func getContact(id: Int) async throws -> APIResponse<Contact>
    
    // Activities
    func listActivities(
        contactId: Int?,
        page: Int,
        limit: Int
    ) async throws -> APIResponse<[Activity]>
    
    func getActivity(id: Int) async throws -> APIResponse<Activity>
    
    // Notes
    func listNotes(
        contactId: Int?,
        page: Int,
        limit: Int
    ) async throws -> APIResponse<[Note]>
    
    // Tasks
    func listTasks(
        contactId: Int?,
        page: Int,
        limit: Int
    ) async throws -> APIResponse<[Task]>
    
    // Gifts
    func listGifts(
        contactId: Int?,
        page: Int,
        limit: Int
    ) async throws -> APIResponse<[Gift]>
    
    // Tags
    func listTags() async throws -> APIResponse<[Tag]>
}
```

## API Endpoints

### Authentication

#### Validate Token
- **Method**: GET
- **Endpoint**: `/contacts?limit=1`
- **Purpose**: Validate API token by making minimal request
- **Headers**: `Authorization: Bearer {token}`
- **Response**: 200 OK if valid, 401 Unauthorized if invalid
- **Usage**: Called on app launch and after 401 errors

### Contacts

#### List Contacts
- **Method**: GET
- **Endpoint**: `/contacts`
- **Query Parameters**:
  - `query` (optional): Search term for filtering contacts
  - `page` (optional): Page number (default: 1)
  - `limit` (optional): Items per page (default: 50, max: 100)
- **Headers**: `Authorization: Bearer {token}`
- **Response**: `APIResponse<[Contact]>` with pagination metadata
- **Example**: `/contacts?query=john&page=2&limit=50`

#### Get Contact Details
- **Method**: GET  
- **Endpoint**: `/contacts/{id}`
- **Path Parameters**:
  - `id`: Contact ID (integer)
- **Headers**: `Authorization: Bearer {token}`
- **Response**: `APIResponse<Contact>` with full contact details
- **Error Cases**: 404 if contact not found

### Activities

#### List Activities
- **Method**: GET
- **Endpoint**: `/activities`
- **Query Parameters**:
  - `contact_id` (optional): Filter by specific contact
  - `page` (optional): Page number (default: 1)
  - `limit` (optional): Items per page (default: 10, max: 50)
- **Headers**: `Authorization: Bearer {token}`
- **Response**: `APIResponse<[Activity]>` with pagination
- **Usage**: Load activities for contact detail view

#### Get Activity Details
- **Method**: GET
- **Endpoint**: `/activities/{id}`
- **Path Parameters**:
  - `id`: Activity ID (integer)
- **Headers**: `Authorization: Bearer {token}`
- **Response**: `APIResponse<Activity>` with full activity details

### Notes

#### List Notes
- **Method**: GET
- **Endpoint**: `/notes`
- **Query Parameters**:
  - `contact_id` (optional): Filter by specific contact
  - `page` (optional): Page number (default: 1)
  - `limit` (optional): Items per page (default: 10, max: 50)
- **Headers**: `Authorization: Bearer {token}`
- **Response**: `APIResponse<[Note]>` with pagination
- **Usage**: Load notes for contact detail view

### Tasks

#### List Tasks
- **Method**: GET
- **Endpoint**: `/tasks`
- **Query Parameters**:
  - `contact_id` (optional): Filter by specific contact
  - `page` (optional): Page number (default: 1)
  - `limit` (optional): Items per page (default: 10, max: 50)
- **Headers**: `Authorization: Bearer {token}`
- **Response**: `APIResponse<[Task]>` with pagination
- **Usage**: Load tasks for contact detail view

### Gifts

#### List Gifts
- **Method**: GET
- **Endpoint**: `/gifts`
- **Query Parameters**:
  - `contact_id` (optional): Filter by specific contact
  - `page` (optional): Page number (default: 1) 
  - `limit` (optional): Items per page (default: 10, max: 50)
- **Headers**: `Authorization: Bearer {token}`
- **Response**: `APIResponse<[Gift]>` with pagination
- **Usage**: Load gifts for contact detail view

### Tags

#### List Tags
- **Method**: GET
- **Endpoint**: `/tags`
- **Headers**: `Authorization: Bearer {token}`
- **Response**: `APIResponse<[Tag]>` (no pagination, all tags returned)
- **Usage**: Load available tags for contact categorization

## Error Handling

### HTTP Status Codes

#### 200 OK
- **Meaning**: Request successful
- **Action**: Process response data normally

#### 401 Unauthorized
- **Meaning**: Invalid or expired API token
- **Action**: Clear stored credentials, redirect to login
- **User Message**: "Your session expired. Please log in again."

#### 403 Forbidden
- **Meaning**: Token valid but insufficient permissions
- **Action**: Show error, do not logout
- **User Message**: "You don't have permission to access this data."

#### 404 Not Found
- **Meaning**: Resource not found (contact, activity, etc.)
- **Action**: Handle gracefully, show appropriate message
- **User Message**: "This item was not found. It may have been deleted."

#### 429 Too Many Requests
- **Meaning**: Rate limit exceeded
- **Action**: Implement exponential backoff retry
- **User Message**: "Too many requests. Please wait a moment and try again."

#### 500 Internal Server Error
- **Meaning**: Monica server error
- **Action**: Retry with exponential backoff (max 3 attempts)
- **User Message**: "Monica is having trouble. Please try again later."

#### Network Errors
- **Meaning**: No internet connection or timeout
- **Action**: Show cached data if available, provide retry option
- **User Message**: "Cannot connect. Check your internet connection and try again."

### Error Response Format

```json
{
  "error": {
    "message": "Human-readable error message",
    "code": 404
  }
}
```

### MonicaAPIError Enum

```swift
enum MonicaAPIError: LocalizedError {
    case invalidToken
    case networkUnavailable
    case notFound(resourceType: String, id: Int?)
    case rateLimitExceeded
    case serverError(statusCode: Int)
    case decodingError(DecodingError)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidToken:
            return "Your session expired. Please log in again."
        case .networkUnavailable:
            return "Cannot connect. Check your internet connection and try again."
        case .notFound(let type, let id):
            if let id = id {
                return "\(type.capitalized) #\(id) was not found."
            } else {
                return "\(type.capitalized) was not found."
            }
        case .rateLimitExceeded:
            return "Too many requests. Please wait a moment and try again."
        case .serverError(let code):
            return "Monica is having trouble (Error \(code)). Please try again later."
        case .decodingError:
            return "Unable to process server response. Please try again."
        case .unknown:
            return "An unexpected error occurred. Please try again."
        }
    }
}
```

## Request/Response Examples

### List Contacts Request
```http
GET /contacts?query=john&page=1&limit=50 HTTP/1.1
Host: monica.example.com
Authorization: Bearer your_api_token_here
Accept: application/json
```

### List Contacts Response
```json
{
  "data": [
    {
      "id": 1,
      "first_name": "John",
      "last_name": "Doe",
      "nickname": "Johnny",
      "gender_id": 1,
      "is_partial": false,
      "is_dead": false,
      "created_at": "2024-01-15T10:30:00Z",
      "updated_at": "2024-10-26T14:22:00Z"
    }
  ],
  "meta": {
    "total": 1247,
    "current_page": 1,
    "per_page": 50
  },
  "links": {
    "first": "/contacts?page=1&limit=50",
    "last": "/contacts?page=25&limit=50", 
    "prev": null,
    "next": "/contacts?page=2&limit=50"
  }
}
```

### Get Contact Request
```http
GET /contacts/1 HTTP/1.1
Host: monica.example.com
Authorization: Bearer your_api_token_here
Accept: application/json
```

### Get Contact Response
```json
{
  "data": {
    "id": 1,
    "first_name": "John",
    "last_name": "Doe",
    "nickname": "Johnny",
    "gender_id": 1,
    "is_partial": false,
    "is_dead": false,
    "created_at": "2024-01-15T10:30:00Z",
    "updated_at": "2024-10-26T14:22:00Z"
  }
}
```

### Error Response Example
```json
{
  "error": {
    "message": "The requested contact was not found.",
    "code": 404
  }
}
```

## Rate Limiting

### Limits
- **Contacts**: 100 requests per minute
- **Activities/Notes/Tasks/Gifts**: 200 requests per minute
- **Authentication**: 10 requests per minute

### Retry Strategy
```swift
// Exponential backoff with jitter
let baseDelay = 1.0 // seconds
let maxRetries = 3
let jitter = Double.random(in: 0.1...0.3)

for attempt in 1...maxRetries {
    let delay = baseDelay * pow(2.0, Double(attempt - 1)) + jitter
    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
    // Retry request
}
```

### Request Deduplication
- Cache identical requests for 5 seconds
- Use request URL + parameters as cache key
- Prevents duplicate API calls during rapid user interaction

## Configuration

### Base URL Configuration
```swift
struct APIConfiguration {
    let baseURL: URL
    let token: String
    let timeout: TimeInterval = 10.0
    let retryCount: Int = 3
    
    static let cloud = APIConfiguration(
        baseURL: URL(string: "https://app.monicahq.com/api")!,
        token: "" // Set by user
    )
    
    static func selfHosted(url: String, token: String) -> APIConfiguration {
        return APIConfiguration(
            baseURL: URL(string: "\(url)/api")!,
            token: token
        )
    }
}
```

### URLSession Configuration
```swift
let configuration = URLSessionConfiguration.default
configuration.timeoutIntervalForRequest = 10.0
configuration.timeoutIntervalForResource = 30.0
configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
configuration.httpAdditionalHeaders = [
    "Accept": "application/json",
    "User-Agent": "MonicaClient/1.0 iOS"
]
```

## Testing Contracts

### Mock API Client
```swift
class MockMonicaAPIClient: MonicaAPIClientProtocol {
    var shouldFail = false
    var mockContacts: [Contact] = []
    var mockActivities: [Activity] = []
    
    func listContacts(page: Int, limit: Int, query: String?) async throws -> APIResponse<[Contact]> {
        if shouldFail {
            throw MonicaAPIError.networkUnavailable
        }
        
        let startIndex = (page - 1) * limit
        let endIndex = min(startIndex + limit, mockContacts.count)
        let contacts = Array(mockContacts[startIndex..<endIndex])
        
        return APIResponse(
            data: contacts,
            meta: PaginationMeta(
                total: mockContacts.count,
                current_page: page,
                per_page: limit
            ),
            links: nil
        )
    }
    
    // Additional mock implementations...
}
```

### Contract Tests
```swift
func testContactListPagination() async throws {
    // Verify pagination works correctly
    let response = try await apiClient.listContacts(page: 1, limit: 10, query: nil)
    
    XCTAssertEqual(response.data.count, 10)
    XCTAssertEqual(response.meta?.current_page, 1)
    XCTAssertEqual(response.meta?.per_page, 10)
    XCTAssertNotNil(response.links?.next)
}

func testInvalidTokenHandling() async {
    // Verify 401 errors are handled correctly
    do {
        _ = try await apiClient.listContacts(page: 1, limit: 10, query: nil)
        XCTFail("Expected error")
    } catch MonicaAPIError.invalidToken {
        // Expected behavior
    } catch {
        XCTFail("Unexpected error: \(error)")
    }
}
```

This API contract provides a complete specification for integrating with the Monica CRM API, ensuring type safety, proper error handling, and reliable communication for the iOS MVP application.