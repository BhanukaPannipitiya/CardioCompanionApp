//
//  CardioCompanionAppApp.swift
//  CardioCompanionApp
//
//  Created by Bhanuka  Pannipitiya  on 2025-04-15.
//

// CardioCompanionApp/CardioCompanionApp.swift
import SwiftUI

@main
struct CardioCompanionApp: App {
    @StateObject private var loginViewModel = LoginViewModel()

    var body: some Scene {
        WindowGroup {
            if loginViewModel.isAuthenticated {
                NavigationStack {
                    MainTabView()
                }
            } else {
                LoginView()
                    .environmentObject(loginViewModel)
            }
        }
    }
}
