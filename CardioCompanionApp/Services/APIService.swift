// CardioCompanionApp/Services/APIService.swift
import Foundation

class APIService {
    static let shared = APIService()
    private let baseURL = "http://localhost:3000"
    private var token: String?

    func login(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/users/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        print("🚀 Sending login request to: \(url)")
        print("📩 Request headers: \(request.allHTTPHeaderFields ?? [:])")

        let body: [String: String] = ["email": email, "password": password]
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
                let user = try JSONDecoder().decode(User.self, from: data)
                print("✅ Successfully decoded user: \(user)")
                self.token = user.token
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

        print("🚀 Sending register request to: \(url)")
        print("📩 Request headers: \(request.allHTTPHeaderFields ?? [:])")

        let body: [String: String] = ["email": email, "password": password, "name": name]
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
                let user = try JSONDecoder().decode(User.self, from: data)
                print("✅ Successfully decoded user: \(user)")
                self.token = user.token
                completion(.success(user))
            } catch {
                print("❌ Decoding error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }

    func registerWithApple(identityToken: String, user: AppleUser?, completion: @escaping (Result<User, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/users/register-apple")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        print("🚀 Sending Apple register request to: \(url)")
        print("📩 Request headers: \(request.allHTTPHeaderFields ?? [:])")

        let body: [String: Any] = [
            "identityToken": identityToken,
            "user": user?.toDictionary() ?? [:]
        ]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
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
                let user = try JSONDecoder().decode(User.self, from: data)
                print("✅ Successfully decoded user: \(user)")
                self.token = user.token
                completion(.success(user))
            } catch {
                print("❌ Decoding error: \(error)")
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
}






