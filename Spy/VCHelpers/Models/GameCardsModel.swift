import Foundation
import CoreData
import UIKit

// MARK: - GameCardsModel
class GameCardsModel {
    
    // MARK: - Properties
    private let gameStateManager = GameStateManager.shared
    private(set) var playerCount: Int = 0
    private(set) var spyCount: Int = 0
    private(set) var spyIndices: Set<Int> = []
    private(set) var category: String = ""
    private(set) var roundDuration: String = ""
    private(set) var roundCount: String = ""
    private(set) var showHints: Bool = false
    private(set) var players: [Player] = []
    private(set) var rounds: [Round] = []
    private(set) var selectedWordForCurrentRound: String = ""
    
    // MARK: - Initialization
    init() {
        fetchGameData()
    }
    
    // MARK: - Data Fetching
    private func fetchGameData() {
        guard let session = gameStateManager.getCurrentGameSession() else {
            print("Error: No current game session found")
            return
        }
        
        self.playerCount = Int(session.playerCount)
        self.spyCount = Int(session.spyCount)
        self.category = session.category ?? ""
        self.roundDuration = String(session.roundDuration)
        self.roundCount = String(session.roundCount)
        self.showHints = session.isHintAvaible
        
        self.players = gameStateManager.getCurrentPlayers()
        self.playerCount = players.count
        
        print("========== DEBUGGING WORD SELECTION ==========")
        print("Session category: \(self.category)")
        print("Session round count: \(self.roundCount)")
        print("Session ID: \(session.id?.uuidString ?? "nil")")
        
        if let sessionRounds = session.rounds as? Set<Round> {
            self.rounds = sessionRounds.sorted { $0.roundNumber < $1.roundNumber }
            
            print("Found \(self.rounds.count) rounds")
            for (idx, r) in self.rounds.enumerated() {
                print("[DEBUG] Round \(idx+1): word='\(r.selectedWord ?? "nil")' roundNumber=\(r.roundNumber)")
            }
        } else {
            print("No rounds found in session")
            self.rounds = []
        }
        
        let currentRound = gameStateManager.getCurrentRoundNumber()
        print("Current round number: \(currentRound)")
        self.spyIndices = gameStateManager.getSpyIndicesForCurrentRound()
        
        if currentRound < rounds.count {
            self.selectedWordForCurrentRound = rounds[currentRound].selectedWord ?? ""
            print("Selected word from round: '\(selectedWordForCurrentRound)'")
        } else {
            print("Warning: Current round (\(currentRound)) >= rounds count (\(rounds.count))")
            self.selectedWordForCurrentRound = ""
        }
        
        // Fallback: If no word is found, try to get a random word from the category
        if selectedWordForCurrentRound.isEmpty {
            print("Warning: No word found for current round. Attempting fallback...")
            selectedWordForCurrentRound = getRandomWordFromCategory(categoryName: self.category)
            print("Fallback word: '\(selectedWordForCurrentRound)'")
        }
        
        print("Final selected word: '\(selectedWordForCurrentRound)'")
        print("=============================================")
        
        let currentRoundNumber = gameStateManager.getCurrentRoundNumber()
        if currentRoundNumber == 0 {
            initializePlayerScores()
        }
        
        updatePlayersSpyStatus()
        gameStateManager.printGameState("Round \(currentRoundNumber + 1) Start")
    }
    
    // MARK: - Game Logic
    private func getRandomWordFromCategory(categoryName: String) -> String {
        print("Fallback: Looking for category '\(categoryName)'")
        return CategorySearchUtility.getRandomWordFromCategory(categoryName: categoryName)
    }
    
    private func initializePlayerScores() {
        for player in players {
            player.score = 0
        }
        
        GameStateManager.shared.saveContext()
        print("========== GAME START - SCORES INITIALIZED ==========")
        gameStateManager.printGameState("Game Start")
    }
    
    private func updatePlayersSpyStatus() {
        guard players.count == playerCount else {
            print("Error: Player count mismatch. Expected \(playerCount), found \(players.count).")
            return
        }
        
        for player in players {
            player.isSpy = false
        }
        
        for index in spyIndices {
            if index < players.count {
                players[Int(index)].isSpy = true
            }
        }
        
        GameStateManager.shared.saveContext()
    }
    
    // MARK: - Game State Queries
    func isPlayerSpy(at index: Int) -> Bool {
        return spyIndices.contains(index)
    }
    
    func getPlayerName(at index: Int) -> String {
        if index < players.count {
            return players[index].name ?? String(format: "player_x".localized, index + 1)
        } else {
            return String(format: "player_x".localized, index + 1)
        }
    }
    
    func getCardConfiguration(for index: Int) -> GameCardConfiguration {
        let isSpy = isPlayerSpy(at: index)
        let playerName = getPlayerName(at: index)
        
        return GameCardConfiguration(
            role: playerName,
            selectedWord: selectedWordForCurrentRound,
            isSpy: isSpy
        )
    }
}

// MARK: - Result Types
struct GameCardConfiguration {
    let role: String
    let selectedWord: String
    let isSpy: Bool
}
