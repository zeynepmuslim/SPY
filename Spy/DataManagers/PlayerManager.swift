//
//  PlayerManager.swift
//  Spy
//
//  Created by Zeynep Müslim on 12.06.2025.
//

import Foundation
import CoreData
import UIKit

class PlayerManager {
    private static let defaultPlayersCount = 10
    
    // MARK: - Singleton
    static let shared = PlayerManager()
    private let context: NSManagedObjectContext
    
    // MARK: - Initialization
    private init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Could not get app delegate")
        }
        self.context = appDelegate.persistentContainer.viewContext
    }
    
    // MARK: - Default Players Management
    
    /// Creates default players if they don't exist, ensuring exactly 10 default players
    func createDefaultPlayers() {
        do {
            let existingCount = try getDefaultPlayersCount()
            if existingCount >= Self.defaultPlayersCount {
                return
            }
            
            let playersToCreate = Self.defaultPlayersCount - existingCount
            createPlayers(count: playersToCreate, startingIndex: existingCount + 1, isDefault: true)
            
            try saveContext()
        } catch {
            handleError("creating default players", error: error)
        }
    }
    
    /// Updates the number of default players to the specified count
    func updateDefaultPlayerCount(to newCount: Int) {
        do {
            let defaultPlayers = try fetchDefaultPlayers()
            let currentCount = defaultPlayers.count
            
            if newCount > currentCount {
                let playersToCreate = newCount - currentCount
                createPlayers(count: playersToCreate, startingIndex: currentCount + 1, isDefault: true)
            } else if newCount < currentCount {
                let playersToDelete = defaultPlayers.suffix(currentCount - newCount)
                deletePlayers(Array(playersToDelete))
            }
            
            try saveContextIfNeeded()
            print("Default player count updated to \(newCount)")
        } catch {
            handleError("updating default player count", error: error)
        }
    }
    
    // MARK: - Player Retrieval
    
    /// Returns all default players sorted by creation date
    func getDefaultPlayers() -> [Player] {
        do {
            return try fetchDefaultPlayers()
        } catch {
            handleError("fetching default players", error: error)
            return []
        }
    }
    
    /// Returns all custom (non-default) players sorted by creation date
    func getCustomPlayers() -> [Player] {
        do {
            return try fetchPlayersWithPredicate(NSPredicate(format: "isDefault == NO"))
        } catch {
            handleError("fetching custom players", error: error)
            return []
        }
    }
    
    /// Returns all players (both default and custom) sorted by creation date
    func getAllPlayers() -> [Player] {
        do {
            return try fetchPlayersWithPredicate(nil)
        } catch {
            handleError("fetching all players", error: error)
            return []
        }
    }
    
    // MARK: - Player Updates
    
    /// Updates a player's name and saves the context
    func updatePlayerName(player: Player, newName: String) {
        player.name = newName
        do {
            try saveContext()
        } catch {
            handleError("saving player name change", error: error)
        }
    }
    
    // MARK: - Core Data Reset
    
    /// Resets all Core Data entities - WARNING: This will delete ALL data
    func resetCoreData() {
        let entityNames = ["Player", "GameSession", "Round", "Category", "Word"]
        
        for entityName in entityNames {
            do {
                try deleteAllEntities(named: entityName)
            } catch {
                print("Could not reset Core Data for entity \(entityName). \(error)")
            }
        }
        
        do {
            try saveContext()
            print("Core Data has been reset.")
        } catch {
            handleError("saving context after reset", error: error)
        }
    }
    
    // MARK: - Debug Utilities
    
    /// Prints detailed information about all players for debugging
    func debugPrintPlayers() {
        let defaultPlayers = getDefaultPlayers()
        let customPlayers = getCustomPlayers()
        
        print("========== PLAYERS ==========")
        print("-- Default Players (\(defaultPlayers.count)) --")
        for (idx, player) in defaultPlayers.enumerated() {
            print("[Default #\(idx+1)] " + formatPlayerDescription(player))
        }
        print("-- Custom Players (\(customPlayers.count)) --")
        for (idx, player) in customPlayers.enumerated() {
            print("[Custom #\(idx+1)] " + formatPlayerDescription(player))
        }
        print("=============================\n")
    }
}

// MARK: - Private Helper Methods
private extension PlayerManager {
    
    /// Creates the specified number of players with given parameters
    func createPlayers(count: Int, startingIndex: Int, isDefault: Bool) {
        for i in startingIndex..<(startingIndex + count) {
            createPlayer(index: i, isDefault: isDefault)
        }
    }
    
    /// Creates a single player with the specified parameters
    func createPlayer(index: Int, isDefault: Bool) {
        let player = Player(context: context)
        player.id = UUID()
        player.name = String(format: "player_x".localized, index)
        player.score = 0
        player.isDefault = isDefault
        player.isSpy = false
        player.createdAt = Date().addingTimeInterval(TimeInterval(index))
    }
    
    /// Deletes multiple players from the context
    func deletePlayers(_ players: [Player]) {
        players.forEach { context.delete($0) }
    }
    
    /// Fetches default players with error throwing
    func fetchDefaultPlayers() throws -> [Player] {
        return try fetchPlayersWithPredicate(NSPredicate(format: "isDefault == YES"))
    }
    
    /// Gets the count of default players
    func getDefaultPlayersCount() throws -> Int {
        let fetchRequest: NSFetchRequest<Player> = Player.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isDefault == YES")
        return try context.count(for: fetchRequest)
    }
    
    /// Generic method to fetch players with optional predicate
    func fetchPlayersWithPredicate(_ predicate: NSPredicate?) throws -> [Player] {
        let fetchRequest: NSFetchRequest<Player> = Player.fetchRequest()
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        return try context.fetch(fetchRequest)
    }
    
    /// Deletes all entities of the specified name
    func deleteAllEntities(named entityName: String) throws {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try context.execute(deleteRequest)
    }
    
    /// Saves context only if there are changes
    func saveContextIfNeeded() throws {
        if context.hasChanges {
            try context.save()
        }
    }
    
    /// Saves context unconditionally
    func saveContext() throws {
        try context.save()
    }
    
    /// Consistent error handling with descriptive messages
    func handleError(_ operation: String, error: Error) {
        print("Error \(operation): \(error)")
    }
    
    /// Formats player information for debugging
    func formatPlayerDescription(_ player: Player) -> String {
        let idString = player.id?.uuidString ?? "nil"
        let name = player.name ?? "nil"
        return "id: \(idString) | name: \(name) | score: \(player.score) | isSpy: \(player.isSpy) | isDefault: \(player.isDefault)"
    }
}
