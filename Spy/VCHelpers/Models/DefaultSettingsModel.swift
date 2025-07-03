//
//  DefaultSettingsModel.swift
//  Spy
//
//  Created by Zeynep Müslim on 8.04.2025.
//

import UIKit

// MARK: - Default Settings Constants
enum DefaultSettingsConstants {
    static let bigMargin: CGFloat = GeneralConstants.Layout.bigMargin
    static let littleMargin: CGFloat = GeneralConstants.Layout.littleMargin
    static let buttonsHeight: CGFloat = GeneralConstants.Button.miniHeight
}

// MARK: - Game Session Values
struct GameSessionValues {
    let playerCount: Int
    let spyCount: Int
    let category: String
    let roundDuration: String
    let roundCount: String
    let showHints: Bool
}

// MARK: - Default Settings UI Manager
class DefaultSettingsUIManager {
    
    // MARK: - Button Creation
    static func createSaveDefaultButton(target: DefaultSettingsViewController) -> CustomGradientButton {
        let button = CustomGradientButton(
            labelText: "save_as_default".localized, 
            width: 100,
            height: GeneralConstants.Button.biggerHeight
        )
        
        button.onClick = { [weak target] in
            guard let target = target else { return }
            target.handleSaveDefaultAction()
        }
        return button
    }
    
    static func createCustomizeButton(target: DefaultSettingsViewController) -> CustomGradientButton {
        let button = CustomGradientButton(
            labelText: "customize".localized,
            width: 200,
            height: DefaultSettingsConstants.buttonsHeight,
            fontSize: GeneralConstants.Font.size01
        )
        
        button.onClick = { [weak target] in
            guard let target = target else { return }
            target.handleCustomizeAction()
        }
        return button
    }
}

// MARK: - Default Settings Data Manager
class DefaultSettingsDataManager {
    
    static func loadDefaultSessionValues() -> GameSessionValues? {
        let defaultSessions = GameStateManager.shared.getDefaultSessions()
        guard let defaultSession = defaultSessions.first else { return nil }
        
        print("Default Game Session Values:")
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
    
    static func saveDefaultSessionValues(_ values: GameSessionValues) {
        PlayerManager.shared.updateDefaultPlayerCount(to: values.playerCount)
        
        let defaultSessions = GameStateManager.shared.getDefaultSessions()
        if let defaultSession = defaultSessions.first {
            GameStateManager.shared.updateDefaultSession(
                defaultSession,
                category: values.category,
                playerCount: Int16(values.playerCount),
                roundCount: Int16(values.roundCount) ?? 5,
                roundDuration: Int16(values.roundDuration) ?? 2,
                spyCount: Int16(values.spyCount),
                isHintAvaible: values.showHints
            )
        } else {
            GameStateManager.shared.createDefaultSession(
                category: values.category,
                playerCount: Int16(values.playerCount),
                roundCount: Int16(values.roundCount) ?? 5,
                roundDuration: Int16(values.roundDuration) ?? 2,
                spyCount: Int16(values.spyCount),
                isHintAvaible: values.showHints
            )
        }
        
        print("Default Settings Updated:")
        print("Total Players: \(values.playerCount)")
        print("Spy Count: \(values.spyCount)")
        print("Category: \(values.category)")
        print("Round Duration: \(values.roundDuration)")
        print("Round Count: \(values.roundCount)")
        print("Show Hints: \(values.showHints)")
    }
}

// MARK: - Settings Group Factory
class DefaultSettingsGroupFactory {
    
    static func createPlayerGroups(playerCount: Int = 5, spyCount: Int = 1) -> [PlayerSettingsGroupManager.PlayerGroup] {
        return [
            PlayerSettingsGroupManager.PlayerGroup(
                title: "player_count".localized,
                index: 0,
                minSpyCount: 1,
                maxSpyCount: 10,
                initialValue: playerCount
            ),
            PlayerSettingsGroupManager.PlayerGroup(
                title: "spy_count".localized,
                index: 1,
                buttonBorderColor: .red,
                buttonShadow: .red,
                buttonColor: .red,
                minSpyCount: 1,
                maxSpyCount: 3,
                initialValue: spyCount
            )
        ]
    }
    
    static func createSettingsGroups(
        target: DefaultSettingsViewController,
        category: String = "basic",
        roundDuration: Int = 3,
        roundCount: Int = 5,
        showHints: Bool = true
    ) -> [GameSettingsGroupManager.SettingsGroup] {
        return [
            GameSettingsGroupManager.createCategoryGroup(
                target: target,
                action: { [weak target] in
                    target?.performSegue(withIdentifier: "DefaultSettingsToCategories", sender: target)
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
class DefaultSettingsSegueHandler {
    
    static func prepareForSegue(_ segue: UIStoryboardSegue, sender: Any?, from viewController: DefaultSettingsViewController) {
        if segue.identifier == "DefaultSettingsToCategories" {
            if let destinationVC = segue.destination as? CustomCategoriesViewController {
                destinationVC.unwindSegueIdentifier = "unwindToDefaultSettings"
                destinationVC.isDefaultMode = true
                print("Setting unwind identifier for CustomCategoriesVC: unwindToDefaultSettings (Default mode)")
            }
        } else if segue.identifier == "DefaultSettingsToCustomPlayers" {
            if let destinationVC = segue.destination as? CustomPlayersViewController {
                let playerCount = viewController.playerGroup?.imageViews.count ?? 0
                destinationVC.configure(playerCount: playerCount, isDefault: true)
                destinationVC.unwindSegueIdentifier = "unwindToDefaultSettings"
                print("Setting unwind identifier for CustomPlayersVC: unwindToDefaultSettings")
            }
        }
    }
    
    static func handleUnwindSegue(_ segue: UIStoryboardSegue, for viewController: DefaultSettingsViewController) {
        print("Returned to Default Settings from: \(segue.source.description)")
        
        if let sourceVC = segue.source as? CustomPlayersViewController {
            let playerCount = sourceVC.playerCount
            print("Received playerCount from CustomPlayersViewController: \(playerCount)")
        } else if let sourceVC = segue.source as? CustomCategoriesViewController {
            let selectedCategory = sourceVC.selectedCategory
            print("Received category: \(selectedCategory)")
            viewController.updateCategoryInSettingsGroup(selectedCategory)
        }
    }
}

// MARK: - DefaultSettingsViewController Extension
extension DefaultSettingsViewController {
    
    func handleSaveDefaultAction() {
        let gameValues = getCurrentGameSessionValues()
        DefaultSettingsDataManager.saveDefaultSessionValues(gameValues)
        customBackAction()
    }
    
    func handleCustomizeAction() {
        let gameValues = getCurrentGameSessionValues()
        PlayerManager.shared.updateDefaultPlayerCount(to: gameValues.playerCount)
        performSegue(withIdentifier: "DefaultSettingsToCustomPlayers", sender: self)
    }
    
    func updateCategoryInSettingsGroup(_ selectedCategory: String) {
        if settingsGroups.indices.contains(0) {
            settingsGroups[0].value = selectedCategory
            let categoryGroup = settingsGroups[0]
            if let categoryButton = categoryGroup.stackView.arrangedSubviews.first(where: { $0 is UIButton }) as? UIButton {
                categoryButton.setTitle(selectedCategory, for: .normal)
                print("Updated category button title to: \(selectedCategory)")
            } else if let categoryLabel = categoryGroup.stackView.arrangedSubviews.first(where: { $0 is UILabel }) as? UILabel {
                categoryLabel.text = selectedCategory
                print("Updated category label text to: \(selectedCategory)")
            } else {
                print("Could not find a UIButton or UILabel in the category group's stack view to update.")
            }
        } else {
            print("Category settings group not found at index 0.")
        }
    }
} 
