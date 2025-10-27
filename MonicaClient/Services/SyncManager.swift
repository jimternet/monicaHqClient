import Foundation
import CoreData

class SyncManager {
    private let dataController: DataController
    private let authManager: AuthenticationManager
    
    init(dataController: DataController, authManager: AuthenticationManager) {
        self.dataController = dataController
        self.authManager = authManager
    }
    
    @MainActor
    func syncContacts() async throws {
        guard let apiClient = authManager.currentAPIClient else {
            throw APIError.unauthorized
        }
        
        let contacts = try await apiClient.fetchAllContacts()
        
        await dataController.importContacts(contacts)
    }
    
    @MainActor
    func syncSingleContact(id: Int) async throws {
        guard let apiClient = authManager.currentAPIClient else {
            throw APIError.unauthorized
        }
        
        let response = try await apiClient.fetchContacts(page: 1, limit: 1)
        if let contact = response.data.first(where: { $0.id == id }) {
            await dataController.importContacts([contact])
        }
    }
}