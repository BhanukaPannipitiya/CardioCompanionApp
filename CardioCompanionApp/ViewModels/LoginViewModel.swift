// CardioCompanionApp/ViewModels/LoginViewModel.swift
import SwiftUI

class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String?
    @Published var isAuthenticated: Bool {
        didSet {
            UserDefaults.standard.set(isAuthenticated, forKey: "isAuthenticated")
        }
    }

    init() {
        self.isAuthenticated = UserDefaults.standard.bool(forKey: "isAuthenticated")
        // Load credentials from Keychain on init
        let credentials = KeychainService.shared.getCredentials()
        if let savedEmail = credentials.email, let savedPassword = credentials.password {
            self.email = savedEmail
            self.password = savedPassword
        }
    }

    func login() {
        APIService.shared.login(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    print("Login successful for user: \(user.email)")
                    // Save credentials to Keychain
                    let saved = KeychainService.shared.saveCredentials(email: self?.email ?? "", password: self?.password ?? "")
                    print("Credentials saved to Keychain: \(saved)")
                    self?.isAuthenticated = true
                    self?.errorMessage = nil
                case .failure(let error):
                    print("Login failed: \(error.localizedDescription)")
                    self?.errorMessage = error.localizedDescription
                    self?.isAuthenticated = false
                }
            }
        }
    }
}
