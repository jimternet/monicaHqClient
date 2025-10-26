# Quickstart Guide: Monica iOS Client MVP

**Date**: 2025-10-26  
**Feature**: Monica iOS Client MVP  
**Target**: iOS 15.0+, iPhone, Swift 5.5+

## Prerequisites

### Development Environment
- **Xcode**: 15.0+ (for iOS 15+ support and async/await)
- **iOS Simulator**: iPhone 12+ recommended for testing
- **macOS**: 13.0+ (for Xcode 15 support)
- **Monica Instance**: Access to cloud (monicahq.com) or self-hosted Monica with API token

### Monica API Access
1. Sign up for Monica account at [monicahq.com](https://monicahq.com) OR set up self-hosted instance
2. Generate API token in Monica Settings → API
3. Test API access: `curl -H "Authorization: Bearer YOUR_TOKEN" https://app.monicahq.com/api/contacts`

## Project Setup

### 1. Create New iOS Project
```bash
# Open Xcode
# File → New → Project
# iOS → App
# Product Name: MonicaClient
# Interface: SwiftUI
# Language: Swift
# Deployment Target: iOS 15.0
```

### 2. Project Configuration
- **Bundle Identifier**: `com.yourcompany.monicaclient`
- **Deployment Target**: iOS 15.0
- **Supported Orientations**: Portrait (primary), Landscape (optional)
- **Capabilities**: Keychain Sharing (for secure token storage)

### 3. Project Structure Setup
```
MonicaClient/
├── MonicaClient/
│   ├── App/
│   │   ├── MonicaClientApp.swift        # App entry point
│   │   └── ContentView.swift            # Root view
│   ├── Features/
│   │   ├── Authentication/
│   │   │   ├── Views/
│   │   │   │   ├── OnboardingView.swift
│   │   │   │   └── LoginView.swift
│   │   │   ├── ViewModels/
│   │   │   │   └── AuthenticationViewModel.swift
│   │   │   └── Models/
│   │   │       └── AuthCredentials.swift
│   │   ├── ContactList/
│   │   │   ├── Views/
│   │   │   │   ├── ContactListView.swift
│   │   │   │   └── ContactRowView.swift
│   │   │   └── ViewModels/
│   │   │       └── ContactListViewModel.swift
│   │   ├── ContactDetail/
│   │   │   ├── Views/
│   │   │   │   ├── ContactDetailView.swift
│   │   │   │   ├── ActivitySection.swift
│   │   │   │   ├── NotesSection.swift
│   │   │   │   └── TasksSection.swift
│   │   │   └── ViewModels/
│   │   │       └── ContactDetailViewModel.swift
│   │   └── Settings/
│   │       ├── Views/
│   │       │   └── SettingsView.swift
│   │       └── ViewModels/
│   │           └── SettingsViewModel.swift
│   ├── Services/
│   │   ├── API/
│   │   │   ├── MonicaAPIClient.swift
│   │   │   ├── APIError.swift
│   │   │   └── APIResponse.swift
│   │   ├── Storage/
│   │   │   ├── KeychainService.swift
│   │   │   ├── UserDefaultsService.swift
│   │   │   └── CacheService.swift
│   │   └── NetworkMonitor.swift
│   ├── Models/
│   │   ├── Contact.swift
│   │   ├── Activity.swift
│   │   ├── Note.swift
│   │   ├── Task.swift
│   │   ├── Gift.swift
│   │   └── Tag.swift
│   ├── Utilities/
│   │   ├── DateFormatting.swift
│   │   ├── Constants.swift
│   │   └── Extensions.swift
│   └── Resources/
│       ├── Assets.xcassets
│       └── Info.plist
└── MonicaClientTests/
    ├── UnitTests/
    ├── IntegrationTests/
    └── Mocks/
```

## Quick Implementation

### 1. Core Models (10 minutes)

Create `Models/Contact.swift`:
```swift
import Foundation

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
    
    var displayName: String {
        if let lastName = last_name {
            return "\(first_name) \(lastName)"
        }
        return first_name
    }
    
    var initials: String {
        let firstInitial = String(first_name.prefix(1)).uppercased()
        let lastInitial = last_name?.prefix(1).uppercased() ?? ""
        return "\(firstInitial)\(lastInitial)"
    }
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

### 2. API Client (15 minutes)

Create `Services/API/MonicaAPIClient.swift`:
```swift
import Foundation

enum MonicaAPIError: LocalizedError {
    case invalidToken
    case networkUnavailable
    case decodingError
    case serverError(Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidToken:
            return "Your session expired. Please log in again."
        case .networkUnavailable:
            return "Cannot connect. Check your internet connection."
        case .decodingError:
            return "Unable to process server response."
        case .serverError(let code):
            return "Server error (\(code)). Please try again later."
        }
    }
}

protocol MonicaAPIClientProtocol {
    func listContacts(page: Int, limit: Int, query: String?) async throws -> APIResponse<[Contact]>
    func validateToken() async throws -> Bool
}

@MainActor
class MonicaAPIClient: MonicaAPIClientProtocol {
    private let baseURL: URL
    private let token: String
    private let session: URLSession
    
    init(baseURL: URL, token: String) {
        self.baseURL = baseURL
        self.token = token
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10.0
        self.session = URLSession(configuration: config)
    }
    
    func validateToken() async throws -> Bool {
        let url = baseURL.appendingPathComponent("contacts")
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (_, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw MonicaAPIError.networkUnavailable
            }
            return httpResponse.statusCode == 200
        } catch {
            throw MonicaAPIError.networkUnavailable
        }
    }
    
    func listContacts(page: Int = 1, limit: Int = 50, query: String? = nil) async throws -> APIResponse<[Contact]> {
        var components = URLComponents(url: baseURL.appendingPathComponent("contacts"), resolvingAgainstBaseURL: true)!
        
        var queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        
        if let query = query, !query.isEmpty {
            queryItems.append(URLQueryItem(name: "query", value: query))
        }
        
        components.queryItems = queryItems
        
        var request = URLRequest(url: components.url!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw MonicaAPIError.networkUnavailable
            }
            
            switch httpResponse.statusCode {
            case 200:
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return try decoder.decode(APIResponse<[Contact]>.self, from: data)
            case 401:
                throw MonicaAPIError.invalidToken
            default:
                throw MonicaAPIError.serverError(httpResponse.statusCode)
            }
        } catch let error as DecodingError {
            throw MonicaAPIError.decodingError
        } catch let error as MonicaAPIError {
            throw error
        } catch {
            throw MonicaAPIError.networkUnavailable
        }
    }
}
```

### 3. Contact List View (20 minutes)

Create `Features/ContactList/Views/ContactListView.swift`:
```swift
import SwiftUI

struct ContactListView: View {
    @StateObject private var viewModel = ContactListViewModel()
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            List(viewModel.contacts) { contact in
                ContactRowView(contact: contact)
                    .onTapGesture {
                        // Navigate to detail view
                    }
            }
            .navigationTitle("Contacts")
            .searchable(text: $searchText, prompt: "Search contacts")
            .refreshable {
                await viewModel.refreshContacts()
            }
            .task {
                await viewModel.loadContacts()
            }
            .task(id: searchText) {
                try? await Task.sleep(nanoseconds: 300_000_000) // 300ms debounce
                await viewModel.searchContacts(query: searchText)
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.clearError() }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
}

struct ContactRowView: View {
    let contact: Contact
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.blue)
                .frame(width: 50, height: 50)
                .overlay(
                    Text(contact.initials)
                        .foregroundColor(.white)
                        .font(.headline)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(contact.displayName)
                    .font(.headline)
                    .lineLimit(1)
                
                if let nickname = contact.nickname {
                    Text(""\(nickname)"")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            if contact.is_partial {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(.orange)
            }
        }
        .frame(height: 70)
    }
}
```

### 4. ViewModel (15 minutes)

Create `Features/ContactList/ViewModels/ContactListViewModel.swift`:
```swift
import Foundation

@MainActor
class ContactListViewModel: ObservableObject {
    @Published var contacts: [Contact] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiClient: MonicaAPIClientProtocol
    
    init(apiClient: MonicaAPIClientProtocol = MonicaAPIClient.shared) {
        self.apiClient = apiClient
    }
    
    func loadContacts() async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiClient.listContacts(page: 1, limit: 50)
            contacts = response.data
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func searchContacts(query: String) async {
        guard !query.isEmpty else {
            await loadContacts()
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiClient.listContacts(page: 1, limit: 50, query: query)
            contacts = response.data
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func refreshContacts() async {
        await loadContacts()
    }
    
    func clearError() {
        errorMessage = nil
    }
}

// Add to MonicaAPIClient.swift for quick testing
extension MonicaAPIClient {
    static let shared = MonicaAPIClient(
        baseURL: URL(string: "https://app.monicahq.com/api")!,
        token: "YOUR_API_TOKEN_HERE"
    )
}
```

### 5. App Entry Point (5 minutes)

Update `App/MonicaClientApp.swift`:
```swift
import SwiftUI

@main
struct MonicaClientApp: App {
    var body: some Scene {
        WindowGroup {
            ContactListView()
        }
    }
}
```

## Testing the Build

### 1. Basic Compilation Test
```bash
# In Xcode
# Product → Build (⌘+B)
# Should compile without errors
```

### 2. Simulator Test
```bash
# In Xcode
# Product → Run (⌘+R)
# Should launch in iOS Simulator
# Contact list should appear (empty without valid API token)
```

### 3. API Integration Test
1. Replace `YOUR_API_TOKEN_HERE` with real Monica API token
2. Run app in simulator
3. Contacts should load from your Monica instance
4. Search should filter contacts
5. Pull-to-refresh should reload data

## Next Steps for Full Implementation

### Phase 1: Complete Basic Features (1-2 weeks)
- [ ] Authentication flow with onboarding
- [ ] Keychain integration for token storage  
- [ ] Contact detail view
- [ ] Settings screen
- [ ] Error handling improvements

### Phase 2: Enhanced Features (1-2 weeks)
- [ ] Activities, notes, tasks, gifts display
- [ ] Pagination for large contact lists
- [ ] Offline caching
- [ ] Search improvements

### Phase 3: Polish & Testing (1 week)
- [ ] Unit tests for ViewModels
- [ ] Integration tests for API client
- [ ] UI tests for critical flows
- [ ] Performance optimization
- [ ] Accessibility improvements

## Troubleshooting

### Common Issues

#### Build Errors
- **"Cannot find type 'Contact'"**: Ensure all model files are added to target
- **"Use of unresolved identifier"**: Check import statements and file organization
- **Async/await errors**: Verify deployment target is iOS 15.0+

#### Runtime Issues
- **Empty contact list**: Verify API token is valid and has permissions
- **Network errors**: Check internet connection and API endpoint URL
- **App crashes on search**: Ensure proper error handling in search implementation

#### API Integration Issues
- **401 Unauthorized**: API token is invalid or expired
- **404 Not Found**: Check base URL format (should end with `/api`)
- **Timeout errors**: Increase timeout or check network stability

### Debug Tools
- **Xcode Console**: Monitor API requests and responses
- **Network Link Conditioner**: Test with poor network conditions
- **Simulator Device Settings**: Test with different iOS versions

### Performance Monitoring
- **Memory Usage**: Monitor in Xcode Debug Navigator
- **Network Usage**: Check API call frequency and data size
- **UI Responsiveness**: Ensure 60fps scrolling in contact list

This quickstart provides a solid foundation for the Monica iOS Client MVP. The implementation follows constitutional principles of simplicity, security, and native iOS experience while providing a scalable architecture for future enhancements.