import Foundation
import SwiftUI

@MainActor
class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var apiURL: String?
    
    private let keychainManager = KeychainManager()
    private var apiClient: MonicaAPIClient?
    
    init() {
        Task {
            await checkAuthenticationStatus()
        }
    }
    
    func checkAuthenticationStatus() async {
        if let credentials = keychainManager.getCredentials() {
            self.apiURL = credentials.apiURL
            self.apiClient = MonicaAPIClient(baseURL: credentials.apiURL, apiToken: credentials.apiToken)
            
            do {
                try await apiClient?.testConnection()
                self.isAuthenticated = true
            } catch {
                self.isAuthenticated = false
                keychainManager.deleteCredentials()
            }
        } else {
            self.isAuthenticated = false
        }
    }
    
    func authenticate(apiURL: String, apiToken: String) async throws {
        let client = MonicaAPIClient(baseURL: apiURL, apiToken: apiToken)
        
        try await client.testConnection()
        
        keychainManager.saveCredentials(apiURL: apiURL, apiToken: apiToken)
        
        self.apiURL = apiURL
        self.apiClient = client
        self.isAuthenticated = true
    }
    
    func logout() {
        keychainManager.deleteCredentials()
        self.apiURL = nil
        self.apiClient = nil
        self.isAuthenticated = false
    }
    
    var currentAPIClient: MonicaAPIClient? {
        return apiClient
    }
}