//
//  ForgotPasswordView.swift
//  CardioCompanionApp
//
//  Created by Bhanuka  Pannipitiya  on 2025-04-15.
//


// CardioCompanionApp/Views/Authentication/ForgotPasswordView.swift
import SwiftUI

struct ForgotPasswordView: View {
    @State private var email: String = ""
    @State private var message: String?
    @State private var errorMessage: String?
    @State private var navigateToOTP = false
    @State private var otpId: String?

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.red)
                .padding(.top, 40)

            Text("Forgot Password")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Enter your email to receive a verification code")
                .font(.subheadline)
                .foregroundColor(.gray)

            HStack {
                Image(systemName: "envelope.fill")
                    .foregroundColor(.gray)
                    .frame(width: 20)
                TextField("Email Address", text: $email)
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
            if let otpId = otpId {
                OTPVerificationView(email: email, otpId: otpId)
            }
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
                    print("✅ Success: \(response)")  // Debug log
                    self.message = response.message
                    self.errorMessage = nil
                    self.otpId = response.otpId
                    self.navigateToOTP = true
                case .failure(let error):
                    print("❌ Error: \(error.localizedDescription)")  // Debug log
                    self.errorMessage = error.localizedDescription
                    self.message = nil
                }
            }
        }
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
    }
}