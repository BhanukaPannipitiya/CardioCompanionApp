// CardioCompanionApp/Services/APIService.swift
import Foundation

class APIService {
    static let shared = APIService()
    private let baseURL = "http://localhost:3000"
    private var token: String? {
        didSet {
            if let token = token {
                print("Token updated, saving to Keychain")
                _ = KeychainService.shared.saveToken(token)
            } else {
                print("Token cleared, removing from Keychain")
                KeychainService.shared.deleteToken()
                // Also clear userId when token is cleared
                KeychainService.shared.deleteUserId()
                AuthManager.shared.logout()
            }
        }
    }

    private init() {
        // Load token from Keychain on init
        if let savedToken = KeychainService.shared.getToken() {
            print("Loaded token from Keychain")
            self.token = savedToken
            // Also load userId from Keychain
            if let savedUserId = KeychainService.shared.getUserId() {
                print("Loaded userId from Keychain: \(savedUserId)")
                AuthManager.shared.currentUserId = savedUserId
                AuthManager.shared.isAuthenticated = true
            }
        } else {
            print("No token found in Keychain")
        }
    }

    private func refreshToken(completion: @escaping (Bool) -> Void) {
        guard let refreshToken = KeychainService.shared.getRefreshToken() else {
            completion(false)
            return
        }
        
        let url = URL(string: "\(baseURL)/users/refresh-token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(refreshToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200,
               let data = data,
               let response = try? JSONDecoder().decode(TokenResponse.self, from: data) {
                self?.token = response.token
                KeychainService.shared.saveRefreshToken(response.refreshToken)
                completion(true)
            } else {
                completion(false)
            }
        }.resume()
    }

    private func handleUnauthorizedError(completion: @escaping (Bool) -> Void) {
        refreshToken { success in
            if !success {
                self.token = nil
            }
            completion(success)
        }
    }

    func login(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/users/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = ["email": email, "password": password]
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                let noDataError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                completion(.failure(noDataError))
                return
            }

            do {
                let user = try JSONDecoder().decode(User.self, from: data)
                print("Login successful, saving token and userId")
                self?.token = user.token
                // Save userId to Keychain
                _ = KeychainService.shared.saveUserId(user.id)
                AuthManager.shared.login(user: user)
                completion(.success(user))
            } catch {
                print("❌ Decoding error: \(error)")
                print("Expected User struct: id (String), email (String), name (String), subscriptionStatus (String), token (String)")
                completion(.failure(error))
            }
        }.resume()
    }

    func register(email: String, password: String, name: String, completion: @escaping (Result<User, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/users/register")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = ["email": email, "password": password, "name": name]
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                let noDataError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                completion(.failure(noDataError))
                return
            }

            do {
                let user = try JSONDecoder().decode(User.self, from: data)
                print("Registration successful, saving token and userId")
                self?.token = user.token
                // Save userId to Keychain
                _ = KeychainService.shared.saveUserId(user.id)
                AuthManager.shared.login(user: user)
                completion(.success(user))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func registerWithApple(identityToken: String, user: AppleUser?, completion: @escaping (Result<User, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/users/register-apple")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "identityToken": identityToken,
            "user": user?.toDictionary() ?? [:]
        ]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                let noDataError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                completion(.failure(noDataError))
                return
            }

            do {
                let user = try JSONDecoder().decode(User.self, from: data)
                print("Apple registration successful, saving token and userId")
                self?.token = user.token
                // Save userId to Keychain
                _ = KeychainService.shared.saveUserId(user.id)
                AuthManager.shared.login(user: user)
                completion(.success(user))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func requestPasswordReset(email: String, completion: @escaping (Result<OTPResponse, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/users/request-password-reset")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        print("🚀 Sending password reset request to: \(url)")
        print("📩 Request headers: \(request.allHTTPHeaderFields ?? [:])")

        let body: [String: String] = ["email": email]
        do {
            request.httpBody = try JSONEncoder().encode(body)
            if let jsonString = String(data: request.httpBody!, encoding: .utf8) {
                print("📤 Request body: \(jsonString)")
            }
        } catch {
            print("❌ Failed to encode request body: \(error)")
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("📥 HTTP Response Status: \(httpResponse.statusCode)")
                print("📥 Response headers: \(httpResponse.allHeaderFields)")
            }

            guard let data = data else {
                let noDataError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                print("❌ No data received from server")
                completion(.failure(noDataError))
                return
            }

            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 Raw response data: \(responseString)")
            }

            do {
                // Try to decode as a dictionary first to see what we're getting
                if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("📥 Decoded JSON response: \(jsonResponse)")
                }
                
                let response = try JSONDecoder().decode(OTPResponse.self, from: data)
                print("✅ Successfully decoded OTP response: \(response)")
                completion(.success(response))
            } catch {
                print("❌ Decoding error: \(error)")
                print("❌ Error description: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }.resume()
    }

    func verifyOTP(email: String, otp: String, otpId: String, completion: @escaping (Result<VerifyOTPResponse, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/users/verify-otp")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = [
            "email": email,
            "otp": otp,
            "otpId": otpId
        ]
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("📥 HTTP Response Status: \(httpResponse.statusCode)")
                print("📥 Response headers: \(httpResponse.allHeaderFields)")
            }

            guard let data = data else {
                let noDataError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                print("❌ No data received from server")
                completion(.failure(noDataError))
                return
            }

            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 Raw response data: \(responseString)")
            }

            do {
                let response = try JSONDecoder().decode(VerifyOTPResponse.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func resetPassword(resetToken: String, newPassword: String, completion: @escaping (Result<ResetPasswordResponse, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/users/reset-password")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = [
            "resetToken": resetToken,
            "newPassword": newPassword
        ]
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("📥 HTTP Response Status: \(httpResponse.statusCode)")
                print("📥 Response headers: \(httpResponse.allHeaderFields)")
            }

            guard let data = data else {
                let noDataError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                print("❌ No data received from server")
                completion(.failure(noDataError))
                return
            }

            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 Raw response data: \(responseString)")
            }

            do {
                let response = try JSONDecoder().decode(ResetPasswordResponse.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func saveSymptomLog(symptomLog: SymptomLog, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/api/symptoms")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let token = token else {
            print("❌ No token available for symptom save")
            let error = NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "No authentication token available"])
            completion(.failure(error))
            return
        }
        
        // Debug information
        print("🔑 Current token: \(token)")
        if let userId = AuthManager.shared.currentUserId {
            print("👤 Current userId: \(userId)")
        } else {
            print("⚠️ No userId found in AuthManager")
        }
        if let refreshToken = KeychainService.shared.getRefreshToken() {
            print("🔄 Refresh token available")
        } else {
            print("⚠️ No refresh token available")
        }
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONEncoder().encode(symptomLog)
            if let jsonString = String(data: request.httpBody!, encoding: .utf8) {
                print("📤 Request body: \(jsonString)")
            }
        } catch {
            print("❌ Failed to encode symptom log: \(error)")
            completion(.failure(error))
            return
        }
        
        print("🚀 Sending symptom save request to: \(url)")
        print("📝 Request headers: \(request.allHTTPHeaderFields ?? [:])")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📥 HTTP Response Status: \(httpResponse.statusCode)")
                print("📥 Response headers: \(httpResponse.allHeaderFields)")
                
                switch httpResponse.statusCode {
                case 200...299:
                    print("✅ Symptom saved successfully")
                    completion(.success(()))
                case 401:
                    print("⚠️ Unauthorized (401) response received")
                    print("🔍 Checking refresh token availability...")
                    
                    if let refreshToken = KeychainService.shared.getRefreshToken() {
                        print("🔄 Attempting token refresh...")
                        self?.handleUnauthorizedError { success in
                            if success {
                                print("✅ Token refresh successful, retrying request")
                                self?.saveSymptomLog(symptomLog: symptomLog, completion: completion)
                            } else {
                                print("❌ Token refresh failed")
                                let error = NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Authentication failed"])
                                completion(.failure(error))
                            }
                        }
                    } else {
                        print("❌ No refresh token available")
                        let error = NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Authentication failed"])
                        completion(.failure(error))
                    }
                default:
                    if let data = data,
                       let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                        print("❌ Server error: \(errorResponse.message)")
                        let error = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorResponse.message])
                        completion(.failure(error))
                    } else {
                        print("❌ Unknown error occurred")
                        let error = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred"])
                        completion(.failure(error))
                    }
                }
            }
            
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("📥 Raw response data: \(responseString)")
            }
        }.resume()
    }

    func logout() {
        print("🔑 Logging out - Clearing token")
        token = nil
        AuthManager.shared.logout()
    }
}






