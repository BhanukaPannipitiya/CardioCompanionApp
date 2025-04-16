import SwiftUI

struct ForgotPasswordView: View {
    @State private var email: String = ""
    @State private var message: String?
    @State private var errorMessage: String?
    @State private var navigateToOTP = false

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "key.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.blue)
                .padding(.top, 40)

            Text("Forgot Password")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Please enter your email to reset your password")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            TextField("Email", text: $email)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(.vertical, 10)
                .padding(.horizontal)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )

            if let message = message {
                Text(message)
                    .foregroundColor(.green)
                    .font(.caption)
            }

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Button(action: requestPasswordReset) {
                Text("Send Verification Code")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }

            NavigationLink(
                destination: LoginView(),
                label: {
                    Text("Back to Login")
                        .foregroundColor(.blue)
                }
            )

            Spacer()
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $navigateToOTP) {
            OTPVerificationView(email: email)
        }
    }

    private func requestPasswordReset() {
        guard !email.isEmpty else {
            errorMessage = "Please enter your email"
            return
        }
        
        APIService.shared.requestPasswordReset(email: email) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.message = response.message
                    self.errorMessage = nil
                    // Navigate to OTP view after a short delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        self.navigateToOTP = true
                    }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.message = nil
                }
            }
        }
    }
} 