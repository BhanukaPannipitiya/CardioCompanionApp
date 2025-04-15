// CardioCompanionApp/Views/Authentication/LoginView.swift
import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Welcome Back")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Sign in to continue your health journey")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                TextField("Email Address", text: $viewModel.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
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
                    destination: Text("Sign Up Screen"), // Replace with SignUpView later
                    label: {
                        Text("Don't have an account? Sign Up")
                            .foregroundColor(.blue)
                    }
                )

                Text("isAuthenticated: \(viewModel.isAuthenticated.description)")
                    .font(.caption)
                    .foregroundColor(.gray)

                Spacer()
            }
            .padding(.top, 50)
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $viewModel.isAuthenticated) {
                DashboardView()
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
