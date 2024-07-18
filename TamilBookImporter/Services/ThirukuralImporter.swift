//
//  ImportThirukural.swift
//  TamilBookImporter
//
//  Created by Selvarajan on 22/06/24.
//

import Foundation
import CoreData
import SwiftUI

class ThirukuralImporter: BookImporter {
    var bookName: String = "திருக்குறள்"
    var book: Book
    var poemFile: String
    var categoryFile: String
    
    var aboutBook: [String: Any] = [:]
    var categories: [[String: Any]] = []
    var poems: [[String: Any]] = []
    
    let context = PersistenceController.shared.container.viewContext
    
    internal init(poemFile: String, categoryFile: String) {
        self.categoryFile = categoryFile
        self.poemFile = poemFile
        book = Book(context: context)
        
        // importing json files content into local objects.
        loadThirukural()
    }
    
    // Function to load the initial data
    func loadThirukural() {
        guard let url = Bundle.main.url(forResource: poemFile, withExtension: "json") else {
            fatalError("Failed to locate InitialData.json in app bundle.")
        }
        
        do {
            let data = try Data(contentsOf: url)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            
            if  let jsonDictionary = json as? [String: Any] {
                aboutBook = jsonDictionary["about"] as! [String: Any]
                poems = jsonDictionary["kural"] as! [[String: Any]]
            }
        } catch {
            fatalError("Failed to load initial data: \(error.localizedDescription)")
        }
    }
    
    func importBookInfo() -> Bool {
        guard let description = aboutBook["Description"] as? String else {
            return false
        }
        
        book.id = UUID()
        book.author = "திருவள்ளுவர்"
        book.color = "blue"
        book.name = bookName
        book.noofpoems = 1330
        book.order = 1
        book.period = ""
        book.info = description
        book.poemType = "குறள்"
        book.categoryLevel = 3
        
        saveContext()
        
        return true
    }

    func importCategories() -> Bool {
        // Load the JSON file
        if let url = Bundle.main.url(forResource: categoryFile, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [[String: Any]]
                
                // Parse the JSON data
                if let jsonArray = json {
                    for item in jsonArray {
                        if let section = item["section"] as? [String: Any],
                           let details = section["detail"] as? [[String: Any]] {
                            for detail in details {
                                // MainCategory
                                let mainCat = MainCategory(context: context)
                                mainCat.id = UUID()
                                mainCat.number = (detail["number"] as? Int16)!
                                mainCat.start = 0
                                mainCat.end = 0
                                mainCat.title = detail["name"] as? String
                                mainCat.groupname = section["tamil"] as? String
                                mainCat.bookname = "திருக்குறள்"
                                mainCat.book = book
                                
                                if let chapterGroups = detail["chapterGroup"] as? [String: Any],
                                   let subDetails = chapterGroups["detail"] as? [[String: Any]] {
                                    for subDetail in subDetails {
                                        
                                        // SubCategory
                                        let subCat = SubCategory(context: context)
                                        subCat.id = UUID()
                                        subCat.number = (subDetail["number"] as? Int16)!
                                        subCat.start = 0
                                        subCat.end = 0
                                        subCat.title = subDetail["name"] as? String
                                        subCat.groupname = chapterGroups["tamil"] as? String
                                        subCat.bookname = "திருக்குறள்"
                                        subCat.mainCategory = mainCat
                                        
                                        
                                        if let chapters = subDetail["chapters"] as? [String: Any],
                                           let chapterDetails = chapters["detail"] as? [[String: Any]] {
                                            for chapterDetail in chapterDetails {
                                                // Section
                                                let sec = Section(context: context)
                                                sec.id = UUID()
                                                sec.number = (chapterDetail["number"] as? Int16)!
                                                sec.start = (chapterDetail["start"] as? Int16)!
                                                sec.end = (chapterDetail["end"] as? Int16)!
                                                sec.title = chapterDetail["name"] as? String
                                                sec.groupname = chapters["tamil"] as? String
                                                sec.bookname = "திருக்குறள்"
                                                sec.subCategory = subCat
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    saveContext()
                    
                    print("Category data imported successfully!")
                    
                    return true
                }
            } catch {
                print("Failed to load or parse JSON: \(error)")
            }
        }
        
        return false
    }
    
    func importPoems() -> Bool {
        //importing poems and meanings
        for kural in poems {
            guard let number = kural["Number"] as? Int,
                  let line1 = kural["Line1"] as? String,
                  let line2 = kural["Line2"] as? String,
                  let transliteration1 = kural["transliteration1"] as? String,
                  let transliteration2 = kural["transliteration2"] as? String,
                  let mv = kural["mv"] as? String,
                  let sp = kural["sp"] as? String,
                  let mk = kural["mk"] as? String,
                  let explanation = kural["explanation"] as? String,
                  let couplet = kural["couplet"] as? String,
                  let translation = kural["Translation"] as? String,
                  let sectionName = kural["section"] as? String else {
                continue
            }
            
            let poemEntity = Poem(context: context)
            poemEntity.id = UUID()
            poemEntity.number = Int16(number)
            poemEntity.poem = "\(line1) \n\(line2)"
            poemEntity.poeminfo = "" // kural["Translation"] as? String ?? ""
            poemEntity.transliteration = "\(transliteration1) \n\(transliteration2)"
            poemEntity.title = ""
            poemEntity.bookname = bookName
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
            
            let expl1 = Explanation(context: context)
            expl1.id = UUID()
            expl1.author = "மு.வரதராசன்"
            expl1.language = "Tamil"
            expl1.order = 1
            expl1.poem = poemEntity
            expl1.title = "மு.வரதராசன் உரை"
            expl1.meaning = mv
            expl1.bookname = bookName
            
            let expl2 = Explanation(context: context)
            expl2.id = UUID()
            expl2.author = "சாலமன் பாப்பையா"
            expl2.language = "Tamil"
            expl2.order = 2
            expl2.poem = poemEntity
            expl2.title = "சாலமன் பாப்பையா உரை"
            expl2.meaning = sp
            expl2.bookname = bookName
            
            let expl3 = Explanation(context: context)
            expl3.id = UUID()
            expl3.author = "கலைஞர்"
            expl3.language = "Tamil"
            expl3.order = 3
            expl3.poem = poemEntity
            expl3.title = "கலைஞர் உரை"
            expl3.meaning = mk
            expl3.bookname = bookName
            
            let expl4 = Explanation(context: context)
            expl4.id = UUID()
            expl4.author = "Translation"
            expl4.language = "English"
            expl4.order = 4
            expl4.poem = poemEntity
            expl4.title = "Translation"
            expl4.meaning = translation
            expl4.bookname = bookName
            
            let expl5 = Explanation(context: context)
            expl5.id = UUID()
            expl5.author = "Couplet"
            expl5.language = "English"
            expl5.order = 5
            expl5.poem = poemEntity
            expl5.title = "Couplet"
            expl5.meaning = couplet
            expl5.bookname = bookName
            
            let expl6 = Explanation(context: context)
            expl6.id = UUID()
            expl6.author = "Explanation"
            expl6.language = "English"
            expl6.order = 6
            expl6.poem = poemEntity
            expl6.title = "Explanation"
            expl6.meaning = explanation
            expl6.bookname = bookName
        }
        
        saveContext()
        
        return true
    }
    
    //// Call this function in your App initialization
    //func loadInitialDataIfNeeded() {
    //    let userDefaults = UserDefaults.standard
    //    let isDataLoaded = userDefaults.bool(forKey: "isDataLoaded")
    //
    //    if !isDataLoaded {
    //        loadThirukural()
    //        userDefaults.set(true, forKey: "isDataLoaded")
    //    }
    //}
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            fatalError("Failed to save \(bookName) data: \(error.localizedDescription)")
        }
    }
}
