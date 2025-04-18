// CardioCompanionApp/Views/Authentication/LoginView.swift
import SwiftUI
import LocalAuthentication

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @State private var isShowingPassword = false
    @State private var showBiometricError = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "heart.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.red)
                    .padding(.top, 40)

                Text("Welcome Back")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Sign in to continue your health journey")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(.gray)
                        .frame(width: 20)
                    TextField("Email Address", text: $viewModel.email)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(.vertical, 10)
                }
                .padding(.horizontal)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
                .padding(.horizontal)

                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.gray)
                        .frame(width: 20)
                    if isShowingPassword {
                        TextField("Password", text: $viewModel.password)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.vertical, 10)
                    } else {
                        SecureField("Password", text: $viewModel.password)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.vertical, 10)
                    }
                    Button(action: {
                        isShowingPassword.toggle()
                    }) {
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

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                Button(action: {
                    viewModel.login()
                }) {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }

                NavigationLink(
                    destination: ForgotPasswordView(),
                    label: {
                        Text("Forgot Password?")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                )

                Button(action: {
                    authenticateWithBiometrics()
                }) {
                    Image(systemName: "faceid")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.blue)
                        .padding()
                        .background(Circle().fill(Color.gray.opacity(0.1)))
                }
                .alert(isPresented: $showBiometricError) {
                    Alert(
                        title: Text("Biometric Authentication Failed"),
                        message: Text("Please use your email and password to log in."),
                        dismissButton: .default(Text("OK"))
                    )
                }

                NavigationLink(
                    destination: SignUpView(),
                    label: {
                        Text("Don't have an account? Sign Up")
                            .foregroundColor(.blue)
                    }
                )

                Spacer()
            }
            .padding(.top, 20)
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $viewModel.isAuthenticated) {
                DashboardView()
            }
        }
    }

    private func authenticateWithBiometrics() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate to access your health data"

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        // Retrieve credentials from Keychain
                        let credentials = KeychainService.shared.getCredentials()
                        if let email = credentials.email, let password = credentials.password {
                            viewModel.email = email
                            viewModel.password = password
                            viewModel.login()
                        } else {
                            showBiometricError = true
                            print("No credentials found in Keychain")
                        }
                    } else {
                        showBiometricError = true
                        print("Biometric authentication failed: \(authenticationError?.localizedDescription ?? "Unknown error")")
                    }
                }
            }
        } else {
            showBiometricError = true
            print("Biometric authentication not available: \(error?.localizedDescription ?? "Unknown error")")
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
