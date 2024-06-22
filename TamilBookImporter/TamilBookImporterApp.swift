//
//  TamilBookImporterApp.swift
//  TamilBookImporter
//
//  Created by Selvarajan on 22/06/24.
//

import SwiftUI

@main
struct TamilBookImporterApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear {
                    loadInitialDataIfNeeded()
                }
        }
    }
}
