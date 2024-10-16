//
//  Devices+CoreDataProperties.swift
//  UST-Test
//
//  Created by Ajith Mohan on 15/10/24.
//
//

import Foundation
import CoreData


extension Devices {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Devices> {
        return NSFetchRequest<Devices>(entityName: "Devices")
    }

    @NSManaged public var name: String?
    @NSManaged public var ipAddress: String?
    @NSManaged public var status: String?
    @NSManaged public var lastUpdated: Date?

}

extension Devices : Identifiable {

}
