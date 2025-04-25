//
//  SignUpViewModel.swift
//  CardioCompanionApp
//
//  Created by Bhanuka  Pannipitiya  on 2025-04-15.
//


// CardioCompanionApp/ViewModels/SignUpViewModel.swift
import SwiftUI

class SignUpViewModel: ObservableObject {
    @Published var name: String = ""
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

    func signUp() {
        APIService.shared.register(email: email, password: password, name: name) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    print("Sign-up successful for user: \(user.email)")
                    self?.isAuthenticated = true
                    self?.errorMessage = nil
                case .failure(let error):
                    print("Sign-up failed: \(error.localizedDescription)")
                    self?.errorMessage = error.localizedDescription
                    self?.isAuthenticated = false
                }
            }
        }
    }

    func signUpWithApple(identityToken: String, user: AppleUser?) {
        print("📱 Starting Apple sign-up process")
        print("📱 Identity Token: \(identityToken)")
        print("📱 User Data: \(user?.toDictionary() ?? [:])")
        
        APIService.shared.registerWithApple(identityToken: identityToken, user: user) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    print("✅ Apple sign-up successful for user: \(user.email)")
                    self?.isAuthenticated = true
                    self?.errorMessage = nil
                case .failure(let error):
                    print("❌ Apple sign-up failed: \(error.localizedDescription)")
                    self?.errorMessage = error.localizedDescription
                    self?.isAuthenticated = false
                }
            }
        }
    }
}