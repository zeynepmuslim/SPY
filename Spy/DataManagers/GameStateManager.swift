import Foundation
import CoreData
import UIKit

class GameStateManager {
    
    // MARK: - Singleton & Initialization
    
    static let shared = GameStateManager()
    private let context: NSManagedObjectContext
    
    private init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Could not get app delegate")
        }
        self.context = appDelegate.persistentContainer.viewContext
    }
    
    // MARK: - Constants
    
    private struct Constants {
        static let defaultCategories = ["basic", "travel", "food", "history", "places", "sports"]
    }
    
    // MARK: - Core Data Helpers
    private func performFetch<T: NSManagedObject>(_ fetchRequest: NSFetchRequest<T>) -> [T] {
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error performing fetch for \(T.self): \(error)")
            return []
        }
    }
    
    private func performFetchFirst<T: NSManagedObject>(_ fetchRequest: NSFetchRequest<T>) -> T? {
        return performFetch(fetchRequest).first
    }
    
    func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    // MARK: - Session Management
    
    func getCurrentGameSession() -> GameSession? {
        let fetchRequest: NSFetchRequest<GameSession> = GameSession.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isDefault == %@", NSNumber(value: false))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        return performFetchFirst(fetchRequest)
    }
    
    func createDefaultSession(category: String = "basic", playerCount: Int16 = 5, roundCount: Int16 = 5, roundDuration: Int16 = 2, spyCount: Int16 = 1, isHintAvaible: Bool = true) {
        let fetchRequest: NSFetchRequest<GameSession> = GameSession.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isDefault == YES")
        
        let existing = performFetch(fetchRequest)
        if !existing.isEmpty {
            return
        }
        
        let session = GameSession(context: context)
        session.id = UUID()
        session.category = category
        session.playerCount = playerCount
        session.roundCount = roundCount
        session.roundDuration = roundDuration
        session.spyCount = spyCount
        session.isDefault = true
        session.isHintAvaible = isHintAvaible
        session.currentRound = 0
        saveContext()
    }
    
    func getDefaultSessions() -> [GameSession] {
        let fetchRequest: NSFetchRequest<GameSession> = GameSession.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isDefault == YES")
        return performFetch(fetchRequest)
    }
    
    func getCustomSessions() -> [GameSession] {
        let fetchRequest: NSFetchRequest<GameSession> = GameSession.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isDefault == NO")
        return performFetch(fetchRequest)
    }
    
    func updateDefaultSession(_ session: GameSession, category: String, playerCount: Int16, roundCount: Int16, roundDuration: Int16, spyCount: Int16, isHintAvaible: Bool) {
        guard session.isDefault == true else { return }
        session.category = category
        session.playerCount = playerCount
        session.roundCount = roundCount
        session.roundDuration = roundDuration
        session.spyCount = spyCount
        session.isHintAvaible = isHintAvaible
        saveContext()
    }
    
    func deleteCustomSession(_ session: GameSession) {
        guard session.isDefault == false else { return }
        context.delete(session)
        saveContext()
    }
    
    func deleteAllCustomSessions() {
        let fetchRequest: NSFetchRequest<GameSession> = GameSession.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isDefault == NO")
        
        let customSessions = performFetch(fetchRequest)
        for session in customSessions {
            context.delete(session)
        }
        saveContext()
    }
    
    // MARK: - Player Management
    
    func getCurrentPlayers() -> [Player] {
        let fetchRequest: NSFetchRequest<Player> = Player.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isDefault == %@", NSNumber(value: false))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        return performFetch(fetchRequest)
    }
    
    // MARK: - Round Management
    
    func getCurrentRoundNumber() -> Int {
        guard let session = getCurrentGameSession() else { return 0 }
        return Int(session.currentRound)
    }
    
    func updateCurrentRound(to roundNumber: Int) {
        guard let session = getCurrentGameSession() else { return }
        session.currentRound = Int16(roundNumber)
        saveContext()
    }
    
    func getCurrentRound() -> Round? {
        guard let session = getCurrentGameSession() else { return nil }
        
        let fetchRequest: NSFetchRequest<Round> = Round.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "session == %@ AND roundNumber == %d", session, session.currentRound)
        return performFetchFirst(fetchRequest)
    }
    
    func updateRoundState(
        spyIndices: Set<Int>,
        foundSpyIndices: Set<Int>,
        blamedCivilianIndices: Set<Int>,
        winnerType: WinnerType? = nil,
        isCompleted: Bool = false
    ) {
        guard let round = getCurrentRound() else { return }
        
        round.spyIndices = spyIndices
        round.foundSpyIndices = foundSpyIndices
        round.blamedCivilianIndices = blamedCivilianIndices
        
        if let winnerType = winnerType {
            round.winnerType = winnerType.rawValue
        }
        
        round.isCompleted = isCompleted
        saveContext()
    }
    
    func getRoundState() -> (
        spyIndices: Set<Int>,
        foundSpyIndices: Set<Int>,
        blamedCivilianIndices: Set<Int>,
        winnerType: WinnerType?,
        isCompleted: Bool
    ) {
        guard let round = getCurrentRound() else {
            return (Set<Int>(), Set<Int>(), Set<Int>(), nil, false)
        }
        
        let spyIndices = round.spyIndices
        let foundSpyIndices = round.foundSpyIndices
        let blamedCivilianIndices = round.blamedCivilianIndices
        
        var winnerType: WinnerType? = nil
        if let winnerTypeString = round.winnerType {
            winnerType = WinnerType(rawValue: winnerTypeString)
        }
        
        return (spyIndices, foundSpyIndices, blamedCivilianIndices, winnerType, round.isCompleted)
    }
    
    // MARK: - Spy Management
    
    func saveSpyIndicesForAllRounds(_ spiesPerRound: [Set<Int>]) {
        guard let session = getCurrentGameSession() else { return }
        
        // Convert Set<Int> to [Int] arrays
        let arrayOfArrays = spiesPerRound.map { Array($0) }
        session.spyIndicesArray = arrayOfArrays
        saveContext()
    }
    
    func getSpyIndicesForAllRounds() -> [Set<Int>] {
        guard let session = getCurrentGameSession() else { return [] }
        // Convert [Int] arrays back to Set<Int>
        return session.spyIndicesArray.map { Set($0) }
    }
    
    func getSpyIndicesForCurrentRound() -> Set<Int> {
        let allSpies = getSpyIndicesForAllRounds()
        let currentRound = getCurrentRoundNumber()
        
        guard currentRound < allSpies.count else { return Set<Int>() }
        return allSpies[currentRound]
    }
    
    func generateAndSetSpyIndicesForAllRounds() {
        guard let session = getCurrentGameSession() else { return }
        
        let playerCount = Int(session.playerCount)
        let spyCount = Int(session.spyCount)
        let expectedRoundCount = Int(session.roundCount) // user wants this many
        
        let actualRounds = (session.rounds as? Set<Round>) ?? Set<Round>() // Already created rounds. can be lower ewhen there is less cat. values.
        let actualRoundCount = actualRounds.count
        
        print("[DEBUG] Expected rounds: \(expectedRoundCount), Actual rounds: \(actualRoundCount)")
        
        let roundCountToUse = actualRoundCount
        
        var spiesPerRound: [Set<Int>] = []
        
        for roundIndex in 0..<roundCountToUse {
            var roundSpies = Set<Int>()
            var available = Array(0..<playerCount)
            
            for _ in 0..<spyCount {
                guard !available.isEmpty else { break }
                let rand = Int.random(in: 0..<available.count)
                roundSpies.insert(available[rand])
                available.remove(at: rand)
            }
            spiesPerRound.append(roundSpies)
            print("[DEBUG] Generated spies for round \(roundIndex + 1): \(roundSpies.sorted())")
        }
    
        session.spyIndicesArray = spiesPerRound.map { Array($0) }
        
        let sortedRounds = actualRounds.sorted { $0.roundNumber < $1.roundNumber }
        
        for (index, round) in sortedRounds.enumerated() {
            if index < spiesPerRound.count {
                round.spyIndices = spiesPerRound[index]
                print("[DEBUG] Round \(index + 1) spies assigned: \(spiesPerRound[index].sorted())")
            } else {
                print("[WARNING] Round \(index + 1) has no spy indices - using empty set")
                round.spyIndices = Set<Int>()
            }
        }
        
        saveContext()
        print("[DEBUG] Spy indices generation completed for \(roundCountToUse) rounds")
    }
    
    // MARK: - Game Progress
    
    func isGameComplete() -> Bool {
        guard let session = getCurrentGameSession() else { return true }
        return session.currentRound >= session.roundCount
    }
    
    func getGameProgress() -> (currentRound: Int, totalRounds: Int) {
        guard let session = getCurrentGameSession() else { return (0, 0) }
        return (Int(session.currentRound) + 1, Int(session.roundCount))
    }
    
    // MARK: - Cleanup & Maintenance
    
    func clearOldSessionsAndStartFresh() {
        print("========== CLEARING OLD SESSIONS ==========")
        
        deleteAllCustomSessions()
        
        let sessionFetch: NSFetchRequest<GameSession> = GameSession.fetchRequest()
        sessionFetch.predicate = NSPredicate(format: "isDefault == YES")
        
        let defaultSessions = performFetch(sessionFetch)
        for session in defaultSessions {
            if let category = session.category, !Constants.defaultCategories.contains(category.lowercased()) {
                print("Removing default session with old category: '\(category)'")
                context.delete(session)
            }
        }
        saveContext()
        createDefaultSession(category: "travel")
        
        print("Created fresh session with 'travel' category")
        print("==========================================")
    }
}

// MARK: - Debug Utilities

extension GameStateManager {
    
    func printGameState(_ event: String) {
        print("========== GAME STATE: \(event) ==========")
        
        guard let session = getCurrentGameSession() else {
            print("No current game session found")
            return
        }
        
        let players = getCurrentPlayers()
        let (spyIndices, foundSpyIndices, blamedCivilianIndices, winnerType, isCompleted) = getRoundState()
        
        print("Current Round: \(session.currentRound + 1)/\(session.roundCount)")
        print("Category: \(session.category ?? "Unknown")")
        print("Spy Indices: \(Array(spyIndices).sorted())")
        print("Found Spies: \(Array(foundSpyIndices).sorted())")
        print("Blamed Civilians: \(Array(blamedCivilianIndices).sorted())")
        print("Winner: \(winnerType?.rawValue ?? "TBD")")
        print("Round Completed: \(isCompleted)")
        
        print("Player Scores:")
        for (index, player) in players.enumerated() {
            let role = spyIndices.contains(index) ? "SPY" : "CIVILIAN"
            print("  Player \(index + 1) (\(player.name ?? "Unknown")) - \(role): \(player.score) points")
        }
        
        print("==========================================")
    }
    
    func debugPrintSessions() {
        let defaultSessions = getDefaultSessions()
        let customSessions = getCustomSessions()
        
        print("========== GAME SESSIONS ==========")
        print("-- Default Sessions (\(defaultSessions.count)) --")
        for (idx, session) in defaultSessions.enumerated() {
            print("[Default #\(idx+1)] " + formatSession(session))
        }
        print("-- Custom Sessions (\(customSessions.count)) --")
        for (idx, session) in customSessions.enumerated() {
            print("[Custom #\(idx+1)] " + formatSession(session))
        }
        print("===================================")
    }
    
    func debugCategoriesAndSessions() {
        print("========== DEBUG CATEGORIES AND SESSIONS ==========")
        
        // Check available categories
        let categoryFetch: NSFetchRequest<Category> = Category.fetchRequest()
        let categories = performFetch(categoryFetch)
        print("Available categories in database:")
        for category in categories {
            let wordCount = (category.words as? Set<Word>)?.count ?? 0
            print("  - '\(category.name ?? "nil")' (\(wordCount) words)")
        }
        
        // Check current sessions
        let sessionFetch: NSFetchRequest<GameSession> = GameSession.fetchRequest()
        let sessions = performFetch(sessionFetch)
        print("Current game sessions:")
        for session in sessions {
            let roundCount = (session.rounds as? Set<Round>)?.count ?? 0
            print("  - Session \(session.id?.uuidString ?? "nil"): category='\(session.category ?? "nil")' (\(roundCount) rounds)")
        }
        
        print("================================================")
    }
    
    private func formatSession(_ session: GameSession) -> String {
        let idString = session.id?.uuidString ?? "nil"
        let category = session.category ?? "nil"
        return "id: \(idString) | category: \(category) | playerCount: \(session.playerCount) | roundCount: \(session.roundCount) | roundDuration: \(session.roundDuration) | spyCount: \(session.spyCount) | currentRound: \(session.currentRound) | isDefault: \(session.isDefault) | isHintAvaible: \(session.isHintAvaible)"
    }
}
