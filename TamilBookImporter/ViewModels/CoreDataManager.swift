//
//  CoreDataManager.swift
//  TamilBookImporter
//
//  Created by Selvarajan on 30/06/24.
//

import CoreData
import Foundation

class CoreDataManager {
    static let shared = CoreDataManager()
    let persistentContainer: NSPersistentContainer

    private init() {
        persistentContainer = NSPersistentContainer(name: "TamilLitDB")
        persistentContainer.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
    }

    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func fetchMainCategories() -> [MainCategory] {
        let fetchRequest: NSFetchRequest<MainCategory> = MainCategory.fetchRequest()
        do {
            return try viewContext.fetch(fetchRequest)
        } catch {
            print("Error fetching main categories: \(error)")
            return []
        }
    }

    // Similarly, add functions to fetch SubCategory and Section if needed
}
