//
//  Explanation+CoreDataProperties.swift
//  TamilBookImporter
//
//  Created by Selvarajan on 04/07/24.
//
//

import Foundation
import CoreData


extension Explanation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Explanation> {
        return NSFetchRequest<Explanation>(entityName: "Explanation")
    }

    @NSManaged public var author: String?
    @NSManaged public var id: UUID?
    @NSManaged public var info: String?
    @NSManaged public var language: String?
    @NSManaged public var meaning: String?
    @NSManaged public var order: Int16
    @NSManaged public var subtitle: String?
    @NSManaged public var title: String?
    @NSManaged public var bookname: String?
    @NSManaged public var poem: Poem?

}

extension Explanation : Identifiable {

}
