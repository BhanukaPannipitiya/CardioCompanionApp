//
//  User.swift
//  CardioCompanionApp
//
//  Created by Bhanuka  Pannipitiya  on 2025-04-15.
//

// Models/User.swift
import Foundation

struct User: Identifiable, Codable {
    let id: String
    let email: String
    let name: String
    let subscriptionStatus: SubscriptionStatus
    let token: String // Added token to match backend response
    // Custom description for better debugging
        var description: String {
            return "User(id: \(id), email: \(email), name: \(name), subscriptionStatus: \(subscriptionStatus.rawValue), token: \(token))"
        }
}

enum SubscriptionStatus: String, Codable {
    case free
    case premium
}


struct AppleUser: Codable {
    let name: String?
    let email: String?

    func toDictionary() -> [String: String?] {
        return [
            "name": name,
            "email": email
        ]
    }
}

struct PasswordResetResponse: Codable {
    let message: String
}

struct OTPResponse: Codable {
    let message: String
    let otpId: String
    
    enum CodingKeys: String, CodingKey {
        case message
        case otpId = "otp_id"  // In case the API uses snake_case
    }
}

struct VerifyOTPResponse: Codable {
    let message: String
    let resetToken: String
}

struct ResetPasswordResponse: Codable {
    let message: String
}
