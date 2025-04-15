// CardioCompanionApp/Services/APIService.swift
import Foundation

class APIService {
    static let shared = APIService()
    private let baseURL = "http://localhost:3000"

    func login(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/users/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Log the request details
        print("🚀 Sending login request to: \(url)")
        print("📩 Request headers: \(request.allHTTPHeaderFields ?? [:])")

        let body: [String: String] = ["email": email, "password": password]
        do {
            request.httpBody = try JSONEncoder().encode(body)
            // Log the request body
            if let jsonString = String(data: request.httpBody!, encoding: .utf8) {
                print("📤 Request body: \(jsonString)")
            }
        } catch {
            print("❌ Failed to encode request body: \(error)")
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            // Check for network errors
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            // Log the HTTP response status
            if let httpResponse = response as? HTTPURLResponse {
                print("📥 HTTP Response Status: \(httpResponse.statusCode)")
                // Log response headers for debugging
                print("📥 Response headers: \(httpResponse.allHeaderFields)")
            }

            // Check if data is received
            guard let data = data else {
                let noDataError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                print("❌ No data received from server")
                completion(.failure(noDataError))
                return
            }

            // Log the raw response data as a string for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 Raw response data: \(responseString)")
            } else {
                print("❌ Could not convert response data to string")
            }

            // Decode the response
            do {
                let user = try JSONDecoder().decode(User.self, from: data)
                print("✅ Successfully decoded user: \(user)")
                completion(.success(user))
            } catch {
                print("❌ Decoding error: \(error)")
                // If decoding fails, log the expected structure for comparison
                print("Expected User struct: id (String), email (String), name (String), subscriptionStatus (String), token (String)")
                completion(.failure(error))
            }
        }.resume()
    }
}

