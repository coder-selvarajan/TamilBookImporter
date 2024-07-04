//
//  BookImporter.swift
//  TamilBookImporter
//
//  Created by Selvarajan on 03/07/24.
//

import Foundation
import CoreData

protocol BookImporter {
    var book: Book { get set }
    var poemFile: String { get set }
    var categoryFile: String { get set }
    
    func importBookInfo() -> Bool
    func importCategories() -> Bool
    func importPoems() -> Bool
    func clearBookData() -> Bool
    func getPoemCount() -> Int
}

extension BookImporter {
    func clearData(for bookName: String, context: NSManagedObjectContext) -> Bool {
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
