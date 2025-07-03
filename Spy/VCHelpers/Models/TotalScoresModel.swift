import Foundation
import CoreData
import UIKit

// MARK: - TotalScoresModel
class TotalScoresModel {
    
    // MARK: - Properties
    private let gameStateManager = GameStateManager.shared
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private let fetchRequest: NSFetchRequest<GameSession> = GameSession.fetchRequest()
    
    private(set) var playerScores: [PlayerScore] = []
    private(set) var players: [Player] = []
    
    // MARK: - Constants
    enum Constants {
        static let bigMargin: CGFloat = GeneralConstants.Layout.bigMargin
        static let littleMargin: CGFloat = GeneralConstants.Layout.littleMargin
        static let buttonsHeight: CGFloat = GeneralConstants.Button.biggerHeight
    }
    
    // MARK: - Initialization
    init() {
        fetchPlayers()
        calculateScores()
    }
    
    // MARK: - Data Fetching
    func fetchPlayers() {
        self.players = gameStateManager.getCurrentPlayers()
    }
    
    func fetchGameSession() {
        fetchRequest.predicate = NSPredicate(format: "isDefault == %@", NSNumber(value: false))
        do {
            let sessions = try context.fetch(fetchRequest)
            for session in sessions {
                context.delete(session)
            }
            try context.save()
            for session in sessions {
                print(session)
            }
        } catch {
            print(error)
        }
    }
    
    // MARK: - Score Calculation
    func calculateScores() {
        playerScores = []
        
        for (index, player) in players.enumerated() {
            let playerScore = PlayerScore(
                id: index + 1,
                name: player.name ?? String(format: "default_player_name".localized, index + 1),
                score: Int(player.score)
            )
            playerScores.append(playerScore)
        }
        
        playerScores.sort { $0.score > $1.score }
        
        print("--- TotalScoresViewController Final Scores (Sorted) ---")
        for (rank, playerScore) in playerScores.enumerated() {
            print("Rank \(rank + 1): \(playerScore.name) - \(playerScore.score) points")
        }
        print("-----------------------------------------------------")
    }
    
    // MARK: - Score Display Logic
    func printFinalScores() {
        print("========== FINAL GAME SCORES ==========")
        for (index, playerScore) in playerScores.enumerated() {
            let rank = index + 1
            print("Rank \(rank): \(playerScore.name) - \(playerScore.score) points")
        }
        print("=======================================")
    }
    
    // MARK: - Table View Configuration
    func getNumberOfPlayers() -> Int {
        return playerScores.count
    }
    
    func getPlayerScore(at index: Int) -> PlayerScore {
        return playerScores[index]
    }
    
    func getRankEmoji(for rank: Int) -> String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "\(rank)."
        }
    }
    
    func getScoreText(for playerScore: PlayerScore) -> String {
        return String(format: "player_score_text".localized, playerScore.name, playerScore.score)
    }
    
    // MARK: - Cell Styling Configuration
    func getCellStyling(for rank: Int) -> (font: UIFont, color: UIColor) {
        switch rank {
        case 1:
            return (UIFont.systemFont(ofSize: 22, weight: .bold), .systemYellow)
        case 2:
            return (UIFont.systemFont(ofSize: 20, weight: .bold), .systemGray)
        case 3:
            return (UIFont.systemFont(ofSize: 19, weight: .semibold), .systemOrange)
        default:
            return (UIFont.systemFont(ofSize: 18, weight: .regular), .white)
        }
    }
    
    // MARK: - Game State Management
    func performGameCleanup() {
        fetchGameSession()
        printFinalScores()
        gameStateManager.printGameState("Game Complete - Final Scores")
    }
} 