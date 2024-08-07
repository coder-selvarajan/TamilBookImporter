//
//  ContentView.swift
//  TamilBookImporter
//
//  Created by Selvarajan on 22/06/24.
//

import SwiftUI

struct ContentView: View {
//    @FetchRequest(
//        entity: Poem.entity(),
//        sortDescriptors: [NSSortDescriptor(keyPath: \Poem.number, ascending: true)]
//    ) var poems: FetchedResults<Poem>
    
    @State private var info: String = ""
    @State var poemCount: Int = 0
    
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
//                let count = countPoems()
//                let expCount = countExplanations()
//                let bookCount = countBooks()
//                
//                clearAllPoems()
//                info = "\(bookCount) books, \(count) poems and \(expCount) explanations cleared successfully!"
            } label: {
                Text("Clear Database ")
                    .padding(10)
            }
            .background(.red)
            .cornerRadius(10.0)
            
            Divider()
            
            Button {
//                loadThirukural()
//                info = "Thirukural json imported successfully! \n\nTotal Poems: \(countPoems())"
            } label: {
                Text("Import 'Thirukural'")
                    .foregroundColor(.black)
                    .padding(10)
            }
            .background(.white)
            .cornerRadius(10.0)
            
            Button {
//                loadThirukural()
//                info = "Athichudi json imported successfully! \n\nTotal Poems: \(countPoems())"
            } label: {
                Text("Import 'Athichudi'")
                    .foregroundColor(.black)
                    .padding(10)
            }
            .background(.white)
            .cornerRadius(10.0)
            
            Spacer()
            
        }
        .padding()
        .frame(maxWidth: 300)
    }
}

#Preview {
    ContentView()
}
