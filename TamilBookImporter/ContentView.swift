//
//  ContentView.swift
//  TamilBookImporter
//
//  Created by Selvarajan on 22/06/24.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: Poem.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Poem.number, ascending: true)]
    ) var poems: FetchedResults<Poem>
    
    @State private var info: String = ""
    @State var poemCount: Int = 0
    
    private func clearAllPoems() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Poem")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try viewContext.execute(deleteRequest)
            try viewContext.save()
        } catch let error as NSError {
            print("Could not delete poems. \(error), \(error.userInfo)")
        }
    }
    
    private func countPoems() -> Int {
        let fetchRequest: NSFetchRequest<Poem> = Poem.fetchRequest()
        var count = 0
        
        do {
            count = try viewContext.count(for: fetchRequest)
        } catch let error as NSError {
            print("Could not count poems. \(error), \(error.userInfo)")
        }
        
        return count
    }
    
    var body: some View {
        VStack {
            Spacer()
            Text("Tamil Books - Importer")
                .font(.title)
            Spacer()
            
            Text("\(info)")
                .font(.body)
            
            Spacer()
            
            Button {
                let count = countPoems()
                
                clearAllPoems()
                info = "\(count) poems cleared successfully!"
            } label: {
                Text("Clear Database ")
                    .padding(10)
            }
            .background(.blue)
            .cornerRadius(10.0)
            
            Button {
                loadThirukural()
                info = "Thirukural json imported successfully! \n\nTotal Poems: \(countPoems())"
            } label: {
                Text("Import 'Thirukural'")
                    .padding(10)
            }
            .background(.blue)
            .cornerRadius(10.0)
            
            
            Spacer()
            
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
