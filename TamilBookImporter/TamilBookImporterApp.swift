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
            HomeView()
//            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environment(\.colorScheme, .light)
        }
    }
    
//    let persistenceController = CoreDataManager.shared
//
//    var body: some Scene {
//        WindowGroup {
//            MainCategoryListView()
//                .environment(\.managedObjectContext, persistenceController.viewContext)
//        }
//    }
    
}
