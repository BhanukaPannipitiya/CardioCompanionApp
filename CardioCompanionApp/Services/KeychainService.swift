//
//  KeychainService.swift
//  CardioCompanionApp
//
//  Created by Bhanuka  Pannipitiya  on 2025-04-15.
//


// CardioCompanionApp/Services/KeychainService.swift
import Foundation
import Security

class KeychainService {
    static let shared = KeychainService()
    private let service = "com.example.CardioCompanionApp"

    func saveCredentials(email: String, password: String) -> Bool {
        // Delete existing credentials to avoid duplicates
        deleteCredentials()

        // Save email
        let emailQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.example.CardioCompanionApp",
            kSecAttrAccount as String: "email",
            kSecValueData as String: email.data(using: .utf8)!
        ]

        let emailStatus = SecItemAdd(emailQuery as CFDictionary, nil)
        guard emailStatus == errSecSuccess else {
            print("Failed to save email to Keychain: \(emailStatus)")
            return false
        }

        // Save password
        let passwordQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.example.CardioCompanionApp",
            kSecAttrAccount as String: "password",
            kSecValueData as String: password.data(using: .utf8)!
        ]

        let passwordStatus = SecItemAdd(passwordQuery as CFDictionary, nil)
        guard passwordStatus == errSecSuccess else {
            print("Failed to save password to Keychain: \(passwordStatus)")
            return false
        }

        return true
    }

    func getCredentials() -> (email: String?, password: String?) {
        // Retrieve email
        let emailQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.example.CardioCompanionApp",
            kSecAttrAccount as String: "email",
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: true
        ]

        var emailItem: CFTypeRef?
        let emailStatus = SecItemCopyMatching(emailQuery as CFDictionary, &emailItem)
        let email = emailStatus == errSecSuccess ? String(data: emailItem as! Data, encoding: .utf8) : nil

        // Retrieve password
        let passwordQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.example.CardioCompanionApp",
            kSecAttrAccount as String: "password",
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: true
        ]

        var passwordItem: CFTypeRef?
        let passwordStatus = SecItemCopyMatching(passwordQuery as CFDictionary, &passwordItem)
        let password = passwordStatus == errSecSuccess ? String(data: passwordItem as! Data, encoding: .utf8) : nil

        return (email, password)
    }

    func deleteCredentials() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.example.CardioCompanionApp"
        ]
        SecItemDelete(query as CFDictionary)
    }

    // Token management
    func saveToken(_ token: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "auth_token",
            kSecValueData as String: token.data(using: .utf8)!
        ]
        
        // Delete existing token first
        deleteToken()
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    func getToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "auth_token",
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess,
           let data = result as? Data,
           let token = String(data: data, encoding: .utf8) {
            return token
        }
        return nil
    }
    
    func deleteToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "auth_token"
        ]
        
        SecItemDelete(query as CFDictionary)
    }
    
    // User ID management
    func saveUserId(_ userId: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "user_id",
            kSecValueData as String: userId.data(using: .utf8)!
        ]
        
        // Delete existing userId first
        deleteUserId()
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    func getUserId() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "user_id",
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess,
           let data = result as? Data,
           let userId = String(data: data, encoding: .utf8) {
            return userId
        }
        return nil
    }
    
    func deleteUserId() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "user_id"
        ]
        
        SecItemDelete(query as CFDictionary)
    }
    
    // Refresh token management
    func saveRefreshToken(_ token: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "refresh_token",
            kSecValueData as String: token.data(using: .utf8)!
        ]
        
        // Delete existing refresh token first
        deleteRefreshToken()
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    func getRefreshToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "refresh_token",
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess,
           let data = result as? Data,
           let token = String(data: data, encoding: .utf8) {
            return token
        }
        return nil
    }
    
    func deleteRefreshToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "refresh_token"
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}