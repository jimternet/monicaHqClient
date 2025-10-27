import Foundation

struct Contact: Codable, Identifiable {
    let id: Int
    let firstName: String?
    let lastName: String?
    let nickname: String?
    let email: String?
    let phone: String?
    let birthdate: Date?
    let address: String?
    let company: String?
    let jobTitle: String?
    let notes: String?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case nickname
        case email
        case phone
        case birthdate
        case address
        case company
        case jobTitle = "job_title"
        case notes
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct ContactsResponse: Codable {
    let data: [Contact]
    let links: PaginationLinks?
    let meta: PaginationMeta?
}

struct PaginationLinks: Codable {
    let first: String?
    let last: String?
    let prev: String?
    let next: String?
}

struct PaginationMeta: Codable {
    let currentPage: Int
    let from: Int?
    let lastPage: Int
    let perPage: Int
    let to: Int?
    let total: Int
    
    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case from
        case lastPage = "last_page"
        case perPage = "per_page"
        case to
        case total
    }
}