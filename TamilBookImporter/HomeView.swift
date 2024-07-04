//
//  HomeView.swift
//  TamilBookImporter
//
//  Created by Selvarajan on 04/07/24.
//

import SwiftUI

struct TamilBook: Identifiable {
    let id = UUID()
    let name: String
    let info: String
}

let TamilBooks = [
    TamilBook(name: "Thirukural", info: "Thirukural is a classic Tamil text consisting of 1,330 couplets."),
    TamilBook(name: "Athichudi", info: "Athichudi is a collection of single-line quotes by Avvaiyar."),
    TamilBook(name: "Naladiyar", info: "Naladiyar is a Tamil poetic work consisting of 400 quatrains.")
]

struct HomeView: View {
    @State private var selectedBook: TamilBook?

    var body: some View {
        NavigationView {
            BookListView(selectedBook: $selectedBook)
            if let selectedBook = selectedBook {
                if selectedBook.name == "Athichudi" {
                    BookDetailView(book: selectedBook, 
                                   bookImporter: AthichudiImporter(poemFile: "athichudi", 
                                                                   categoryFile: "athichudi-category"))
                } else if selectedBook.name == "Thirukural" {
                    BookDetailView(book: selectedBook,
                                   bookImporter: ThirukuralImporter(poemFile: "thirukural",
                                                                   categoryFile: "thirukural-category"))
                }
            } else {
                Text("Select a book")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
            }
        }
        .frame(minWidth: 600, minHeight: 400)
    }
}

struct BookListView: View {
    @Binding var selectedBook: TamilBook?
 
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack {
                List(TamilBooks) { book in
                    Text(book.name)
                        .onTapGesture {
                            selectedBook = book
                        }
                }
                .listStyle(SidebarListStyle())
                
                Spacer()
                
                Button {
                    _ = clearAllData()
                } label: {
                    Text("Clear Database")
                        .padding(10)
                }
                .cornerRadius(10.0)
                .padding(20)

            }
            .frame(minWidth: 200)
        }
    }
}

struct BookDetailView: View {
    let book: TamilBook
    let bookImporter: BookImporter

    @State private var info: String = ""
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(alignment: .leading) {
                Text(book.name)
                    .font(.largeTitle)
                    .padding(.bottom)
                
                Text(book.info)
                    .font(.body)
                    .padding(.bottom)
                
                Text("\(info)")
                    .font(.body)
                
                HStack {
                    
                    Button {
                        let count = bookImporter.getPoemCount()
                        if bookImporter.clearBookData() {
                            info = "\(book.name) data(\(count) poems) cleared successfully!"
                        } else {
                            info = "Something went wrong!"
                        }
                    } label: {
                        Text("Clear Book Data")
                            .padding()
                    }
                    .cornerRadius(10.0)
                    .padding()
                    
                    Button {
                        if bookImporter.importBookInfo() {
                            if bookImporter.importCategories() {
                                if bookImporter.importPoems() {
                                    let count = bookImporter.getPoemCount()
                                    info = "\(book.name) json imported successfully! \n\nTotal Poems: \(count)"
                                } else {
                                    info = "\(book.name) json import failed!"
                                }
                            }
                        }
                        
                    } label: {
                        Text("Import Book Data")
                            .padding()
                    }
                    .cornerRadius(10.0)
                    .padding()
                }
                
                Spacer()
            }
            .padding()
        }
        
    }
        
}

#Preview {
    HomeView()
}
