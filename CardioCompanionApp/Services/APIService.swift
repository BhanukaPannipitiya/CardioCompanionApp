import Foundation

class APIService {
    static let shared = APIService()
    
    // Use your computer's local IP address instead of localhost
    // You can find this by running 'ifconfig' in Terminal and looking for 'en0' or 'en1'
    // For example: "http://192.168.1.100:3000"
    private let baseURL = "http://192.168.8.185:3000" // Replace with your actual IP address
    
    private var token: String? {
        didSet {
            if let token = token {
                print("🔑 Token updated, saving to Keychain: \(token)")
                _ = KeychainService.shared.saveToken(token)
            } else {
                print("🔑 Token cleared, removing from Keychain")
                KeychainService.shared.deleteToken()
                KeychainService.shared.deleteUserId()
                AuthManager.shared.logout()
            }
        }
    }

    private init() {
        if let savedToken = KeychainService.shared.getToken() {
            print("🔑 Loaded token from Keychain: \(savedToken)")
            self.token = savedToken
            if let savedUserId = KeychainService.shared.getUserId() {
                print("👤 Loaded userId from Keychain: \(savedUserId)")
                AuthManager.shared.currentUserId = savedUserId
                AuthManager.shared.isAuthenticated = true
            }
        } else {
            print("🔑 No token found in Keychain")
        }
    }

    private func refreshToken(completion: @escaping (Bool) -> Void) {
        guard let refreshToken = KeychainService.shared.getRefreshToken() else {
            print("❌ No refresh token available")
            completion(false)
            return
        }
        
        let url = URL(string: "\(baseURL)/users/refresh-token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(refreshToken)", forHTTPHeaderField: "Authorization")
        
        print("🚀 Sending refresh token request to: \(url)")
        print("📝 Request headers: \(request.allHTTPHeaderFields ?? [:])")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("❌ Refresh token network error: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📥 Refresh token response status: \(httpResponse.statusCode)")
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("📥 Raw refresh token response: \(responseString)")
                }
                
                if httpResponse.statusCode == 200, let data = data,
                   let response = try? JSONDecoder().decode(TokenResponse.self, from: data) {
                    print("✅ Refresh token successful, new token: \(response.token)")
                    self?.token = response.token
                    KeychainService.shared.saveRefreshToken(response.refreshToken)
                    completion(true)
                } else {
                    print("❌ Refresh token failed with status: \(httpResponse.statusCode)")
                    completion(false)
                }
            }
        }.resume()
    }

    private func handleUnauthorizedError(completion: @escaping (Bool) -> Void) {
        print("⚠️ Handling unauthorized error, attempting token refresh")
        refreshToken { success in
            if !success {
                print("❌ Token refresh failed, clearing token")
                self.token = nil
            } else {
                print("✅ Token refresh succeeded")
            }
            completion(success)
        }
    }

    func addMedication(_ medication: Medication, completion: @escaping (Result<Medication, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/medications") else {
            let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            print("❌ Invalid URL: \(baseURL)/api/medications")
            completion(.failure(error))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("🔑 Using token: \(token)")
        } else {
            let error = NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "No authentication token"])
            print("❌ No authentication token available")
            completion(.failure(error))
            return
        }
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let requestBody = try encoder.encode(medication)
            request.httpBody = requestBody
            if let jsonString = String(data: requestBody, encoding: .utf8) {
                print("📤 Request body: \(jsonString)")
            } else {
                print("⚠️ Could not convert request body to string for logging")
            }
        } catch {
            print("❌ Failed to encode medication: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }
        
        print("🚀 Sending add medication request to: \(url)")
        print("📝 Request headers: \(request.allHTTPHeaderFields ?? [:])")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No HTTP response received"])
                print("❌ No HTTP response received")
                completion(.failure(error))
                return
            }
            
            print("📥 Response status: \(httpResponse.statusCode)")
            print("📥 Response headers: \(httpResponse.allHeaderFields)")
            
            guard let data = data else {
                let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                print("❌ No data received from server")
                completion(.failure(error))
                return
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 Raw response data: \(responseString)")
            } else {
                print("⚠️ Could not convert response data to string for logging")
            }
            
            do {
                let decoder = JSONDecoder()
                let dateFormatter = ISO8601DateFormatter()
                dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                decoder.dateDecodingStrategy = .custom { decoder in
                    let container = try decoder.singleValueContainer()
                    let dateString = try container.decode(String.self)
                    
                    if let date = dateFormatter.date(from: dateString) {
                        return date
                    }
                    
                    // Try alternative format without fractional seconds
                    dateFormatter.formatOptions = [.withInternetDateTime]
                    if let date = dateFormatter.date(from: dateString) {
                        return date
                    }
                    
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
                }
                let addedMedication = try decoder.decode(Medication.self, from: data)
                print("✅ Successfully decoded medication: \(addedMedication)")
                completion(.success(addedMedication))
            } catch {
                print("❌ Decoding error: \(error.localizedDescription)")
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .dataCorrupted(let context):
                        print("❌ Data corrupted: \(context.debugDescription)")
                    case .keyNotFound(let key, let context):
                        print("❌ Key '\(key)' not found: \(context.debugDescription)")
                    case .typeMismatch(let type, let context):
                        print("❌ Type mismatch for \(type): \(context.debugDescription)")
                    case .valueNotFound(let type, let context):
                        print("❌ Value not found for \(type): \(context.debugDescription)")
                    @unknown default:
                        print("❌ Unknown decoding error")
                    }
                }
                completion(.failure(error))
            }
        }.resume()
    }

    func fetchMedications(completion: @escaping (Result<[Medication], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/medications") else {
            let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            print("❌ Invalid URL: \(baseURL)/api/medications")
            completion(.failure(error))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("🔑 Using token: \(token)")
        } else {
            let error = NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "No authentication token"])
            print("❌ No authentication token available")
            completion(.failure(error))
            return
        }
        
        print("🚀 Sending fetch medications request to: \(url)")
        print("📝 Request headers: \(request.allHTTPHeaderFields ?? [:])")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No HTTP response received"])
                print("❌ No HTTP response received")
                completion(.failure(error))
                return
            }
            
            print("📥 Response status: \(httpResponse.statusCode)")
            print("📥 Response headers: \(httpResponse.allHeaderFields)")
            
            guard let data = data else {
                let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                print("❌ No data received from server")
                completion(.failure(error))
                return
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 Raw response data: \(responseString)")
            } else {
                print("⚠️ Could not convert response data to string for logging")
            }
            
            do {
                let decoder = JSONDecoder()
                let dateFormatter = ISO8601DateFormatter()
                dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                decoder.dateDecodingStrategy = .custom { decoder in
                    let container = try decoder.singleValueContainer()
                    let dateString = try container.decode(String.self)
                    
                    if let date = dateFormatter.date(from: dateString) {
                        return date
                    }
                    
                    // Try alternative format without fractional seconds
                    dateFormatter.formatOptions = [.withInternetDateTime]
                    if let date = dateFormatter.date(from: dateString) {
                        return date
                    }
                    
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
                }
                let medications = try decoder.decode([Medication].self, from: data)
                print("✅ Successfully decoded \(medications.count) medications")
                completion(.success(medications))
            } catch {
                print("❌ Decoding error: \(error.localizedDescription)")
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .dataCorrupted(let context):
                        print("❌ Data corrupted: \(context.debugDescription)")
                    case .keyNotFound(let key, let context):
                        print("❌ Key '\(key)' not found: \(context.debugDescription)")
                    case .typeMismatch(let type, let context):
                        print("❌ Type mismatch for \(type): \(context.debugDescription)")
                    case .valueNotFound(let type, let context):
                        print("❌ Value not found for \(type): \(context.debugDescription)")
                    @unknown default:
                        print("❌ Unknown decoding error")
                    }
                }
                completion(.failure(error))
            }
        }.resume()
    }

    func deleteMedication(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/medications/\(id)") else {
            let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            print("❌ Invalid URL: \(baseURL)/api/medications/\(id)")
            completion(.failure(error))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("🔑 Using token: \(token)")
        } else {
            let error = NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "No authentication token"])
            print("❌ No authentication token available")
            completion(.failure(error))
            return
        }
        
        print("🚀 Sending delete medication request to: \(url)")
        print("📝 Request headers: \(request.allHTTPHeaderFields ?? [:])")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No HTTP response received"])
                print("❌ No HTTP response received")
                completion(.failure(error))
                return
            }
            
            print("📥 Response status: \(httpResponse.statusCode)")
            print("📥 Response headers: \(httpResponse.allHeaderFields)")
            
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("📥 Raw response data: \(responseString)")
                
                // Try to decode error message from server
                if httpResponse.statusCode >= 400 {
                    do {
                        if let errorDict = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let errorMessage = errorDict["message"] as? String {
                            let error = NSError(domain: "", code: httpResponse.statusCode, 
                                              userInfo: [NSLocalizedDescriptionKey: "Server error: \(errorMessage)"])
                            print("❌ Server error: \(errorMessage)")
                            completion(.failure(error))
                            return
                        }
                    } catch {
                        print("⚠️ Could not decode error message from server")
                    }
                }
            } else {
                print("⚠️ No response data or could not convert to string")
            }
            
            if httpResponse.statusCode == 204 {
                print("✅ Successfully deleted medication with id: \(id)")
                completion(.success(()))
            } else {
                let errorMessage = "Failed to delete medication. Status: \(httpResponse.statusCode)"
                let error = NSError(domain: "", code: httpResponse.statusCode, 
                                  userInfo: [NSLocalizedDescriptionKey: errorMessage])
                print("❌ \(errorMessage)")
                completion(.failure(error))
            }
        }.resume()
    }

    func toggleMedicationTaken(id: String, scheduleTime: Date, isTaken: Bool, completion: @escaping (Result<Medication, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/medications/\(id)/toggle-taken") else {
            let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            print("❌ Invalid URL: \(baseURL)/api/medications/\(id)/toggle-taken")
            completion(.failure(error))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("🔑 Using token: \(token)")
        } else {
            let error = NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "No authentication token"])
            print("❌ No authentication token available")
            completion(.failure(error))
            return
        }
        
        let body: [String: Any] = [
            "scheduleTime": ISO8601DateFormatter().string(from: scheduleTime),
            "isTaken": isTaken
        ]
        
        do {
            let requestBody = try JSONSerialization.data(withJSONObject: body)
            request.httpBody = requestBody
            if let jsonString = String(data: requestBody, encoding: .utf8) {
                print("📤 Request body: \(jsonString)")
            } else {
                print("⚠️ Could not convert request body to string for logging")
            }
        } catch {
            print("❌ Failed to encode request body: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }
        
        print("🚀 Sending toggle medication taken request to: \(url)")
        print("📝 Request headers: \(request.allHTTPHeaderFields ?? [:])")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No HTTP response received"])
                print("❌ No HTTP response received")
                completion(.failure(error))
                return
            }
            
            print("📥 Response status: \(httpResponse.statusCode)")
            print("📥 Response headers: \(httpResponse.allHeaderFields)")
            
            guard let data = data else {
                let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                print("❌ No data received from server")
                completion(.failure(error))
                return
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 Raw response data: \(responseString)")
            } else {
                print("⚠️ Could not convert response data to string for logging")
            }
            
            do {
                let decoder = JSONDecoder()
                let dateFormatter = ISO8601DateFormatter()
                dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                decoder.dateDecodingStrategy = .custom { decoder in
                    let container = try decoder.singleValueContainer()
                    let dateString = try container.decode(String.self)
                    
                    if let date = dateFormatter.date(from: dateString) {
                        return date
                    }
                    
                    // Try alternative format without fractional seconds
                    dateFormatter.formatOptions = [.withInternetDateTime]
                    if let date = dateFormatter.date(from: dateString) {
                        return date
                    }
                    
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
                }
                let updatedMedication = try decoder.decode(Medication.self, from: data)
                print("✅ Successfully decoded updated medication: \(updatedMedication)")
                completion(.success(updatedMedication))
            } catch {
                print("❌ Decoding error: \(error.localizedDescription)")
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .dataCorrupted(let context):
                        print("❌ Data corrupted: \(context.debugDescription)")
                    case .keyNotFound(let key, let context):
                        print("❌ Key '\(key)' not found: \(context.debugDescription)")
                    case .typeMismatch(let type, let context):
                        print("❌ Type mismatch for \(type): \(context.debugDescription)")
                    case .valueNotFound(let type, let context):
                        print("❌ Value not found for \(type): \(context.debugDescription)")
                    @unknown default:
                        print("❌ Unknown decoding error")
                    }
                }
                completion(.failure(error))
            }
        }.resume()
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
                print("✅ Login successful, saving token and userId")
                self?.token = user.token
                _ = KeychainService.shared.saveUserId(user.id)
                AuthManager.shared.login(user: user)
                completion(.success(user))
            } catch {
                print("❌ Decoding error: \(error)")
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
                print("✅ Registration successful, saving token and userId")
                self?.token = user.token
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
                print("✅ Apple registration successful, saving token and userId")
                self?.token = user.token
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

        let body: [String: String] = ["email": email]
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
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
                let response = try JSONDecoder().decode(OTPResponse.self, from: data)
                completion(.success(response))
            } catch {
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
                completion(.failure(error))
                return
            }

            guard let data = data else {
                let noDataError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                completion(.failure(noDataError))
                return
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
                completion(.failure(error))
                return
            }

            guard let data = data else {
                let noDataError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                completion(.failure(noDataError))
                return
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
            let error = NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "No authentication token available"])
            completion(.failure(error))
            return
        }
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONEncoder().encode(symptomLog)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200...299:
                    completion(.success(()))
                case 401:
                    self?.handleUnauthorizedError { success in
                        if success {
                            self?.saveSymptomLog(symptomLog: symptomLog, completion: completion)
                        } else {
                            let error = NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Authentication failed"])
                            completion(.failure(error))
                        }
                    }
                default:
                    let error = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error occurred"])
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    func logout() {
        print("🔑 Logging out - Clearing token")
        token = nil
        AuthManager.shared.logout()
    }

    func fetchSymptomLogs(startDate: Date? = nil, endDate: Date? = nil, completion: @escaping (Result<[SymptomLog], Error>) -> Void) {
        var urlComponents = URLComponents(string: "\(baseURL)/api/symptoms")!
        
        if let startDate = startDate, let endDate = endDate {
            let dateFormatter = ISO8601DateFormatter()
            urlComponents.queryItems = [
                URLQueryItem(name: "startDate", value: dateFormatter.string(from: startDate)),
                URLQueryItem(name: "endDate", value: dateFormatter.string(from: endDate))
            ]
        }
        
        guard let url = urlComponents.url else {
            let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            completion(.failure(error))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let token = token else {
            let error = NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "No authentication token available"])
            completion(.failure(error))
            return
        }
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200...299:
                    guard let data = data else {
                        let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                        completion(.failure(error))
                        return
                    }
                    do {
                        let symptomLogs = try JSONDecoder().decode([SymptomLog].self, from: data)
                        completion(.success(symptomLogs))
                    } catch {
                        completion(.failure(error))
                    }
                case 401:
                    let error = NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Authentication failed"])
                    completion(.failure(error))
                default:
                    let error = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error occurred"])
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    func fetchUserProfile(completion: @escaping (Result<UserProfile, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/users/profile") else {
            let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            print("❌ Invalid URL: \(baseURL)/users/profile")
            completion(.failure(error))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let token = token else {
            let error = NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "No authentication token available"])
            print("❌ No authentication token available for fetchUserProfile")
            completion(.failure(error))
            return
        }
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        print("🚀 Sending fetch user profile request to: \(url)")
        print("📝 Request headers: \(request.allHTTPHeaderFields ?? [:])")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("❌ Network error in fetchUserProfile: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📥 Response status: \(httpResponse.statusCode)")
                print("📥 Response headers: \(httpResponse.allHeaderFields)")
                
                switch httpResponse.statusCode {
                case 200...299:
                    guard let data = data else {
                        let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                        print("❌ No data received in fetchUserProfile response")
                        completion(.failure(error))
                        return
                    }
                    
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("📥 Raw response data: \(responseString)")
                    } else {
                        print("⚠️ Could not convert response data to string for logging")
                    }
                    
                    do {
                        let profile = try JSONDecoder().decode(UserProfile.self, from: data)
                        print("✅ Successfully decoded user profile")
                        completion(.success(profile))
                    } catch {
                        print("❌ Decoding error in fetchUserProfile: \(error.localizedDescription)")
                        if let decodingError = error as? DecodingError {
                            switch decodingError {
                            case .dataCorrupted(let context):
                                print("❌ Data corrupted: \(context.debugDescription)")
                            case .keyNotFound(let key, let context):
                                print("❌ Key '\(key)' not found: \(context.debugDescription)")
                            case .typeMismatch(let type, let context):
                                print("❌ Type mismatch for \(type): \(context.debugDescription)")
                            case .valueNotFound(let type, let context):
                                print("❌ Value not found for \(type): \(context.debugDescription)")
                            @unknown default:
                                print("❌ Unknown decoding error")
                            }
                        }
                        completion(.failure(error))
                    }
                case 401:
                    print("⚠️ Authentication failed in fetchUserProfile, attempting token refresh")
                    self?.handleUnauthorizedError { success in
                        if success {
                            print("✅ Token refresh successful, retrying fetchUserProfile")
                            self?.fetchUserProfile(completion: completion)
                        } else {
                            let error = NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Authentication failed"])
                            print("❌ Token refresh failed in fetchUserProfile")
                            completion(.failure(error))
                        }
                    }
                default:
                    let error = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error occurred"])
                    print("❌ Server error in fetchUserProfile: Status \(httpResponse.statusCode)")
                    completion(.failure(error))
                }
            } else {
                let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No HTTP response received"])
                print("❌ No HTTP response received in fetchUserProfile")
                completion(.failure(error))
            }
        }.resume()
    }

    func updateUserProfile(profile: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/users/profile") else {
            let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            print("❌ Invalid URL: \(baseURL)/users/profile")
            completion(.failure(error))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let token = token else {
            let error = NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "No authentication token available"])
            print("❌ No authentication token available for updateUserProfile")
            completion(.failure(error))
            return
        }
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: profile)
            if let jsonString = String(data: request.httpBody!, encoding: .utf8) {
                print("📤 Request body: \(jsonString)")
            }
        } catch {
            print("❌ Failed to encode profile data: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }
        
        print("🚀 Sending update profile request to: \(url)")
        print("📝 Request headers: \(request.allHTTPHeaderFields ?? [:])")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("❌ Network error in updateUserProfile: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📥 Response status: \(httpResponse.statusCode)")
                print("📥 Response headers: \(httpResponse.allHeaderFields)")
                
                switch httpResponse.statusCode {
                case 200...299:
                    print("✅ Profile updated successfully")
                    completion(.success(()))
                case 401:
                    print("⚠️ Authentication failed in updateUserProfile, attempting token refresh")
                    self?.handleUnauthorizedError { success in
                        if success {
                            print("✅ Token refresh successful, retrying updateUserProfile")
                            self?.updateUserProfile(profile: profile, completion: completion)
                        } else {
                            let error = NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Authentication failed"])
                            print("❌ Token refresh failed in updateUserProfile")
                            completion(.failure(error))
                        }
                    }
                default:
                    let error = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error occurred"])
                    print("❌ Server error in updateUserProfile: Status \(httpResponse.statusCode)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    func getSymptomReports(userId: String, startDate: Date, endDate: Date) async throws -> [SymptomLog] {
        return try await withCheckedThrowingContinuation { continuation in
            fetchSymptomLogs(startDate: startDate, endDate: endDate) { result in
                switch result {
                case .success(let logs):
                    continuation.resume(returning: logs)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
