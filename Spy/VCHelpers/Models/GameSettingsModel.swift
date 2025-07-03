//
//  GameSettingsModel.swift
//  Spy
//
//  Created by Zeynep Müslim on 8.04.2025.
//

import UIKit
import CoreData

// MARK: - Game Settings Constants
enum GameSettingsConstants {
    static let bigMargin: CGFloat = GeneralConstants.Layout.bigMargin
    static let littleMargin: CGFloat = GeneralConstants.Layout.littleMargin
    static let buttonsHeight: CGFloat = GeneralConstants.Button.miniHeight
}

// MARK: - Game Settings UI Manager
class GameSettingsUIManager {
    
    // MARK: - Button Creation
    static func createStartButton(target: GameSettingsViewController) -> CustomGradientButton {
        let button = CustomGradientButton(
            labelText: "play".localized, 
            height: GeneralConstants.Button.biggerHeight, 
            isBorderlessButton: true
        )
        button.onClick = { [weak target] in
            guard let target = target else { return }
            target.handleStartButtonAction()
        }
        return button
    }
    
    static func createCustomizeButton(target: GameSettingsViewController) -> CustomGradientButton {
        let button = CustomGradientButton(
            labelText: "customize".localized, 
            height: GameSettingsConstants.buttonsHeight, 
            fontSize: GeneralConstants.Font.size01
        )
        button.onClick = { [weak target] in
            guard let target = target else { return }
            target.handleCustomizeButtonAction()
        }
        return button
    }
}

// MARK: - Game Settings Data Manager
class GameSettingsDataManager {
    
    static let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // MARK: - Default Values Loading
    static func loadDefaultSessionValues() -> GameSessionValues? {
        let defaultSessions = GameStateManager.shared.getDefaultSessions()
        guard let defaultSession = defaultSessions.first else {
            print("No default session found, using default values")
            return nil
        }
        
        print("Loading Default Game Session Values:")
        print("Category: \(defaultSession.category ?? "N/A")")
        print("Player Count: \(defaultSession.playerCount)")
        print("Spy Count: \(defaultSession.spyCount)")
        print("Round Count: \(defaultSession.roundCount)")
        print("Round Duration: \(defaultSession.roundDuration)")
        print("Show Hints: \(defaultSession.isHintAvaible)")
        
        return GameSessionValues(
            playerCount: Int(defaultSession.playerCount),
            spyCount: Int(defaultSession.spyCount),
            category: defaultSession.category ?? "basic",
            roundDuration: String(defaultSession.roundDuration),
            roundCount: String(defaultSession.roundCount),
            showHints: defaultSession.isHintAvaible
        )
    }
    
    // MARK: - Current Game Session Values
    static func getCurrentGameSessionValues(
        from playerGroups: [PlayerSettingsGroupManager.PlayerGroup],
        and settingsGroups: [GameSettingsGroupManager.SettingsGroup]
    ) -> GameSessionValues {
        
        let playerCount = playerGroups.first?.imageViews.count ?? 0
        let spyCount = playerGroups.last?.imageViews.count ?? 0
        
        var category = ""
        var roundDuration = ""
        var roundCount = ""
        var showHints = false
        
        for (index, group) in settingsGroups.enumerated() {
            switch index {
            case 0:
                category = String(describing: group.value)
            case 1:
                roundDuration = String(describing: group.value)
            case 2:
                roundCount = String(describing: group.value)
            case 3:
                showHints = group.switchButton?.isOn ?? false
            default:
                break
            }
        }
        
        return GameSessionValues(
            playerCount: playerCount,
            spyCount: spyCount,
            category: category,
            roundDuration: roundDuration,
            roundCount: roundCount,
            showHints: showHints
        )
    }
    
    // MARK: - Game Session Creation
    static func saveGameSessionAndCreateRounds(with values: GameSessionValues, customPlayerNames: [String]?) {
        setupPlayersForNewGame(playerCount: values.playerCount, customPlayerNames: customPlayerNames)
        
        // Save game session
        let newGameSession = GameSession(context: context)
        newGameSession.id = UUID()
        newGameSession.playerCount = Int16(values.playerCount)
        newGameSession.spyCount = Int16(values.spyCount)
        newGameSession.category = values.category
        newGameSession.roundDuration = Int16(values.roundDuration) ?? 2
        newGameSession.roundCount = Int16(values.roundCount) ?? 8
        newGameSession.isHintAvaible = values.showHints
        newGameSession.isDefault = false
        newGameSession.currentRound = 0
        
        GameStateManager.shared.saveContext()
        createRounds(for: newGameSession)
    }
    
    // MARK: - Player Setup
    private static func setupPlayersForNewGame(playerCount: Int, customPlayerNames: [String]?) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Player.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isDefault == FALSE")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
        } catch {
            print("Error deleting old players: \(error)")
        }
        
        let namesToUse = customPlayerNames ?? (0..<playerCount).map { String(format: "player_x".localized, $0 + 1) }
        
        for i in 0..<playerCount {
            let player = Player(context: context)
            player.id = UUID()
            player.name = (i < namesToUse.count) ? namesToUse[i] : String(format: "player_x".localized, i + 1)
            player.score = 0
            player.isSpy = false
            player.isDefault = false
            player.createdAt = Date().addingTimeInterval(TimeInterval(i))
        }
        
        GameStateManager.shared.saveContext()
        print("\(playerCount) new players created.")
    }
    
    // MARK: - Round Creation
    private static func createRounds(for session: GameSession) {
        let categoryName = session.category ?? ""
        let requestedRoundCount = Int(session.roundCount)
        
        print("========== CREATING ROUNDS DEBUG ==========")
        print("Category name: '\(categoryName)'")
        print("Requested round count: \(requestedRoundCount)")
        
        guard let categoryEntity = CategorySearchUtility.findCategory(by: categoryName) else {
            print("Category '\(categoryName)' not found with any search strategy")
            CategorySearchUtility.printAllCategories()
            print("=========================================")
            return
        }
        
        print("Found category entity: '\(categoryEntity.name ?? "nil")'")
        
        guard let wordsSet = categoryEntity.words as? Set<Word>, !wordsSet.isEmpty else {
            print("No words found for category \(categoryName)")
            print("=========================================")
            return
        }
        
        var wordsArray = Array(wordsSet)
        print("Found \(wordsArray.count) words in category")
        wordsArray.shuffle()
        
        var selectedWords: [Word] = []
        
        if wordsArray.count >= requestedRoundCount {
            selectedWords = Array(wordsArray.prefix(requestedRoundCount))
            print("Selected \(selectedWords.count) words from \(wordsArray.count) available words")
        } else {
            selectedWords = []
            for _ in 0..<requestedRoundCount {
                let randomWord = wordsArray.randomElement()!
                selectedWords.append(randomWord)
            }
            print("Randomly selected \(selectedWords.count) words from \(wordsArray.count) available words")
            print("Words will be reused randomly: \(requestedRoundCount > wordsArray.count)")
        }
        
        if let existingRounds = session.rounds as? Set<Round> {
            print("Deleting \(existingRounds.count) existing rounds")
            for round in existingRounds { context.delete(round) }
        }
        
        for (index, word) in selectedWords.enumerated() {
            let round = Round(context: context)
            round.id = UUID()
            round.selectedWord = word.text ?? ""
            round.roundNumber = Int16(index)
            round.session = session
            print("Created round \(index): word='\(round.selectedWord ?? "nil")'")
        }
        
        GameStateManager.shared.saveContext()
        print("Created \(selectedWords.count) rounds for session \(session.id?.uuidString ?? "")")
        GameStateManager.shared.generateAndSetSpyIndicesForAllRounds()
        
        print("=========================================")
    }
}

// MARK: - Settings Group Factory
class GameSettingsGroupFactory {
    
    static func createPlayerGroups(playerCount: Int = 5, spyCount: Int = 1) -> [PlayerSettingsGroupManager.PlayerGroup] {
        return [
            PlayerSettingsGroupManager.PlayerGroup(
                title: "player_count_static".localized,
                index: 0,
                minSpyCount: 1,
                maxSpyCount: 10,
                initialValue: playerCount
            ),
            PlayerSettingsGroupManager.PlayerGroup(
                title: "spy_count_static".localized,
                index: 1,
                buttonBorderColor: .red,
                buttonShadow: .red,
                buttonColor: .red,
                minSpyCount: 1,
                maxSpyCount: 3,
                initialValue: spyCount
            ),
        ]
    }
    
    static func createSettingsGroups(
        target: GameSettingsViewController,
        category: String = "basic",
        roundDuration: Int = 3,
        roundCount: Int = 5,
        showHints: Bool = true
    ) -> [GameSettingsGroupManager.SettingsGroup] {
        return [
            GameSettingsGroupManager.createCategoryGroup(
                target: target,
                action: { [weak target] in
                    target?.performSegue(withIdentifier: "GameSettingsToCategories", sender: target)
                },
                initialCategory: category
            ),
            GameSettingsGroupManager.createRoundDurationGroup(
                target: target,
                initialDuration: roundDuration
            ),
            GameSettingsGroupManager.createRoundCountGroup(
                target: target,
                initialCount: roundCount
            ),
            GameSettingsGroupManager.createHintToggleGroup(
                target: target,
                initialShowHints: showHints
            )
        ]
    }
}

// MARK: - Segue Handler
class GameSettingsSegueHandler {
    
    static func prepareForSegue(
        _ segue: UIStoryboardSegue, 
        sender: Any?, 
        from viewController: GameSettingsViewController,
        playerCount: Int,
        customPlayerNames: [String]?
    ) {
        if segue.identifier == "settingsToCustomPlayers",
           let customPlayersVC = segue.destination as? CustomPlayersViewController {
            
            customPlayersVC.configure(playerCount: playerCount, customNames: customPlayerNames)
            customPlayersVC.unwindSegueIdentifier = "unwindToGameSettings"
            print("Setting unwind identifier for CustomPlayersVC: unwindToGameSettings")
            
        } else if segue.identifier == "GameSettingsToCategories" {
            if let destinationVC = segue.destination as? CustomCategoriesViewController {
                destinationVC.unwindSegueIdentifier = "unwindToGameSettings"
                destinationVC.isDefaultMode = false  
                print("Setting unwind identifier for CustomCategoriesVC: unwindToGameSettings (Game mode)")
            }
        }
    }
    
    static func handleUnwindSegue(_ segue: UIStoryboardSegue, for viewController: GameSettingsViewController) -> [String]? {
        print("Returned to Game Settings from: \(segue.source.description)")
        if let sourceVC = segue.source as? CustomPlayersViewController {
            print("Received custom player names: \(sourceVC.playerNames)")
            return sourceVC.playerNames
        }
        return nil
    }
}

// MARK: - Category Display Manager
class GameSettingsCategoryManager {
    static func updateCategoryDisplay(in settingsGroups: inout [GameSettingsGroupManager.SettingsGroup]) {
        if let defaultSession = GameStateManager.shared.getDefaultSessions().first,
           let categoryName = defaultSession.category,
           !settingsGroups.isEmpty {
            settingsGroups[0].value = categoryName
            print("Category display updated to: \(categoryName)")
        }
    }
} 
