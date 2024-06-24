//
//  Book+CoreDataProperties.swift
//  TamilBookImporter
//
//  Created by Selvarajan on 24/06/24.
//
//

import Foundation
import CoreData


extension Book {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Book> {
        return NSFetchRequest<Book>(entityName: "Book")
    }

    @NSManaged public var author: String?
    @NSManaged public var color: String?
    @NSManaged public var id: UUID?
    @NSManaged public var image: String?
    @NSManaged public var info: String?
    @NSManaged public var name: String?
    @NSManaged public var noofpoems: Int16
    @NSManaged public var order: Int16
    @NSManaged public var period: String?
    @NSManaged public var categories: NSSet?
    @NSManaged public var poems: NSSet?

}

// MARK: Generated accessors for categories
extension Book {

    @objc(addCategoriesObject:)
    @NSManaged public func addToCategories(_ value: MainCategory)

    @objc(removeCategoriesObject:)
    @NSManaged public func removeFromCategories(_ value: MainCategory)

    @objc(addCategories:)
    @NSManaged public func addToCategories(_ values: NSSet)

    @objc(removeCategories:)
    @NSManaged public func removeFromCategories(_ values: NSSet)

}

// MARK: Generated accessors for poems
extension Book {

    @objc(addPoemsObject:)
    @NSManaged public func addToPoems(_ value: Poem)

    @objc(removePoemsObject:)
    @NSManaged public func removeFromPoems(_ value: Poem)

    @objc(addPoems:)
    @NSManaged public func addToPoems(_ values: NSSet)

    @objc(removePoems:)
    @NSManaged public func removeFromPoems(_ values: NSSet)

}

extension Book : Identifiable {

}
