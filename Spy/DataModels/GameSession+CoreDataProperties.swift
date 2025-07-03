//
//  GameSession+CoreDataProperties.swift
//  Spy
//
//  Created by Zeynep Müslim on 14.06.2025.
//
//

import Foundation
import CoreData


extension GameSession {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GameSession> {
        return NSFetchRequest<GameSession>(entityName: "GameSession")
    }

    @NSManaged public var category: String?
    @NSManaged public var currentRound: Int16
    @NSManaged public var id: UUID?
    @NSManaged public var isDefault: Bool
    @NSManaged public var isHintAvaible: Bool
    @NSManaged public var playerCount: Int16
    @NSManaged public var roundCount: Int16
    @NSManaged public var roundDuration: Int16
    @NSManaged public var spyCount: Int16
    @NSManaged public var rounds: NSSet?
    
    @NSManaged public var spyIndicesAllRounds: NSArray?
    
    var spyIndicesArray: [[Int]] {
        get {
            return (spyIndicesAllRounds as? [[Int]]) ?? []
        }
        set {
            spyIndicesAllRounds = newValue as NSArray
        }
    }
}

extension GameSession : Identifiable {

}
