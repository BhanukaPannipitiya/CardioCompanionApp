import Foundation
import SwiftUI

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    @Published var isAuthenticated: Bool {
        didSet {
            UserDefaults.standard.set(isAuthenticated, forKey: "isAuthenticated")
        }
    }
    @Published var currentUserId: String? {
        didSet {
            UserDefaults.standard.set(currentUserId, forKey: "currentUserId")
        }
    }
    
    private init() {
        self.isAuthenticated = UserDefaults.standard.bool(forKey: "isAuthenticated")
        self.currentUserId = UserDefaults.standard.string(forKey: "currentUserId")
        print(" AuthManager initialized - isAuthenticated: \(isAuthenticated), userId: \(currentUserId ?? "nil")")
    }
    
    func login(userId: String) {
        isAuthenticated = true
        currentUserId = userId
        print("User logged in - userId: \(userId)")
    }
    
    func login(user: User) {
        isAuthenticated = true
        currentUserId = user.id
        print("User logged in - userId: \(user.id ?? "nil")")
    }
    
    func logout() {
        isAuthenticated = false
        currentUserId = nil
        print(" User logged out")
    }
} 
