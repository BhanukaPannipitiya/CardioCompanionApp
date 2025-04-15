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
    }

    func login() {
        APIService.shared.login(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    print("Login successful for user: \(user.email)")
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
