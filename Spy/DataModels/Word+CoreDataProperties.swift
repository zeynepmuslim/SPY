//
//  Word+CoreDataProperties.swift
//  Spy
//
//  Created by Zeynep Müslim on 11.06.2025.
//
//

import Foundation
import CoreData


extension Word {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Word> {
        return NSFetchRequest<Word>(entityName: "Word")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var text: String?
    @NSManaged public var category: Category?

}

extension Word : Identifiable {

}
