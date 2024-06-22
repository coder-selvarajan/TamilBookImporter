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
func loadInitialData() {
    guard let url = Bundle.main.url(forResource: "thirukkural", withExtension: "json") else {
        fatalError("Failed to locate InitialData.json in app bundle.")
    }
    
    do {
        let data = try Data(contentsOf: url)
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        
        if let jsonDictionary = json as? [String: Any], let kurals = jsonDictionary["kural"] as? [[String: Any]] {
            parseAndStoreData(kurals: kurals)
        }
    } catch {
        fatalError("Failed to load initial data: \(error.localizedDescription)")
    }
}

// Function to parse and store data
func parseAndStoreData(kurals: [[String: Any]]) {
    let context = PersistenceController.shared.container.viewContext
    
    for kural in kurals {
        guard let number = kural["Number"] as? Int,
              let line1 = kural["Line1"] as? String,
              let line2 = kural["Line2"] as? String,
              let transliteration1 = kural["transliteration1"] as? String,
              let transliteration2 = kural["transliteration2"] as? String else {
            continue
        }
        
        let poemEntity = Poem(context: context)
        poemEntity.id = UUID()
        poemEntity.number = Int16(number)
        poemEntity.poem = "\(line1) \(line2)"
        poemEntity.poeminfo = "" // kural["Translation"] as? String ?? ""
        poemEntity.transliteration = "\(transliteration1) \(transliteration2)"
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
        loadInitialData()
        userDefaults.set(true, forKey: "isDataLoaded")
    }
}
