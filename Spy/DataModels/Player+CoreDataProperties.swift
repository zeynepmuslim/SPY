//
//  Player+CoreDataProperties.swift
//  Spy
//
//  Created by Zeynep Müslim on 12.06.2025.
//
//

import Foundation
import CoreData


extension Player {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Player> {
        return NSFetchRequest<Player>(entityName: "Player")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var isDefault: Bool
    @NSManaged public var isSpy: Bool
    @NSManaged public var name: String?
    @NSManaged public var score: Int16
    @NSManaged public var createdAt: Date?

}

extension Player : Identifiable {

}
