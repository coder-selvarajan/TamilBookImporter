//
//  ImportThirukural.swift
//  TamilBookImporter
//
//  Created by Selvarajan on 22/06/24.
//

import Foundation
import CoreData
import SwiftUI

// Function to load the initial data
func loadThirukural() {
    guard let url = Bundle.main.url(forResource: "thirukkural", withExtension: "json") else {
        fatalError("Failed to locate InitialData.json in app bundle.")
    }
    
    do {
        let data = try Data(contentsOf: url)
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        
        if  let jsonDictionary = json as? [String: Any],
            let about = jsonDictionary["about"] as? [String: Any],
            let kurals = jsonDictionary["kural"] as? [[String: Any]] {
            parseAndStoreData(about: about, kurals: kurals)
        }
    } catch {
        fatalError("Failed to load initial data: \(error.localizedDescription)")
    }
}

// Function to parse and store data
func parseAndStoreData(about: [String: Any], kurals: [[String: Any]]) {
    let context = PersistenceController.shared.container.viewContext
    guard let description = about["Description"] as? String else {
        return
    }
    
    let book = Book(context: context)
    book.id = UUID()
    book.author = "திருவள்ளுவர்"
    book.color = "blue"
    book.name = "திருக்குறள்"
    book.noofpoems = 1330
    book.order = 1
    book.period = ""
    book.info = description
    
    // import Categories
    importCategories(for: book)
    
    //importing poems and meanings
    for kural in kurals {
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
              let translation = kural["Translation"] as? String else {
            continue
        }
         
        let poemEntity = Poem(context: context)
        poemEntity.id = UUID()
        poemEntity.number = Int16(number)
        poemEntity.poem = "\(line1) \n\(line2)"
        poemEntity.poeminfo = "" // kural["Translation"] as? String ?? ""
        poemEntity.transliteration = "\(transliteration1) \n\(transliteration2)"
        
        //adding poem to the book
        book.poems?.adding(poemEntity)
        
        let expl1 = Explanation(context: context)
        expl1.id = UUID()
        expl1.author = "மு.வரதராசன்"
        expl1.language = "Tamil"
        expl1.order = 1
        expl1.poem = poemEntity
        expl1.title = "மு.வரதராசன் உரை"
        expl1.meaning = mv
        
        let expl2 = Explanation(context: context)
        expl2.id = UUID()
        expl2.author = "சாலமன் பாப்பையா"
        expl2.language = "Tamil"
        expl2.order = 2
        expl2.poem = poemEntity
        expl2.title = "சாலமன் பாப்பையா உரை"
        expl2.meaning = sp
        
        let expl3 = Explanation(context: context)
        expl3.id = UUID()
        expl3.author = "கலைஞர்"
        expl3.language = "Tamil"
        expl3.order = 3
        expl3.poem = poemEntity
        expl3.title = "கலைஞர் உரை"
        expl3.meaning = mk
        
        
        let expl4 = Explanation(context: context)
        expl4.id = UUID()
        expl4.author = "Translation"
        expl4.language = "English"
        expl4.order = 4
        expl4.poem = poemEntity
        expl4.title = "Translation"
        expl4.meaning = translation
        
        let expl5 = Explanation(context: context)
        expl5.id = UUID()
        expl5.author = "Couplet"
        expl5.language = "English"
        expl5.order = 5
        expl5.poem = poemEntity
        expl5.title = "Couplet"
        expl5.meaning = couplet
        
        let expl6 = Explanation(context: context)
        expl6.id = UUID()
        expl6.author = "Explanation"
        expl6.language = "English"
        expl6.order = 6
        expl6.poem = poemEntity
        expl6.title = "Explanation"
        expl6.meaning = explanation
        
    }
    
    do {
        try context.save()
    } catch {
        fatalError("Failed to save initial data: \(error.localizedDescription)")
    }
}

// Call this function in your App initialization
func loadInitialDataIfNeeded() {
    let userDefaults = UserDefaults.standard
    let isDataLoaded = userDefaults.bool(forKey: "isDataLoaded")
    
    if !isDataLoaded {
        loadThirukural()
        userDefaults.set(true, forKey: "isDataLoaded")
    }
}

func clearAllPoems() {
    let context = PersistenceController.shared.container.viewContext
    
    let fetchRequest2: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Poem")
    let deleteRequest2 = NSBatchDeleteRequest(fetchRequest: fetchRequest2)
    
    let deleteRequest3 = NSBatchDeleteRequest(fetchRequest: NSFetchRequest(entityName: "Book"))
    let deleteRequest4 = NSBatchDeleteRequest(fetchRequest: NSFetchRequest(entityName: "Explanation"))
    
    let deleteRequest5 = NSBatchDeleteRequest(fetchRequest: NSFetchRequest(entityName: "MainCategory"))
    let deleteRequest6 = NSBatchDeleteRequest(fetchRequest: NSFetchRequest(entityName: "SubCategory"))
    let deleteRequest7 = NSBatchDeleteRequest(fetchRequest: NSFetchRequest(entityName: "Section"))
    
    do {
        
        try context.execute(deleteRequest7)
        try context.execute(deleteRequest6)
        try context.execute(deleteRequest5)
        
        try context.execute(deleteRequest4)
        try context.execute(deleteRequest3)
        try context.execute(deleteRequest2)
        
        try context.save()
    } catch let error as NSError {
        print("Could not delete poems. \(error), \(error.userInfo)")
    }
}

func countBooks() -> Int {
    let context = PersistenceController.shared.container.viewContext
    let fetchRequest: NSFetchRequest<Book> = Book.fetchRequest()
    var count = 0
    
    do {
        count = try context.count(for: fetchRequest)
    } catch let error as NSError {
        print("Could not count poems. \(error), \(error.userInfo)")
    }
    
    return count
}

func countPoems() -> Int {
    let context = PersistenceController.shared.container.viewContext
    let fetchRequest: NSFetchRequest<Poem> = Poem.fetchRequest()
    var count = 0
    
    do {
        count = try context.count(for: fetchRequest)
    } catch let error as NSError {
        print("Could not count poems. \(error), \(error.userInfo)")
    }
    
    return count
}

func countExplanations() -> Int {
    let context = PersistenceController.shared.container.viewContext
    let fetchRequest: NSFetchRequest<Explanation> = Explanation.fetchRequest()
    var count = 0
    
    do {
        count = try context.count(for: fetchRequest)
    } catch let error as NSError {
        print("Could not count poems. \(error), \(error.userInfo)")
    }
    
    return count
}

func importCategories(for book: Book) {
    let context = PersistenceController.shared.container.viewContext
    
    // Load the JSON file
    if let url = Bundle.main.url(forResource: "kural-category", withExtension: "json") {
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
                                            sec.subCategory = subCat
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                try context.save()
                print("Data imported successfully!")
            }
        } catch {
            print("Failed to load or parse JSON: \(error)")
        }
    }
    
}
