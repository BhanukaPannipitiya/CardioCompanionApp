func verifyOTP(email: String, otp: String, completion: @escaping (Result<VerifyOTPResponse, Error>) -> Void) {
    let url = URL(string: "\(baseURL)/users/verify-otp")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let body: [String: String] = [
        "email": email,
        "otp": otp
    ]
    
    do {
        request.httpBody = try JSONEncoder().encode(body)
    } catch {
        completion(.failure(error))
        return
    }

    URLSession.shared.dataTask(with: request) { data, response, error in
        // ... standard error handling ...
        
        do {
            let response = try JSONDecoder().decode(VerifyOTPResponse.self, from: data)
            completion(.success(response))
        } catch {
            completion(.failure(error))
        }
    }.resume()
} 