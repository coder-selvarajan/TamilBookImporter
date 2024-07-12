//
//  ImportAthichudi.swift
//  TamilBookImporter
//
//  Created by Selvarajan on 03/07/24.
//

import Foundation
import CoreData

class AthichudiImporter: BookImporter {
    var bookName: String = "ஆத்திச்சூடி"
    var poemFile: String
    var categoryFile: String
    var book: Book
    
    var aboutBook: [String: Any] = [:]
    var categories: [[String: Any]] = []
    var poems: [[String: Any]] = []
    
    let context = PersistenceController.shared.container.viewContext
    
    internal init(poemFile: String, categoryFile: String) {
        self.categoryFile = categoryFile
        self.poemFile = poemFile
        book = Book(context: context)
        
        // importing json files content into local objects.
        loadPoemFile()
        loadCategoryFile()
    }
    
    private func loadPoemFile() {
        guard let url = Bundle.main.url(forResource: poemFile, withExtension: "json") else {
            fatalError("Failed to locate \(poemFile).json in app bundle.")
        }
        
        do {
            let data = try Data(contentsOf: url)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            
            if  let jsonDictionary = json as? [String: Any] {
                aboutBook = jsonDictionary["about"] as! [String: Any]
                poems = jsonDictionary["athichudi"] as! [[String: Any]]
            }
        } catch {
            fatalError("Failed to load json data: \(error.localizedDescription)")
        }
    }
    
    private func loadCategoryFile() {
        guard let url = Bundle.main.url(forResource: categoryFile, withExtension: "json") else {
            fatalError("Failed to locate \(categoryFile).json in app bundle.")
        }
        
        do {
            let data = try Data(contentsOf: url)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            
            if  let jsonDictionary = json as? [String: Any] {
                categories = jsonDictionary["categories"] as! [[String: Any]]
            }
        } catch {
            fatalError("Failed to load json data: \(error.localizedDescription)")
        }
    }
    
    func importBookInfo() -> Bool {
        
        guard let bookname = aboutBook["bookname"] as? String,
              let description = aboutBook["description"] as? String,
              let author = aboutBook["author"] as? String,
              let noofpoems = aboutBook["noofpoems"] as? Int,
              let period = aboutBook["period"] as? String else {
            return false
        }
        
        book.id = UUID()
        book.author = author
        book.color = "cyan"
        book.name = bookname
        book.noofpoems = Int16(noofpoems)
        book.order = 1
        book.period = period
        book.info = description
        book.poemType = "வாக்கியம்"
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
                  let poemContent = poem["poem"] as? String,
                  let meaning = poem["meaning"] as? String,
                  let paraphrase = poem["paraphrase"] as? String,
                  let translation = poem["translation"] as? String else {
                continue
            }
            
            let poemEntity = Poem(context: context)
            poemEntity.id = UUID()
            poemEntity.number = Int16(number)
            poemEntity.poem = poemContent
            poemEntity.poeminfo = ""
            poemEntity.transliteration = ""
            poemEntity.title = ""
            poemEntity.bookname = bookName
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
            expl1.title = "பதவுரை"
            expl1.meaning = meaning
            expl1.bookname = bookName
            
            let expl2 = Explanation(context: context)
            expl2.id = UUID()
            expl2.author = ""
            expl2.language = "Tamil"
            expl2.order = 2
            expl2.poem = poemEntity
            expl2.title = "பொழிப்புரை"
            expl2.meaning = paraphrase
            expl2.bookname = bookName
            
            let expl3 = Explanation(context: context)
            expl3.id = UUID()
            expl3.author = "Explanation"
            expl3.language = "English"
            expl3.order = 3
            expl3.poem = poemEntity
            expl3.title = "Explanation"
            expl3.meaning = translation
            expl3.bookname = bookName
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
