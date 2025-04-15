//
//  CardioCompanionAppApp.swift
//  CardioCompanionApp
//
//  Created by Bhanuka  Pannipitiya  on 2025-04-15.
//

import SwiftUI

@main
struct CardioCompanionAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
