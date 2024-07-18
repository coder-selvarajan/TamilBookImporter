//
//  ThirikadukamImporter.swift
//  TamilBookImporter
//
//  Created by Selvarajan on 06/07/24.
//

import Foundation
import CoreData

class ThirikadukamImporter: BookImporter {
    var bookName: String = "திரிகடுகம்"
    var book: Book
    var poemFile: String = ""
    var categoryFile: String = ""

    var aboutBook: [String: Any] = [:]
    var categories: [[String: Any]] = []
    var poems: [[String: Any]] = []
    
    let context = PersistenceController.shared.container.viewContext
    
    init(poemFile: String, categoryFile: String) {
        self.categoryFile = categoryFile
        self.poemFile = poemFile
        book = Book(context: context)
        
        // importing categories from json
        if categoryFile != "" {
            categories = loadCategoriesFromJson(categoryFile)
        }
        
        // importing poems from json
        if poemFile != "" {
            let dataFromJson = loadPoemsFromJson(poemFile)
            aboutBook = dataFromJson.0
            poems = dataFromJson.1
        }
    }
    
    func importBookInfo() -> Bool {
        guard let bookname = aboutBook["bookname"] as? String,
              let author = aboutBook["author"] as? String,
              let _ = aboutBook["category"] as? String,
              let description = aboutBook["description"] as? String,
              let noofpoems = aboutBook["noofpoems"] as? Int,
              let period = aboutBook["period"] as? String else {
            return false
        }
        
        book.id = UUID()
        book.author = author
        book.color = "green"
        book.name = bookname
        book.noofpoems = Int16(noofpoems)
        book.order = 1
        book.period = period
        book.info = description
        book.poemType = "பாடல்"
        book.categoryLevel = 1
        
        saveContext()
        
        return true
    }
    
    func importCategories() -> Bool {
        if categories.count == 0 {
            return false
        }
        
        for category in categories {
            if let name = category["category"] as? String,
               let number = category["number"] as? Int,
               let start = category["start"] as? Int,
               let end = category["end"] as? Int {
                
                let mainCat = MainCategory(context: context)
                mainCat.id = UUID()
                mainCat.number = Int16(number)
                mainCat.start = Int16(start)
                mainCat.end = Int16(end)
                mainCat.title = name
                mainCat.groupname = ""
                mainCat.bookname = bookName
                mainCat.book = book
            }
        }
        
        saveContext()
        
        return true
    }
    
    func importPoems() -> Bool {
        if poems.count == 0 {
            return false
        }
        
        for poem in poems {
            guard let number = poem["number"] as? Int,
                  let categoryName = poem["category"] as? String,
                  let poemTitle = poem["title"] as? String,
                  let poemContent = poem["poem"] as? String,
                  let explanationHeader = poem["explanation_header"] as? String,
                  let explanation = poem["explanation"] as? String else {
                continue
            }
            
            let poemEntity = Poem(context: context)
            poemEntity.id = UUID()
            poemEntity.number = Int16(number)
            poemEntity.poem = poemContent
            poemEntity.poeminfo = ""
            poemEntity.transliteration = ""
            poemEntity.bookname = bookName
            poemEntity.type = ""
            poemEntity.title = poemTitle
            poemEntity.book = book
            
            //adding poem to the book
            book.poems?.adding(poemEntity)
            
            // Link poem to MainCategory
            if let bookName = book.name {
                let categoryFetchRequest: NSFetchRequest<MainCategory> = MainCategory.fetchRequest()
                categoryFetchRequest.predicate = NSPredicate(format: "title == %@ AND bookname == %@",
                                                             categoryName, bookName)

                do {
                    let categories = try context.fetch(categoryFetchRequest)
                    if let category = categories.first {
                        poemEntity.setValue(category, forKey: "mainCategory")
                        poemEntity.maincategoryname = category.title ?? ""
                    }
                } catch {
                    print("Failed to fetch categories: \(error)")
                }
            }
            
            //Importing explanations
            let expl1 = Explanation(context: context)
            expl1.id = UUID()
            expl1.author = ""
            expl1.language = "Tamil"
            expl1.order = 1
            expl1.poem = poemEntity
            expl1.title = "விளக்கம்"
            expl1.meaning = explanation
            expl1.bookname = bookName
        }
        
        //Save poems and explanations into Core data
        saveContext()
        
        return true
    }
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            fatalError("Failed to save \(bookName) data: \(error.localizedDescription)")
        }
    }
}
