import Foundation

struct LoginResponse: Codable {
    let token: String
    let refreshToken: String
    let user: User
}

struct TokenResponse: Codable {
    let token: String
    let refreshToken: String
}

struct ErrorResponse: Codable {
    let message: String
    let code: Int?
    
    enum CodingKeys: String, CodingKey {
        case message
        case code
    }
} 