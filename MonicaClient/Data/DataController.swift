import CoreData
import Foundation

@MainActor
class DataController: ObservableObject {
    let container: NSPersistentContainer
    let authManager: AuthenticationManager
    @Published var isLoaded = false
    
    lazy var syncManager: SyncManager = {
        return SyncManager(dataController: self, authManager: self.authManager)
    }()
    
    init(authManager: AuthenticationManager) {
        self.authManager = authManager
        
        // Create model programmatically since file loading is failing
        let model = NSManagedObjectModel()
        
        // Create ContactEntity
        let contactEntity = NSEntityDescription()
        contactEntity.name = "ContactEntity"
        contactEntity.managedObjectClassName = "ContactEntity"
        
        // Add attributes
        let attributes: [(String, NSAttributeType, Bool)] = [
            ("id", .integer32AttributeType, false),
            ("firstName", .stringAttributeType, true),
            ("lastName", .stringAttributeType, true),
            ("nickname", .stringAttributeType, true),
            ("email", .stringAttributeType, true),
            ("phone", .stringAttributeType, true),
            ("address", .stringAttributeType, true),
            ("company", .stringAttributeType, true),
            ("jobTitle", .stringAttributeType, true),
            ("notes", .stringAttributeType, true),
            ("birthdate", .dateAttributeType, true),
            ("createdAt", .dateAttributeType, true),
            ("updatedAt", .dateAttributeType, true),
            ("lastSyncedAt", .dateAttributeType, true)
        ]
        
        for (name, type, isOptional) in attributes {
            let attribute = NSAttributeDescription()
            attribute.name = name
            attribute.attributeType = type
            attribute.isOptional = isOptional
            contactEntity.properties.append(attribute)
        }
        
        model.entities = [contactEntity]
        
        // Initialize container with programmatic model
        self.container = NSPersistentContainer(name: "MonicaClient", managedObjectModel: model)
        
        // Use in-memory store
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { [weak self] description, error in
            if let error = error {
                print("❌ Core Data failed to load: \(error.localizedDescription)")
            } else {
                print("✅ Core Data loaded with programmatic model")
                print("Store type: \(description.type)")
            }
            DispatchQueue.main.async {
                self?.isLoaded = true
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        print("✅ DataController initialized with programmatic model")
    }
    
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error)")
            }
        }
    }
    
    func importContacts(_ contacts: [Contact]) async {
        let context = container.viewContext
        
        print("💾 Importing \(contacts.count) contacts to Core Data...")
        
        for contact in contacts {
            let fetchRequest: NSFetchRequest<ContactEntity> = ContactEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %d", contact.id)
            
            do {
                let results = try context.fetch(fetchRequest)
                let entity = results.first ?? ContactEntity(context: context)
                
                entity.id = Int32(contact.id)
                entity.firstName = contact.firstName
                entity.lastName = contact.lastName
                entity.nickname = contact.nickname
                entity.email = contact.email
                entity.phone = contact.phone
                entity.birthdate = contact.birthdate
                entity.address = contact.address
                entity.company = contact.company
                entity.jobTitle = contact.jobTitle
                entity.notes = contact.notes
                entity.createdAt = contact.createdAt
                entity.updatedAt = contact.updatedAt
                entity.lastSyncedAt = Date()
                
                print("   ✅ Imported: \(contact.firstName ?? "") \(contact.lastName ?? "")")
                
            } catch {
                print("   ❌ Failed to import contact \(contact.id): \(error)")
            }
        }
        
        save()
        print("💾 Core Data save completed")
    }
    
    func deleteContact(_ contact: ContactEntity) {
        container.viewContext.delete(contact)
        save()
    }
    
    func clearAllData() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = ContactEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try container.viewContext.execute(deleteRequest)
            save()
        } catch {
            print("Failed to clear data: \(error)")
        }
    }
}