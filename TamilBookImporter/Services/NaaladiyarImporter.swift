//
//  NaaladiyarImporter.swift
//  TamilBookImporter
//
//  Created by Selvarajan on 13/07/24.
//

import Foundation
import CoreData

class NaaladiyarImporter: BookImporter {
    var bookName: String = "நாலடியார்"
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
        book.color = "indigo"
        book.name = bookname
        book.noofpoems = Int16(noofpoems)
        book.order = 1
        book.period = period
        book.info = description
        book.poemType = "பாடல்"
        book.categoryLevel = 3
        
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
               let subcategories = category["subcategories"] as? [[String: Any]] {
                
                let mainCat = MainCategory(context: context)
                mainCat.id = UUID()
                mainCat.number = Int16(number)
                mainCat.start = 0
                mainCat.end = 0
                mainCat.title = name
                mainCat.groupname = "பால்"
                mainCat.bookname = bookName
                mainCat.book = book
                
                for subCategory in subcategories {
                    if let name = subCategory["subcategory"] as? String,
                       let number = subCategory["number"] as? Int,
                       let sections = subCategory["sections"] as? [[String: Any]] {
                        
                        let subCat = SubCategory(context: context)
                        subCat.id = UUID()
                        subCat.number = Int16(number)
                        subCat.start = 0
                        subCat.end = 0
                        subCat.title = name
                        subCat.groupname = "இயல்"
                        subCat.bookname = bookName
                        subCat.mainCategory = mainCat
                        
                        for section in sections {
                            if let name = section["section"] as? String,
                               let number = section["number"] as? Int,
                               let start = section["start"] as? Int,
                               let end = section["end"] as? Int {
                                
                                let sec = Section(context: context)
                                sec.id = UUID()
                                sec.number = Int16(number)
                                sec.start = Int16(start)
                                sec.end = Int16(end)
                                sec.title = name
                                sec.groupname = "அதிகாரம்"
                                sec.bookname = bookName
                                sec.subCategory = subCat
                            }
                        }
                    }
                }
                
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
            guard let number = poem["Number"] as? Int,
                  let _ = poem["Category"] as? String,
                  let _ = poem["SubCategory"] as? String,
                  let sectionName = poem["Section"] as? String,
                  let poemContent = poem["Poem"] as? String,
                  let explanation = poem["Meaning"] as? String else {
                continue
            }
            
            let poemEntity = Poem(context: context)
            poemEntity.id = UUID()
            poemEntity.number = Int16(number)
            poemEntity.poem = poemContent
            poemEntity.poeminfo = ""
            poemEntity.transliteration = ""
            poemEntity.bookname = bookName
            poemEntity.title = ""
            poemEntity.book = book
            
            //adding poem to the book
            book.poems?.adding(poemEntity)
            
            // Link poem to section
            if let bookName = book.name {
                let sectionFetchRequest: NSFetchRequest<Section> = Section.fetchRequest()
                sectionFetchRequest.predicate = NSPredicate(format: "title == %@ AND bookname == %@", sectionName, bookName)
                
                do {
                    let sections = try context.fetch(sectionFetchRequest)
                    if let section = sections.first {
                        poemEntity.setValue(section, forKey: "section")
                        poemEntity.sectionname = section.title ?? ""
                        if let subCat = section.subCategory, let mainCat = subCat.mainCategory {
                            poemEntity.subcategoryname = subCat.title ?? ""
                            poemEntity.maincategoryname = mainCat.title ?? ""
                        }
                    }
                } catch {
                    print("Failed to fetch sections: \(error)")
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
    
    func saveContext() {
        do {
            try context.save()
        } catch {
            fatalError("Failed to save \(bookName) data: \(error.localizedDescription)")
        }
    }
}
