//
//  Settings+CoreDataProperties.swift
//  TamilBookImporter
//
//  Created by Selvarajan on 23/06/24.
//
//

import Foundation
import CoreData


extension Settings {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Settings> {
        return NSFetchRequest<Settings>(entityName: "Settings")
    }


}

extension Settings : Identifiable {

}
