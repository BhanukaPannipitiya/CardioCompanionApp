//
//  User.swift
//  CardioCompanionApp
//
//  Created by Bhanuka  Pannipitiya  on 2025-04-15.
//

// Models/User.swift
import Foundation

struct User: Codable, Identifiable {
    let id: String
    let email: String
    let name: String
    let subscriptionStatus: String
    let token: String
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
        case otpId = "otp_id"  
    }
}

struct VerifyOTPResponse: Codable {
    let message: String
    let resetToken: String
}

struct ResetPasswordResponse: Codable {
    let message: String
}
