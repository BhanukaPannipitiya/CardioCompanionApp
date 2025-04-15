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
