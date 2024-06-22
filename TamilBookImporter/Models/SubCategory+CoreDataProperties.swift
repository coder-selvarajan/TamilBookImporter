//
//  SubCategory+CoreDataProperties.swift
//  TamilBookImporter
//
//  Created by Selvarajan on 22/06/24.
//
//

import Foundation
import CoreData


extension SubCategory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SubCategory> {
        return NSFetchRequest<SubCategory>(entityName: "SubCategory")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var info: String?
    @NSManaged public var order: Int16
    @NSManaged public var subtitle: String?
    @NSManaged public var title: String?
    @NSManaged public var mainCategory: MainCategory?
    @NSManaged public var poems: NSSet?
    @NSManaged public var sections: NSSet?

}

// MARK: Generated accessors for poems
extension SubCategory {

    @objc(addPoemsObject:)
    @NSManaged public func addToPoems(_ value: Poem)

    @objc(removePoemsObject:)
    @NSManaged public func removeFromPoems(_ value: Poem)

    @objc(addPoems:)
    @NSManaged public func addToPoems(_ values: NSSet)

    @objc(removePoems:)
    @NSManaged public func removeFromPoems(_ values: NSSet)

}

// MARK: Generated accessors for sections
extension SubCategory {

    @objc(addSectionsObject:)
    @NSManaged public func addToSections(_ value: Section)

    @objc(removeSectionsObject:)
    @NSManaged public func removeFromSections(_ value: Section)

    @objc(addSections:)
    @NSManaged public func addToSections(_ values: NSSet)

    @objc(removeSections:)
    @NSManaged public func removeFromSections(_ values: NSSet)

}

extension SubCategory : Identifiable {

}
