//
//  Round+CoreDataProperties.swift
//  Spy
//
//  Created by Zeynep Müslim on 14.06.2025.
//
//

import Foundation
import CoreData


extension Round {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Round> {
        return NSFetchRequest<Round>(entityName: "Round")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var roundNumber: Int16
    @NSManaged public var selectedWord: String?
    @NSManaged public var winnerType: String?
    @NSManaged public var session: GameSession?
    
    @NSManaged private var spyIndicesRaw: NSArray?
    @NSManaged private var foundSpyIndicesRaw: NSArray?
    @NSManaged private var blamedCivilianIndicesRaw: NSArray?
    
    var spyIndices: Set<Int> {
        get {
            return Set((spyIndicesRaw as? [Int]) ?? [])
        }
        set {
            spyIndicesRaw = Array(newValue) as NSArray
        }
    }
    
    var foundSpyIndices: Set<Int> {
        get {
            return Set((foundSpyIndicesRaw as? [Int]) ?? [])
        }
        set {
            foundSpyIndicesRaw = Array(newValue) as NSArray
        }
    }
    
    var blamedCivilianIndices: Set<Int> {
        get {
            return Set((blamedCivilianIndicesRaw as? [Int]) ?? [])
        }
        set {
            blamedCivilianIndicesRaw = Array(newValue) as NSArray
        }
    }
}

extension Round : Identifiable {

}
