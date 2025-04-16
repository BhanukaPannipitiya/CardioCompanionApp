import SwiftUI

struct OTPVerificationView: View {
    let email: String
    let otpId: String
    @State private var otp: String = ""
    @State private var message: String?
    @State private var errorMessage: String?
    @State private var navigateToResetPassword = false
    @State private var resetToken: String?

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "key.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.blue)
                .padding(.top, 40)

            Text("Enter OTP")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Please enter the verification code sent to your email")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            HStack {
                Image(systemName: "number")
                    .foregroundColor(.gray)
                    .frame(width: 20)
                TextField("Enter OTP", text: $otp)
                    .keyboardType(.numberPad)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.vertical, 10)
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

            Button(action: verifyOTP) {
                Text("Verify OTP")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }

            Spacer()
        }
        .navigationDestination(isPresented: $navigateToResetPassword) {
            if let resetToken = resetToken {
                ResetPasswordView(resetToken: resetToken)
            }
        }
    }

    private func verifyOTP() {
        APIService.shared.verifyOTP(email: email, otp: otp, otpId: otpId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    message = response.message
                    errorMessage = nil
                    resetToken = response.resetToken
                    navigateToResetPassword = true
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    message = nil
                }
            }
        }
    }
} 