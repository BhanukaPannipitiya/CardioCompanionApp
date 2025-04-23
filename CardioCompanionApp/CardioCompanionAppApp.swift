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
    @StateObject private var authManager = AuthManager.shared

    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                NavigationStack {
                    MainTabView()
                }
                .environmentObject(authManager)
            } else {
                LoginView()
                    .environmentObject(authManager)
            }
        }
    }
}
