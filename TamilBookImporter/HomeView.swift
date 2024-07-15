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
    TamilBook(name: "IniyavaiNarpathu", info: ""),
    TamilBook(name: "InnaNarpathu", info: ""),
    TamilBook(name: "Aacharakkovai", info: ""),
    TamilBook(name: "Nanmanikadikai", info: ""),
    TamilBook(name: "Thirikadukam", info: ""),
    TamilBook(name: "Naaladiyar", info: "Naladiyar is a Tamil poetic work consisting of 400 quatrains."),
    TamilBook(name: "Muthumozhikanchi", info: ""),
    TamilBook(name: "Pazhamozhinanooru", info: "")
]

struct HomeView: View {
    @State private var selectedBook: TamilBook?
    
    var body: some View {
        NavigationView {
            BookListView(selectedBook: $selectedBook)
            Group {
                if let selectedBook = selectedBook {
                    switch selectedBook.name {
                    case "Athichudi":
                        BookDetailView(book: selectedBook,
                                       bookImporter: AthichudiImporter(poemFile: "athichudi",
                                                                       categoryFile: "athichudi-category"))
                    case "Thirukural":
                        BookDetailView(book: selectedBook,
                                       bookImporter: ThirukuralImporter(poemFile: "thirukural",
                                                                        categoryFile: "thirukural-category"))
                    case "IniyavaiNarpathu":
                        BookDetailView(book: selectedBook,
                                       bookImporter: IniyavaiNarpathuImporter(poemFile: "iniyavai-narpathu",
                                                                        categoryFile: "iniyavai-narpathu-category"))
                    case "InnaNarpathu":
                        BookDetailView(book: selectedBook,
                                       bookImporter: InnaNarpathuImporter(poemFile: "inna-narpathu",
                                                                        categoryFile: "inna-narpathu-category"))
                    case "Aacharakkovai":
                        BookDetailView(book: selectedBook,
                                       bookImporter: AacharakkovaiImporter(poemFile: "aacharakkovai",
                                                                        categoryFile: "aacharakkovai-category"))
                    case "Nanmanikadikai":
                        BookDetailView(book: selectedBook,
                                       bookImporter: NanmanikadikaiImporter(poemFile: "nanmanikadikai",
                                                                        categoryFile: "nanmanikadikai-category"))
                    case "Thirikadukam":
                        BookDetailView(book: selectedBook,
                                       bookImporter: ThirikadukamImporter(poemFile: "thirikadukam",
                                                                        categoryFile: "thirikadukam-category"))
                    case "Naaladiyar":
                        BookDetailView(book: selectedBook,
                                       bookImporter: NaaladiyarImporter(poemFile: "naaladiyar",
                                                                        categoryFile: "naaladiyar-category"))
                    case "Muthumozhikanchi":
                        BookDetailView(book: selectedBook,
                                       bookImporter: MuthumozhikanchiImporter(poemFile: "muthumozhikanchi",
                                                                        categoryFile: "muthumozhikanchi-category"))
                    case "Pazhamozhinanooru":
                        BookDetailView(book: selectedBook,
                                       bookImporter: PazhamozhiNanooruImporter(poemFile: "pazhamozhinanooru",
                                                                        categoryFile: "pazhamozhinanooru-category"))
                    
                    default:
                        EmptyView()
                    }
                } else {
                    Text("Select a book")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                }
            }
        }
        .frame(minWidth: 600, minHeight: 400)
    }
}

struct BookListView: View {
    @Binding var selectedBook: TamilBook?
    @State var message: String = ""
    
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
                
                Text(message)
                    .padding()
                Button {
                    _ = clearAllData()
                    
                    message = "Database cleared"
                } label: {
                    Text("Clear Database")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
                .padding()

            }
            .frame(minWidth: 200)
        }
    }
}

struct BookDetailView: View {
    let book: TamilBook
    let bookImporter: BookImporter
    
    @State private var info: String = ""
    
    @State private var explanationCount: Int = 0
    @State private var poemCount: Int = 0
    @State private var sectionCount: Int = 0
    @State private var subCatCount: Int = 0
    @State private var mainCatCount: Int = 0
    
    func updateStatus() {
        explanationCount = bookImporter.getExplanationCount()
        poemCount = bookImporter.getPoemCount()
        sectionCount = bookImporter.getSectionCount()
        subCatCount = bookImporter.getSubCategoryCount()
        mainCatCount = bookImporter.getMainCategoryCount()
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(alignment: .leading) {
                Text(book.name)
                    .font(.largeTitle)
                    .padding(.bottom, 10)
                
               
                VStack(alignment: .leading) {
                    Text("**Record Count:**")
                        .font(.headline)
                        .padding(.bottom, 2)
                    
                    HStack(alignment: VerticalAlignment.top, spacing: 30) {
                        
                        VStack(alignment: .leading) {
                            Text("Category: ")
                            Text("\(mainCatCount)")
                                .font(.title)
                        }
                        VStack(alignment: .leading) {
                            Text("SubCategory: ")
                            Text("\(subCatCount)")
                                .font(.title)
                        }
                        VStack(alignment: .leading) {
                            Text("Section: ")
                            Text("\(sectionCount)")
                                .font(.title)
                        }
                        VStack(alignment: .leading) {
                            Text("Poems: ")
                            Text("\(poemCount)")
                                .font(.title)
                        }
                        VStack(alignment: .leading) {
                            Text("Meaning: ")
                            Text("\(explanationCount)")
                                .font(.title)
                        }
                    }
                }
                .padding(20)
                .background(.gray.opacity(0.15))
                .cornerRadius(10.0)
                .padding(.bottom)
                
                
                VStack(alignment: .leading) {
                    
                    HStack {
                        Button {
                            if bookImporter.clearBookData() {
                                info = "\(book.name) data cleared successfully!"
                            } else {
                                info = "Something went wrong!"
                            }
                            updateStatus()
                            
                        } label: {
                            Text("Clear data")
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding(15)
                                .background(Color.pink)
                                .cornerRadius(10)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button {
                            if bookImporter.importBookInfo() {
                                if bookImporter.importCategories() {
                                    if bookImporter.importPoems() {
                                        info = "\(book.name) json imported successfully!"
                                    } else {
                                        info = "\(book.name) json import failed!"
                                    }
                                }
                            }
                            updateStatus()
                        } label: {
                            Text("Import \(book.name)")
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding(15)
                                .background(Color.cyan)
                                .cornerRadius(10)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button {
                            updateStatus()
                        } label: {
                            Text("Refresh")
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding(15)
                                .background(Color.cyan)
                                .cornerRadius(10)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                Text("\(info)")
                    .font(.title3)
                    .padding(.top)
                Spacer()
            }
            .padding(50)
        }
        .onAppear(){
            updateStatus()
        }
        
    }
        
}

#Preview {
    HomeView()
}
