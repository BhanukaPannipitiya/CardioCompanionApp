// CardioCompanionApp/Views/Authentication/SignUpView.swift
import SwiftUI
import AuthenticationServices

struct SignUpView: View {
    @StateObject private var viewModel = SignUpViewModel()
    @State private var isShowingPassword = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "heart.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.red)
                    .padding(.top, 40)

                Text("Create Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Join CardioCompanion today!")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(.gray)
                        .frame(width: 20)
                    TextField("Full Name", text: $viewModel.name)
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
                    viewModel.signUp()
                }) {
                    Text("Sign Up")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }

                SignInWithAppleButton(
                    .signUp,
                    onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    },
                    onCompletion: { result in
                        switch result {
                        case .success(let authorization):
                            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                                let userID = appleIDCredential.user
                                let fullName = appleIDCredential.fullName
                                let email = appleIDCredential.email
                                
                                // Create a name string, handling potential nil values
                                var name = ""
                                if let givenName = fullName?.givenName {
                                    name += givenName
                                }
                                if let familyName = fullName?.familyName {
                                    if !name.isEmpty {
                                        name += " "
                                    }
                                    name += familyName
                                }
                                
                                // If name is empty, use a default name
                                if name.isEmpty {
                                    name = "Apple User"
                                }
                                
                                print("📱 Apple Sign In - UserID: \(userID)")
                                print("📱 Apple Sign In - Name: \(name)")
                                print("📱 Apple Sign In - Email: \(email ?? "No email provided")")
                                
                                if let identityTokenData = appleIDCredential.identityToken,
                                   let identityToken = String(data: identityTokenData, encoding: .utf8) {
                                    let appleUser = AppleUser(name: name, email: email)
                                    viewModel.signUpWithApple(identityToken: identityToken, user: appleUser)
                                } else {
                                    print("❌ Failed to get Apple identity token")
                                    viewModel.errorMessage = "Failed to get Apple identity token"
                                }
                            } else {
                                print("❌ Failed to get Apple ID credential")
                                viewModel.errorMessage = "Failed to get Apple ID credential"
                            }
                        case .failure(let error):
                            print("❌ Sign in with Apple failed: \(error.localizedDescription)")
                            viewModel.errorMessage = error.localizedDescription
                        }
                    }
                )
                .frame(height: 50)
                .cornerRadius(10)
                .padding(.horizontal)

                NavigationLink(
                    destination: LoginView(),
                    label: {
                        Text("Already have an account? Sign In")
                            .foregroundColor(.blue)
                    }
                )

                Spacer()
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $viewModel.isAuthenticated) {
                DashboardView()
            }
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
