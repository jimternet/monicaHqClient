import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case serverError(Int)
    case decodingError
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .unauthorized:
            return "Invalid API token or unauthorized access"
        case .serverError(let code):
            return "Server error (code: \(code))"
        case .decodingError:
            return "Failed to decode server response"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

class MonicaAPIClient {
    private let baseURL: String
    private let apiToken: String
    private let session: URLSession
    
    init(baseURL: String, apiToken: String) {
        self.baseURL = baseURL.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "/$", with: "")
        self.apiToken = apiToken
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
    }
    
    private func makeRequest(endpoint: String, method: String = "GET", body: Data? = nil) async throws -> Data {
        guard let url = URL(string: "\(baseURL)/api\(endpoint)") else {
            print("❌ Invalid URL: \(baseURL)/api\(endpoint)")
            throw APIError.invalidURL
        }
        
        print("🔗 Making request to: \(url.absoluteString)")
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if let body = body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            print("📡 Response status: \(httpResponse.statusCode)")
            
            switch httpResponse.statusCode {
            case 200...299:
                return data
            case 401:
                print("❌ Unauthorized - check your API token")
                throw APIError.unauthorized
            case 404:
                print("❌ 404 Not Found - check your API URL and endpoint")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Response: \(responseString)")
                }
                throw APIError.serverError(404)
            case 400...499:
                print("❌ Client error: \(httpResponse.statusCode)")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Response: \(responseString)")
                }
                throw APIError.serverError(httpResponse.statusCode)
            case 500...599:
                print("❌ Server error: \(httpResponse.statusCode)")
                throw APIError.serverError(httpResponse.statusCode)
            default:
                throw APIError.invalidResponse
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    func testConnection() async throws {
        // Try current API first
        do {
            _ = try await makeRequest(endpoint: "/me")
        } catch {
            // If that fails, try v1 endpoint
            print("⚠️ /me failed, trying /account endpoint...")
            _ = try await makeRequest(endpoint: "/account")
        }
    }
    
    func fetchContacts(page: Int = 1, limit: Int = 100) async throws -> ContactsResponse {
        let data = try await makeRequest(endpoint: "/contacts?page=\(page)&limit=\(limit)")
        
        print("📥 Fetching contacts - page: \(page), limit: \(limit)")
        
        // Print raw response for debugging
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Raw response preview: \(String(jsonString.prefix(500)))")
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            let response = try decoder.decode(ContactsResponse.self, from: data)
            print("✅ Decoded \(response.data.count) contacts")
            return response
        } catch {
            print("❌ Decoding error: \(error)")
            
            // Try to decode as a simple structure to see what we got
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                print("Response structure: \(json.keys)")
            }
            
            throw APIError.decodingError
        }
    }
    
    func fetchAllContacts() async throws -> [Contact] {
        var allContacts: [Contact] = []
        var currentPage = 1
        var hasMorePages = true
        
        print("🔄 Starting to fetch all contacts...")
        
        while hasMorePages {
            let response = try await fetchContacts(page: currentPage, limit: 100)
            allContacts.append(contentsOf: response.data)
            
            print("📊 Page \(currentPage): Got \(response.data.count) contacts (Total so far: \(allContacts.count))")
            
            if let meta = response.meta {
                hasMorePages = currentPage < meta.lastPage
                currentPage += 1
            } else {
                hasMorePages = false
            }
        }
        
        print("✅ Finished fetching. Total contacts: \(allContacts.count)")
        return allContacts
    }
    
    func createContact(_ contact: Contact) async throws -> Contact {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let body = try encoder.encode(contact)
        
        let data = try await makeRequest(endpoint: "/contacts", method: "POST", body: body)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(Contact.self, from: data)
    }
    
    func updateContact(_ contact: Contact) async throws -> Contact {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let body = try encoder.encode(contact)
        
        let data = try await makeRequest(endpoint: "/contacts/\(contact.id)", method: "PUT", body: body)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(Contact.self, from: data)
    }
    
    func deleteContact(id: Int) async throws {
        _ = try await makeRequest(endpoint: "/contacts/\(id)", method: "DELETE")
    }
}