import SwiftUI

struct ResetPasswordView: View {
    let resetToken: String
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var message: String?
    @State private var errorMessage: String?
    @State private var isShowingPassword = false
    @State private var isShowingConfirmPassword = false
    @State private var navigateToLogin = false

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.rotation")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.blue)
                .padding(.top, 40)

            Text("Reset Password")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Enter your new password")
                .font(.subheadline)
                .foregroundColor(.gray)

            // New Password Field
            HStack {
                Image(systemName: "lock.fill")
                    .foregroundColor(.gray)
                    .frame(width: 20)
                if isShowingPassword {
                    TextField("New Password", text: $newPassword)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(.vertical, 10)
                } else {
                    SecureField("New Password", text: $newPassword)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(.vertical, 10)
                }
                Button(action: { isShowingPassword.toggle() }) {
                    Image(systemName: isShowingPassword ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
            )
            .padding(.horizontal)

            // Confirm Password Field
            HStack {
                Image(systemName: "lock.fill")
                    .foregroundColor(.gray)
                    .frame(width: 20)
                if isShowingConfirmPassword {
                    TextField("Confirm Password", text: $confirmPassword)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(.vertical, 10)
                } else {
                    SecureField("Confirm Password", text: $confirmPassword)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(.vertical, 10)
                }
                Button(action: { isShowingConfirmPassword.toggle() }) {
                    Image(systemName: isShowingConfirmPassword ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
            )
            .padding(.horizontal)

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

            Button(action: resetPassword) {
                Text("Reset Password")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }

            Spacer()
        }
        .navigationDestination(isPresented: $navigateToLogin) {
            LoginView()
        }
    }

    private func resetPassword() {
        guard newPassword == confirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }

        guard !newPassword.isEmpty else {
            errorMessage = "Password cannot be empty"
            return
        }

        APIService.shared.resetPassword(resetToken: resetToken, newPassword: newPassword) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    message = response.message
                    errorMessage = nil
                    // Navigate to login after a short delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        navigateToLogin = true
                    }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    message = nil
                }
            }
        }
    }
} 