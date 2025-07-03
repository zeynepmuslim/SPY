import Foundation
import CoreData
import UIKit

// MARK: - ScoresModel
class ScoresModel {
    
    // MARK: - Properties
    private let gameStateManager = GameStateManager.shared
    
    // Game Session Data
    private(set) var numberOfChildren: Int = 0
    private(set) var category: String = ""
    private(set) var roundDuration: String = ""
    private(set) var roundCount: String = ""
    private(set) var currentRound: Int = 0
    private(set) var players: [Player] = []
    
    // Round State Data
    private(set) var spyIndices: Set<Int> = []
    private(set) var foundSpyIndices: Set<Int> = []
    private(set) var blamedCivilianIndices: Set<Int> = []
    private(set) var winnerType: WinnerType?
    
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
        
        self.numberOfChildren = Int(session.playerCount)
        self.category = session.category ?? ""
        self.roundDuration = String(session.roundDuration)
        self.roundCount = String(session.roundCount)
        self.currentRound = Int(session.currentRound)
        
        self.players = gameStateManager.getCurrentPlayers()
        
        let roundState = gameStateManager.getRoundState()
        self.spyIndices = roundState.spyIndices
        self.foundSpyIndices = roundState.foundSpyIndices
        self.blamedCivilianIndices = roundState.blamedCivilianIndices
        self.winnerType = roundState.winnerType
    }
    
    // MARK: - Winner and Word Logic
    func getWinnerText() -> String {
        switch winnerType {
        case .civilians:
            return "winner_civils".localized
        case .spies:
            return "winner_spies".localized
        case .timeout:
            return "winner_spies_times_up".localized
        case .none:
            return "winner_determining".localized
        }
    }
    
    func getSelectedWordText() -> String {
        let selectedWord = getSelectedWordForCurrentRound()
        return String(format: "selected_word_prefix".localized, selectedWord.localized)
    }
    
    private func getSelectedWordForCurrentRound() -> String {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            let sessionRequest: NSFetchRequest<GameSession> = GameSession.fetchRequest()
            sessionRequest.predicate = NSPredicate(format: "isDefault == %@", NSNumber(value: false))
            let sessions = try context.fetch(sessionRequest)
            if let currentSession = sessions.last,
               let sessionRounds = currentSession.rounds as? Set<Round> {
                let sortedRounds = sessionRounds.sorted { $0.roundNumber < $1.roundNumber }
                let safeRoundIndex = min(max(currentRound, 0), sortedRounds.count - 1)
                return sortedRounds[safeRoundIndex].selectedWord ?? "unknown".localized
            }
        } catch {
            print("Error fetching selected word: \(error)")
        }
        return "unknown".localized
    }
    
    // MARK: - Score Calculation
    func getCivilianPointsText() -> String {
        let aliveCivilians = Set(0..<numberOfChildren).subtracting(spyIndices).subtracting(blamedCivilianIndices)
        let allSpiesFound = foundSpyIndices.count == spyIndices.count
        
        let points = allSpiesFound ? aliveCivilians.count : 0
        return String(format: "role_point_text".localized, "civil".localized, points)
    }
    
    func getSpyPointsText() -> String {
        let allSpiesFound = foundSpyIndices.count == spyIndices.count
        let points = allSpiesFound ? 0 : numberOfChildren
        return String(format: "role_point_text".localized, "spy".localized, points)
    }
    
    // MARK: - Rounds Logic
    func getRemainingRoundsText() -> String {
        let totalRounds = Int(roundCount) ?? 1
        let remainingRounds = totalRounds - (currentRound + 1)
        
        if remainingRounds > 0 {
            return String(format: "rounds_left".localized, remainingRounds)
        } else {
            return "last_round".localized
        }
    }
    
    func hasNextRound() -> Bool {
        let totalRounds = Int(roundCount) ?? 1
        let nextRoundIndex = currentRound + 1
        return nextRoundIndex < totalRounds
    }
    
    func getNextRoundIndex() -> Int {
        return currentRound + 1
    }
    
    // MARK: - Collection View Configuration
    func determineColumns(for count: Int) -> Int {
        if count == 4 {
            return 2
        }
        return (count <= 6) ? 3 : 4
    }
    
    func shouldUseVerticalLayout() -> Bool {
        return numberOfChildren <= 6
    }
    
    // MARK: - Cell Configuration
    func getCellConfiguration(for indexPath: IndexPath) -> ScoreCellConfiguration {
        let childId = indexPath.item + 1
        let isSpy = spyIndices.contains(indexPath.item)
        let topText = isSpy ? "SPY".localized : "CIVIL".localized
        
        let playerScore = (indexPath.item < players.count) ? Int(players[indexPath.item].score) : 0
        let bottomText = String(format: "score_text".localized, playerScore)
        
        let status: ButtonStatus
        if foundSpyIndices.contains(indexPath.item) || blamedCivilianIndices.contains(indexPath.item) {
            status = .deactive
        } else {
            status = isSpy ? .activeRed : .activeBlue
        }
        
        return ScoreCellConfiguration(
            childId: childId,
            iconName: "spy-right-w",
            topLabelText: topText,
            bottomLabelText: bottomText,
            status: status,
            isSpy: isSpy
        )
    }
    
    // MARK: - Navigation Logic
    func proceedToNextStep(completion: @escaping (ScoreNavigationType) -> Void) {
        if hasNextRound() {
            gameStateManager.updateCurrentRound(to: getNextRoundIndex())
            print("Proceeding to next round (\(getNextRoundIndex() + 1)/\(roundCount)) - Performing segue to GameCards")
            completion(.nextRound)
        } else {
            print("All rounds completed – Performing segue to TotalScores")
            completion(.totalScores)
        }
    }
}

// MARK: - Supporting Types
struct ScoreCellConfiguration {
    let childId: Int
    let iconName: String
    let topLabelText: String
    let bottomLabelText: String
    let status: ButtonStatus
    let isSpy: Bool
}

enum ScoreNavigationType {
    case nextRound
    case totalScores
} 
