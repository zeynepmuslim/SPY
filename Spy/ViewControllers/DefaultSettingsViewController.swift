//
//  DefaultSettingsViewController.swift
//  Spy
//
//  Created by Zeynep Müslim on 8.04.2025.
//

import UIKit
import SwiftUI

class DefaultSettingsViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    // MARK: - UI Components
    let bottomView = CustomDarkScrollView()
    let titleVCLabel = UILabel()
    
    // MARK: - Data Properties
    var playerGroups: [PlayerSettingsGroupManager.PlayerGroup] = []
    var settingsGroups: [GameSettingsGroupManager.SettingsGroup] = []
    private var selectedCategory = "basic"
    
    var playerGroup: PlayerSettingsGroupManager.PlayerGroup? {
        playerGroups.first
    }
    
    var spyGroup: PlayerSettingsGroupManager.PlayerGroup? {
        playerGroups.last
    }
    
    lazy var backButton = BackButton(target: self, action: #selector(customBackAction))
    lazy var saveDefaultButton = DefaultSettingsUIManager.createSaveDefaultButton(target: self)
    lazy var customizeButton = DefaultSettingsUIManager.createCustomizeButton(target: self)
    
    lazy var gradientView = GradientView(superView: view)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadDefaultValues()
        setupInitialUI()
        setupMainConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateCategoryDisplay()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        titleVCLabel.text = "default_settings".localized
        titleVCLabel.font = UIFont.systemFont(ofSize: GeneralConstants.Font.size05, weight: .bold)
        titleVCLabel.textColor = .spyBlue01
        titleVCLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomView.addSubview(titleVCLabel)
    }
    
    private func loadDefaultValues() {
        if let defaultValues = DefaultSettingsDataManager.loadDefaultSessionValues() {
            selectedCategory = defaultValues.category
            setupGroups(with: defaultValues)
        } else {
            print("No default session found, using default values")
            setupGroups()
        }
    }
    
    private func setupGroups(with values: GameSessionValues? = nil) {
        if let values = values {
            playerGroups = DefaultSettingsGroupFactory.createPlayerGroups(
                playerCount: values.playerCount,
                spyCount: values.spyCount
            )
            settingsGroups = DefaultSettingsGroupFactory.createSettingsGroups(
                target: self,
                category: values.category,
                roundDuration: Int(values.roundDuration) ?? 3,
                roundCount: Int(values.roundCount) ?? 5,
                showHints: values.showHints
            )
        } else {
            playerGroups = DefaultSettingsGroupFactory.createPlayerGroups()
            settingsGroups = DefaultSettingsGroupFactory.createSettingsGroups(target: self)
        }
    }
    
    private func setupInitialUI() {
        [gradientView, backButton, bottomView, saveDefaultButton].forEach {
            view.addSubview($0)
        }
        
        setupPlayerGroupsUI()
        setupSettingsGroupsUI()
        
        bottomView.addSubview(customizeButton)
    }
    
    private func setupPlayerGroupsUI() {
        var previousGroup: PlayerSettingsGroupManager.PlayerGroup?
        playerGroups.forEach { group in
            addGroupToView(group, previousGroup: previousGroup)
            previousGroup = group
        }
    }
    
    private func setupSettingsGroupsUI() {
        var lastPlayerGroup = playerGroups.last
        settingsGroups.forEach { group in
            addSettingsGroupToView(group, previousPlayerGroup: lastPlayerGroup)
            lastPlayerGroup = nil
        }
    }
    
    // MARK: - UI Helper Methods
    private func addGroupToView(_ group: PlayerSettingsGroupManager.PlayerGroup, previousGroup: PlayerSettingsGroupManager.PlayerGroup?) {
        [group.label, group.stackView, group.minusButton, group.plusButton].forEach {
            bottomView.addSubview($0)
        }
        setupGroupConstraints(group, previousGroup: previousGroup)
    }
    
    private func addSettingsGroupToView(_ group: GameSettingsGroupManager.SettingsGroup, previousPlayerGroup: PlayerSettingsGroupManager.PlayerGroup?) {
        bottomView.addSubview(group.stackView)
        setupSettingsGroupConstraints(group, previousPlayerGroup: previousPlayerGroup)
    }
    
    // MARK: - Data Management
    func getCurrentGameSessionValues() -> GameSessionValues {
        let playerCount = playerGroup?.imageViews.count ?? 0
        let spyCount = spyGroup?.imageViews.count ?? 0
        
        var category = ""
        var roundDuration = ""
        var roundCount = ""
        var showHints = false
        
        for (index, group) in settingsGroups.enumerated() {
            switch index {
            case 0: category = String(describing: group.value)
            case 1: roundDuration = String(describing: group.value)
            case 2: roundCount = String(describing: group.value)
            case 3: showHints = group.switchButton?.isOn ?? false
            default: break
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
    
    private func updateCategoryDisplay() {
        if let defaultSession = GameStateManager.shared.getDefaultSessions().first,
           let categoryName = defaultSession.category,
           let categoryGroup = settingsGroups.first {
            categoryGroup.value = categoryName
            print("Default settings category display updated to: \(categoryName)")
        }
    }
    
    // MARK: - Navigation
    @objc func customBackAction() {
        performSegue(withIdentifier: "unwindFromDefaultSettings", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        DefaultSettingsSegueHandler.prepareForSegue(segue, sender: sender, from: self)
        
        let customSegueIdentifiers = ["DefaultSettingsToCategories", "DefaultSettingsToCustomPlayers"]
        if customSegueIdentifiers.contains(segue.identifier ?? "") {
            segue.destination.modalPresentationStyle = .custom
            segue.destination.transitioningDelegate = self
        }
    }
    
    @IBAction func unwindToDefaultSettingsWithSegue(_ segue: UIStoryboardSegue) {
        DefaultSettingsSegueHandler.handleUnwindSegue(segue, for: self)
    }
    
    // MARK: - UIViewControllerTransitioningDelegate
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return StoryboardFadeToBlueUnwind()
    }
}

//// MARK: - SwiftUI Preview
//struct DefaultSettingsViewController_Previews: PreviewProvider {
//    static var previews: some View {
//        ViewControllerPreview {
//            DefaultSettingsViewController()
//        }
//    }
//}
