//
//  MainCategory+CoreDataProperties.swift
//  TamilBookImporter
//
//  Created by Selvarajan on 24/06/24.
//
//

import Foundation
import CoreData


extension MainCategory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MainCategory> {
        return NSFetchRequest<MainCategory>(entityName: "MainCategory")
    }

    @NSManaged public var end: Int16
    @NSManaged public var groupname: String?
    @NSManaged public var id: UUID?
    @NSManaged public var info: String?
    @NSManaged public var number: Int16
    @NSManaged public var start: Int16
    @NSManaged public var subtitle: String?
    @NSManaged public var title: String?
    @NSManaged public var bookname: String?
    @NSManaged public var book: Book?
    @NSManaged public var poems: Poem?
    @NSManaged public var subCategories: NSSet?

}

// MARK: Generated accessors for subCategories
extension MainCategory {

    @objc(addSubCategoriesObject:)
    @NSManaged public func addToSubCategories(_ value: SubCategory)

    @objc(removeSubCategoriesObject:)
    @NSManaged public func removeFromSubCategories(_ value: SubCategory)

    @objc(addSubCategories:)
    @NSManaged public func addToSubCategories(_ values: NSSet)

    @objc(removeSubCategories:)
    @NSManaged public func removeFromSubCategories(_ values: NSSet)

}

extension MainCategory : Identifiable {

}
