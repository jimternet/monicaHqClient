import Foundation
import CoreData

extension ContactEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ContactEntity> {
        return NSFetchRequest<ContactEntity>(entityName: "ContactEntity")
    }

    @NSManaged public var address: String?
    @NSManaged public var birthdate: Date?
    @NSManaged public var company: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var email: String?
    @NSManaged public var firstName: String?
    @NSManaged public var id: Int32
    @NSManaged public var jobTitle: String?
    @NSManaged public var lastName: String?
    @NSManaged public var lastSyncedAt: Date?
    @NSManaged public var nickname: String?
    @NSManaged public var notes: String?
    @NSManaged public var phone: String?
    @NSManaged public var updatedAt: Date?

}

extension ContactEntity : Identifiable {

}