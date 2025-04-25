import Foundation

struct UserProfile: Codable, Equatable {
    let id: String
    let name: String
    let email: String
    let username: String?
    let firstName: String?
    let lastName: String?
    let address: String?
    let dateOfBirth: String?
    let postOpDay: Int?
    let streak: Int?
    let points: Int?
    let subscriptionStatus: String?
    let adherenceRate: Int?
    let recentSymptoms: [ProfileSymptomLog]?
    let createdAt: String?
    let lastLogin: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case address
        case dateOfBirth
        case postOpDay = "post_op_day"
        case streak
        case points
        case subscriptionStatus
        case adherenceRate
        case recentSymptoms
        case createdAt
        case lastLogin
    }
    
    static func == (lhs: UserProfile, rhs: UserProfile) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.email == rhs.email &&
               lhs.username == rhs.username &&
               lhs.firstName == rhs.firstName &&
               lhs.lastName == rhs.lastName &&
               lhs.address == rhs.address &&
               lhs.dateOfBirth == rhs.dateOfBirth &&
               lhs.postOpDay == rhs.postOpDay &&
               lhs.streak == rhs.streak &&
               lhs.points == rhs.points &&
               lhs.subscriptionStatus == rhs.subscriptionStatus &&
               lhs.adherenceRate == rhs.adherenceRate
    }
}

struct ProfileSymptomLog: Codable {
    let id: String
    let userId: String
    let timestamp: String
    let symptoms: [ProfileSymptom]
    let severityRatings: [String: Int]
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userId
        case timestamp
        case symptoms
        case severityRatings
        case createdAt
    }
}

struct ProfileSymptom: Codable {
    let name: String
    let isUrgent: Bool
    let id: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case isUrgent
        case id = "_id"
    }
} 