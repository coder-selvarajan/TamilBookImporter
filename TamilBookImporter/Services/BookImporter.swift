//
//  BookImporter.swift
//  TamilBookImporter
//
//  Created by Selvarajan on 03/07/24.
//

import Foundation
import CoreData

protocol BookImporter {
    var bookName: String { get set }
    var book: Book { get set }
    var poemFile: String { get set }
    var categoryFile: String { get set }
    
    func importBookInfo() -> Bool
    func importCategories() -> Bool
    func importPoems() -> Bool    
}

extension BookImporter {
    
    // import poems and book info from json file
    func loadPoemsFromJson(_ poemFile: String) -> ([String: Any], [[String: Any]]) {
        var aboutFromJson: [String: Any] = [:]
        var poemsFromJson: [[String: Any]] = []
        guard let url = Bundle.main.url(forResource: poemFile, withExtension: "json") else {
            fatalError("Failed to locate \(poemFile).json in app bundle.")
        }
        
        do {
            let data = try Data(contentsOf: url)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            
            if  let jsonDictionary = json as? [String: Any] {
                aboutFromJson = jsonDictionary["about"] as! [String: Any]
                poemsFromJson = jsonDictionary["poems"] as! [[String: Any]]
            }
        } catch {
            fatalError("Failed to load json data: \(error.localizedDescription)")
        }
        
        return (aboutFromJson, poemsFromJson)
    }
    
    // import categories from json file
    func loadCategoriesFromJson(_ categoryFile: String) -> [[String: Any]] {
        var categoriesFromJson : [[String: Any]] = []
        guard let url = Bundle.main.url(forResource: categoryFile, withExtension: "json") else {
            fatalError("Failed to locate \(categoryFile).json in app bundle.")
        }
        
        do {
            let data = try Data(contentsOf: url)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            
            if  let jsonDictionary = json as? [String: Any] {
                categoriesFromJson = jsonDictionary["categories"] as! [[String: Any]]
            }
        } catch {
            fatalError("Failed to load json data: \(error.localizedDescription)")
        }
        
        return categoriesFromJson
    }
    
    // fetch the count of records from the given entity
    private func getCount<T: NSFetchRequestResult>(for entity: T.Type) -> Int {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest = NSFetchRequest<T>(entityName: String(describing: entity))
        fetchRequest.predicate = NSPredicate(format: "bookname == %@", bookName)
        var count = 0

        do {
            count = try context.count(for: fetchRequest)
        } catch let error as NSError {
            print("Could not count items. \(error), \(error.userInfo)")
        }

        return count
    }
    
    func getExplanationCount() -> Int {
        return getCount(for: Explanation.self)
    }
    
    func getPoemCount() -> Int {
        return getCount(for: Poem.self)
    }
    
    func getSectionCount() -> Int {
        return getCount(for: Section.self)
    }
    
    func getSubCategoryCount() -> Int {
        return getCount(for: SubCategory.self)
    }
    
    func getMainCategoryCount() -> Int {
        return getCount(for: MainCategory.self)
    }
    
    func clearBookData() -> Bool {
        let context = PersistenceController.shared.container.viewContext
        
        // Predicate to filter by bookName
        let predicate = NSPredicate(format: "bookname == %@", bookName)
        
        // Fetch and delete requests for Explanation entity
        let fetchRequestExplanation: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Explanation")
        fetchRequestExplanation.predicate = predicate
        let deleteRequestExplanation = NSBatchDeleteRequest(fetchRequest: fetchRequestExplanation)
        
        // Fetch and delete requests for Poem entity
        let fetchRequestPoem: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Poem")
        fetchRequestPoem.predicate = predicate
        let deleteRequestPoem = NSBatchDeleteRequest(fetchRequest: fetchRequestPoem)
        
        // Fetch and delete requests for Section entity
        let fetchRequestSection: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Section")
        fetchRequestSection.predicate = predicate
        let deleteRequestSection = NSBatchDeleteRequest(fetchRequest: fetchRequestSection)
        
        // Fetch and delete requests for SubCategory entity
        let fetchRequestSubCategory: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "SubCategory")
        fetchRequestSubCategory.predicate = predicate
        let deleteRequestSubCategory = NSBatchDeleteRequest(fetchRequest: fetchRequestSubCategory)
        
        // Fetch and delete requests for MainCategory entity
        let fetchRequestMainCategory: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "MainCategory")
        fetchRequestMainCategory.predicate = predicate
        let deleteRequestMainCategory = NSBatchDeleteRequest(fetchRequest: fetchRequestMainCategory)
        
        // Fetch and delete requests for Book entity
        let fetchRequestBook: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Book")
        fetchRequestBook.predicate = NSPredicate(format: "name == %@", bookName)
        let deleteRequestBook = NSBatchDeleteRequest(fetchRequest: fetchRequestBook)
        
        do {
            try context.execute(deleteRequestExplanation)
            try context.execute(deleteRequestPoem)
            try context.execute(deleteRequestSection)
            try context.execute(deleteRequestSubCategory)
            try context.execute(deleteRequestMainCategory)
            try context.execute(deleteRequestBook)

            try context.save()
        } catch let error as NSError {
            print("Could not delete records for book name \(bookName). \(error), \(error.userInfo)")
            return false
        }
        
        print("Book(\(bookName)) data cleared")
        return true
    }
    
}


func clearAllData() -> Bool {
    let context = PersistenceController.shared.container.viewContext
    
    // Fetch and delete requests for Explanation entity
    let deleteRequestExplanation = NSBatchDeleteRequest(fetchRequest: NSFetchRequest(entityName: "Explanation"))
    
    // Fetch and delete requests for Poem entity
    let deleteRequestPoem = NSBatchDeleteRequest(fetchRequest: NSFetchRequest(entityName: "Poem"))
    
    // Fetch and delete requests for Section entity
    let deleteRequestSection = NSBatchDeleteRequest(fetchRequest: NSFetchRequest(entityName: "Section"))
    
    // Fetch and delete requests for SubCategory entity
    let deleteRequestSubCategory = NSBatchDeleteRequest(fetchRequest: NSFetchRequest(entityName: "SubCategory"))
    
    // Fetch and delete requests for MainCategory entity
    let deleteRequestMainCategory = NSBatchDeleteRequest(fetchRequest: NSFetchRequest(entityName: "MainCategory"))
    
    // Fetch and delete requests for Book entity
    let deleteRequestBook = NSBatchDeleteRequest(fetchRequest: NSFetchRequest(entityName: "Book"))
    
    do {
        try context.execute(deleteRequestExplanation)
        try context.execute(deleteRequestPoem)
        try context.execute(deleteRequestSection)
        try context.execute(deleteRequestSubCategory)
        try context.execute(deleteRequestMainCategory)
        try context.execute(deleteRequestBook)
        
        try context.save()
    } catch let error as NSError {
        print("Could not delete records. \(error), \(error.userInfo)")
        return false
    }
    
    print("Databsae cleared")
    return true
}
