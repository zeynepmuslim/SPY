import Foundation
import CoreData

// MARK: - CountdownModel
class CountdownModel {
    
    // MARK: - Properties
    private let gameStateManager = GameStateManager.shared
    private(set) var players: [Player] = []
    private(set) var spyIndices: Set<Int> = []
    private(set) var foundSpyIndices: Set<Int> = []
    private(set) var blamedCivilianIndices: Set<Int> = []
    private(set) var numberOfPlayers: Int = 0
    private(set) var category: String = ""
    private(set) var roundDuration: String = "2"
    private(set) var roundCount: String = ""
    private(set) var isHintAvailable: Bool = true
    private(set) var hints: [String] = []
    
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
        
        self.numberOfPlayers = Int(session.playerCount)
        self.category = session.category ?? ""
        self.roundDuration = String(session.roundDuration)
        self.roundCount = String(session.roundCount)
        self.isHintAvailable = session.isHintAvaible
        
        if self.isHintAvailable {
            self.hints = HintManager.shared.getHints(forCategory: self.category)
        }
        
        self.players = gameStateManager.getCurrentPlayers()
        
        let roundState = gameStateManager.getRoundState()
        self.spyIndices = roundState.spyIndices
        self.foundSpyIndices = roundState.foundSpyIndices
        self.blamedCivilianIndices = roundState.blamedCivilianIndices
    }
    
    // MARK: - Game State Queries
    func isPlayerSpy(_ playerIndex: Int) -> Bool {
        return spyIndices.contains(playerIndex)
    }
    
    func isPlayerDeactivated(_ playerIndex: Int) -> Bool {
        return foundSpyIndices.contains(playerIndex) || blamedCivilianIndices.contains(playerIndex)
    }
    
    func getPlayerName(at index: Int) -> String {
        guard index < players.count else {
            return String(format: "player_x".localized, index + 1)
        }
        return players[index].name ?? String(format: "player_x".localized, index + 1)
    }
    
    // MARK: - Game Logic
    func processPlayerBlame(selectedPlayerIndex: Int) -> BlameResult {
        let playerNumber = selectedPlayerIndex + 1
        let isSpy = spyIndices.contains(selectedPlayerIndex)
        
        if isSpy {
            foundSpyIndices.insert(selectedPlayerIndex)
            print("Spy found! Found spies: \(foundSpyIndices). Total spies: \(spyIndices.count)")
            
            if foundSpyIndices.count == spyIndices.count {
                // All spies found - Civilian victory
                applyCivilianVictoryScoring()
                updateRoundState(winnerType: .civilians, isCompleted: true)
                return .allSpiesFound(playerNumber: playerNumber)
            } else {
                // Spy found but game continues
                updateRoundState()
                return .spyFound(playerNumber: playerNumber)
            }
        } else {
            // Civilian blamed
            blamedCivilianIndices.insert(selectedPlayerIndex)
            applyFalseAccusationScoring()
            
            // Check if spies won (all civilians blamed)
            let unfoundSpies = spyIndices.subtracting(foundSpyIndices)
            let deactivatedIndices = foundSpyIndices.union(blamedCivilianIndices)
            let allIndices = Set(0..<numberOfPlayers)
            let activeIndices = allIndices.subtracting(deactivatedIndices)
            
            if activeIndices == unfoundSpies && !unfoundSpies.isEmpty {
                // Spies won
                applySpyVictoryScoring()
                updateRoundState(winnerType: .spies, isCompleted: true)
                return .spiesWon(playerNumber: playerNumber)
            } else {
                // Game continues
                updateRoundState()
                return .civilianBlamed(playerNumber: playerNumber)
            }
        }
    }
    
    func processTimeUp() -> GameEndResult {
        applySpyVictoryScoring()
        updateRoundState(winnerType: .timeout, isCompleted: true)
        return .timeUp
    }
    
    // MARK: - Round State Management
    private func updateRoundState(winnerType: WinnerType? = nil, isCompleted: Bool = false) {
        gameStateManager.updateRoundState(
            spyIndices: spyIndices,
            foundSpyIndices: foundSpyIndices,
            blamedCivilianIndices: blamedCivilianIndices,
            winnerType: winnerType,
            isCompleted: isCompleted
        )
    }
    
    // MARK: - Scoring Methods
    private func applyFalseAccusationScoring() {
        print("========== FALSE ACCUSATION SCORING ==========")
        
        let survivingSpies = spyIndices.subtracting(foundSpyIndices)
        let allCivilians = Set(0..<numberOfPlayers).subtracting(spyIndices)
        
        for spyIndex in survivingSpies {
            if spyIndex < players.count {
                let oldScore = players[spyIndex].score
                players[spyIndex].score += 1
                printScoreChange("False Accusation - Spy Gains", playerIndex: spyIndex, oldScore: oldScore, newScore: players[spyIndex].score)
            }
        }
        
        for civilianIndex in allCivilians {
            if civilianIndex < players.count {
                let oldScore = players[civilianIndex].score
                players[civilianIndex].score -= 1
                printScoreChange("False Accusation - Civilian Loses", playerIndex: civilianIndex, oldScore: oldScore, newScore: players[civilianIndex].score)
            }
        }
        
        GameStateManager.shared.saveContext()
        gameStateManager.printGameState("After False Accusation")
    }
    
    private func applyCivilianVictoryScoring() {
        print("========== CIVILIAN VICTORY SCORING ==========")
        
        let allCivilians = Set(0..<numberOfPlayers).subtracting(spyIndices)
        let aliveCivilians = allCivilians.subtracting(blamedCivilianIndices)
        let aliveCivilianCount = aliveCivilians.count
        
        print("Alive civilians count: \(aliveCivilianCount)")
        
        for civilianIndex in aliveCivilians {
            if civilianIndex < players.count {
                let oldScore = players[civilianIndex].score
                players[civilianIndex].score += Int16(aliveCivilianCount)
                printScoreChange("Civilian Victory", playerIndex: civilianIndex, oldScore: oldScore, newScore: players[civilianIndex].score)
            }
        }
        
        GameStateManager.shared.saveContext()
        gameStateManager.printGameState("After Civilian Victory")
    }
    
    private func applySpyVictoryScoring() {
        print("========== SPY VICTORY SCORING ==========")
        
        let survivingSpies = spyIndices.subtracting(foundSpyIndices)
        let totalPlayers = numberOfPlayers
        
        print("Surviving spies count: \(survivingSpies.count), Total players: \(totalPlayers)")
        
        for spyIndex in survivingSpies {
            if spyIndex < players.count {
                let oldScore = players[spyIndex].score
                players[spyIndex].score += Int16(totalPlayers)
                printScoreChange("Spy Victory", playerIndex: spyIndex, oldScore: oldScore, newScore: players[spyIndex].score)
            }
        }
        
        GameStateManager.shared.saveContext()
        gameStateManager.printGameState("After Spy Victory")
    }
    
    private func printScoreChange(_ event: String, playerIndex: Int, oldScore: Int16, newScore: Int16) {
        let player = players[playerIndex]
        let role = spyIndices.contains(playerIndex) ? "SPY" : "CIVILIAN"
        let change = newScore - oldScore
        let changeStr = change >= 0 ? "+\(change)" : "\(change)"
        print("SCORE CHANGE - \(event): Player \(playerIndex + 1) (\(player.name ?? "Unknown")) - \(role): \(oldScore) → \(newScore) (\(changeStr))")
    }
}

// MARK: - Result Types
enum BlameResult {
    case spyFound(playerNumber: Int)
    case allSpiesFound(playerNumber: Int)
    case civilianBlamed(playerNumber: Int)
    case spiesWon(playerNumber: Int)
    
    var shouldEndGame: Bool {
        switch self {
        case .allSpiesFound, .spiesWon:
            return true
        case .spyFound, .civilianBlamed:
            return false
        }
    }
    
    var endMessage: String? {
        switch self {
        case .allSpiesFound:
            return "ALL_SPIES_FOUND".localized
        case .spiesWon:
            return "SPIES_WON".localized
        case .spyFound, .civilianBlamed:
            return nil
        }
    }
    
    func getPointsDisplayInfo() -> (title: String, showCivilianPoints: Bool, showSpyPoints: Bool) {
        switch self {
        case .spyFound(let playerNumber):
            return (
                title: String(format: "player_was_a_spy".localized, playerNumber).uppercased(),
                showCivilianPoints: false,
                showSpyPoints: true
            )
        case .allSpiesFound:
            return (
                title: "ALL_SPIES_FOUND".localized.uppercased(),
                showCivilianPoints: false,
                showSpyPoints: false
            )
        case .civilianBlamed(let playerNumber):
            return (
                title: String(format: "player_was_a_civilian".localized, playerNumber).uppercased(),
                showCivilianPoints: true,
                showSpyPoints: true
            )
        case .spiesWon:
            return (
                title: "SPIES_WON".localized.uppercased(),
                showCivilianPoints: false,
                showSpyPoints: false
            )
        }
    }
}

enum GameEndResult {
    case timeUp
    
    var endMessage: String {
        switch self {
        case .timeUp:
            return "TIME_UP_AGENTS_WIN".localized
        }
    }
}
