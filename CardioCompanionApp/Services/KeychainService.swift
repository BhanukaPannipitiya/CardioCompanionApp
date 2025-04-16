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
}