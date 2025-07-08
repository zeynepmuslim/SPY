import SwiftUI
import CoreData
import UIKit

class GameSettingsViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private let bottomView = CustomDarkScrollView()
    private var playerGroups: [PlayerSettingsGroupManager.PlayerGroup] = []
    private var settingsGroups: [GameSettingsGroupManager.SettingsGroup] = []
    
    private var playerGroup: PlayerSettingsGroupManager.PlayerGroup? {
        playerGroups.first
    }
    
    private var spyGroup: PlayerSettingsGroupManager.PlayerGroup? {
        playerGroups.last
    }
    
    private lazy var backButton = BackButton(
        target: self, action: #selector(customBackAction))
    private lazy var startButton = GameSettingsUIManager.createStartButton(target: self)
    private lazy var customizeButton = GameSettingsUIManager.createCustomizeButton(target: self)
    private lazy var gradientView = GradientView(superView: view)
    
    private var customPlayerNames: [String]?
    private var userSelectedCategory: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDefaultValuesAndSetup()
        setupInitialUI()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if userSelectedCategory == nil {
            GameSettingsCategoryManager.updateCategoryDisplay(in: &settingsGroups)
            print("Auto-updating category display from defaults")
        } else {
            print("Skipping category auto-update - user has selected: \(userSelectedCategory!)")
        }
    }
    
    // MARK: - Setup Methods
    private func loadDefaultValuesAndSetup() {
        if let defaultValues = GameSettingsDataManager.loadDefaultSessionValues() {
            setupPlayerGroups(playerCount: defaultValues.playerCount, spyCount: defaultValues.spyCount)
            setupSettingsGroups(
                category: defaultValues.category,
                roundDuration: Int(defaultValues.roundDuration) ?? 3,
                roundCount: Int(defaultValues.roundCount) ?? 5,
                showHints: defaultValues.showHints
            )
        } else {
            setupPlayerGroups()
            setupSettingsGroups()
        }
    }
    
    private func setupPlayerGroups(playerCount: Int = 5, spyCount: Int = 1) {
        playerGroups = GameSettingsGroupFactory.createPlayerGroups(
            playerCount: playerCount,
            spyCount: spyCount
        )
    }
    
    private func setupSettingsGroups(
        category: String = "basic",
        roundDuration: Int = 3,
        roundCount: Int = 5,
        showHints: Bool = true
    ) {
        settingsGroups = GameSettingsGroupFactory.createSettingsGroups(
            target: self,
            category: category,
            roundDuration: roundDuration,
            roundCount: roundCount,
            showHints: showHints
        )
    }
    
    private func setupInitialUI() {
        [gradientView, backButton, bottomView, startButton].forEach {
            view.addSubview($0)
        }
        
        var previousGroup: PlayerSettingsGroupManager.PlayerGroup?
        playerGroups.forEach { group in
            addGroupToView(group, previousGroup: previousGroup)
            previousGroup = group
        }
        
        var lastPlayerGroup = playerGroups.last
        settingsGroups.forEach { group in
            addSettingsGroupToView(group, previousPlayerGroup: lastPlayerGroup)
            lastPlayerGroup = nil
        }
        
        bottomView.addSubview(customizeButton)
    }
    
    // MARK: - UI Layout Methods
    private func addGroupToView(_ group: PlayerSettingsGroupManager.PlayerGroup, previousGroup: PlayerSettingsGroupManager.PlayerGroup?) {
        [group.label, group.stackView, group.minusButton, group.plusButton].forEach {
            bottomView.addSubview($0)
        }
        setupGroupConstraints(group, previousGroup: previousGroup)
    }
    
    private func addSettingsGroupToView(_ group: GameSettingsGroupManager.SettingsGroup, previousPlayerGroup: PlayerSettingsGroupManager.PlayerGroup?) {
        bottomView.addSubview(group.stackView)
        
        if let previousGroup = previousPlayerGroup {
            NSLayoutConstraint.activate([
                group.stackView.topAnchor.constraint(
                    equalTo: previousGroup.stackView.bottomAnchor,
                    constant: GameSettingsConstants.bigMargin),
                group.stackView.leadingAnchor.constraint(
                    equalTo: bottomView.leadingAnchor,
                    constant: GameSettingsConstants.bigMargin),
                group.stackView.trailingAnchor.constraint(
                    equalTo: bottomView.trailingAnchor,
                    constant: -GameSettingsConstants.bigMargin)
            ])
        } else {
            if let currentIndex = settingsGroups.firstIndex(of: group), currentIndex > 0 {
                let previousSettingsGroup = settingsGroups[currentIndex - 1]
                NSLayoutConstraint.activate([
                    group.stackView.topAnchor.constraint(
                        equalTo: previousSettingsGroup.stackView.bottomAnchor,
                        constant: GameSettingsConstants.bigMargin),
                    group.stackView.leadingAnchor.constraint(
                        equalTo: bottomView.leadingAnchor,
                        constant: GameSettingsConstants.bigMargin),
                    group.stackView.trailingAnchor.constraint(
                        equalTo: bottomView.trailingAnchor,
                        constant: -GameSettingsConstants.bigMargin)
                ])
            }
        }
    }
    
    private func setupGroupConstraints(_ group: PlayerSettingsGroupManager.PlayerGroup, previousGroup: PlayerSettingsGroupManager.PlayerGroup?) {
        if let previous = previousGroup {
            NSLayoutConstraint.activate([
                group.label.topAnchor.constraint(
                    equalTo: previous.stackView.bottomAnchor,
                    constant: GameSettingsConstants.littleMargin),
                group.stackView.topAnchor.constraint(
                    equalTo: group.label.bottomAnchor,
                    constant: GameSettingsConstants.littleMargin),
            ])
        } else {
            NSLayoutConstraint.activate([
                group.label.topAnchor.constraint(
                    equalTo: bottomView.topAnchor,
                    constant: GameSettingsConstants.bigMargin),
                group.stackView.topAnchor.constraint(
                    equalTo: group.label.bottomAnchor,
                    constant: GameSettingsConstants.littleMargin),
            ])
        }
        
        setupGroupHorizontalConstraints(group)
        setupGroupVerticalConstraints(group)
    }
    
    private func setupGroupHorizontalConstraints(_ group: PlayerSettingsGroupManager.PlayerGroup) {
        NSLayoutConstraint.activate([
            group.label.leadingAnchor.constraint(
                equalTo: bottomView.leadingAnchor,
                constant: GameSettingsConstants.bigMargin),
            group.label.heightAnchor.constraint(
                equalToConstant: GameSettingsConstants.buttonsHeight),
            group.label.trailingAnchor.constraint(
                equalTo: group.minusButton.leadingAnchor,
                constant: -GameSettingsConstants.bigMargin),
            
            group.stackView.trailingAnchor.constraint(
                equalTo: group.minusButton.leadingAnchor,
                constant: -GameSettingsConstants.littleMargin),
            group.stackView.heightAnchor.constraint(
                equalToConstant: GameSettingsConstants.buttonsHeight),
            group.stackView.leadingAnchor.constraint(
                equalTo: bottomView.leadingAnchor,
                constant: GameSettingsConstants.bigMargin),
            
            group.minusButton.trailingAnchor.constraint(
                equalTo: group.plusButton.leadingAnchor, constant: -8),
            group.plusButton.trailingAnchor.constraint(
                equalTo: bottomView.trailingAnchor,
                constant: -GameSettingsConstants.bigMargin),
            group.minusButton.widthAnchor.constraint(
                equalToConstant: GameSettingsConstants.buttonsHeight),
            group.plusButton.widthAnchor.constraint(
                equalToConstant: GameSettingsConstants.buttonsHeight),
        ])
    }
    
    private func setupGroupVerticalConstraints(_ group: PlayerSettingsGroupManager.PlayerGroup) {
        if group === playerGroup {
            NSLayoutConstraint.activate([
                group.minusButton.centerYAnchor.constraint(
                    equalTo: group.label.centerYAnchor),
                group.plusButton.centerYAnchor.constraint(
                    equalTo: group.label.centerYAnchor),
            ])
        } else {
            NSLayoutConstraint.activate([
                group.minusButton.centerYAnchor.constraint(
                    equalTo: group.stackView.centerYAnchor,
                    constant: -GameSettingsConstants.bigMargin),
                group.plusButton.centerYAnchor.constraint(
                    equalTo: group.stackView.centerYAnchor,
                    constant: -GameSettingsConstants.bigMargin),
            ])
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 8),
            backButton.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40),
            
            bottomView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: GameSettingsConstants.bigMargin),
            bottomView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -GameSettingsConstants.bigMargin),
            bottomView.topAnchor.constraint(
                equalTo: backButton.bottomAnchor, constant: 10),
            
            startButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: GameSettingsConstants.bigMargin),
            startButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -GameSettingsConstants.bigMargin),
            startButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -GameSettingsConstants.bigMargin),
            
            customizeButton.topAnchor.constraint(
                equalTo: playerGroup?.minusButton.bottomAnchor ?? bottomView.topAnchor,
                constant: GameSettingsConstants.littleMargin),
            customizeButton.leadingAnchor.constraint(
                equalTo: playerGroup?.minusButton.leadingAnchor ?? bottomView.leadingAnchor),
            customizeButton.trailingAnchor.constraint(
                equalTo: playerGroup?.plusButton.trailingAnchor ?? bottomView.trailingAnchor),
        ])
        
        if let lastSettingsGroup = settingsGroups.last {
            bottomView.bottomAnchor.constraint(
                equalTo: lastSettingsGroup.stackView.bottomAnchor, constant: 20).isActive = true
        } else {
            bottomView.bottomAnchor.constraint(
                equalTo: startButton.topAnchor, constant: -20).isActive = true
        }
    }
    
    // MARK: - Action Methods
    @objc private func customBackAction() {
        self.performSegue(withIdentifier: "unwindFromGameSettings", sender: self)
    }
    
    func handleStartButtonAction() {
        let gameValues = GameSettingsDataManager.getCurrentGameSessionValues(
            from: playerGroups,
            and: settingsGroups
        )
        GameSettingsDataManager.saveGameSessionAndCreateRounds(
            with: gameValues,
            customPlayerNames: customPlayerNames
        )
        
        userSelectedCategory = nil
        print("Reset user category selection for next game")
        
        self.performSegue(withIdentifier: "gameSettingsToCards", sender: self)
    }
    
    func handleCustomizeButtonAction() {
        self.performSegue(withIdentifier: "settingsToCustomPlayers", sender: self)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let playerCount = playerGroup?.imageViews.count ?? 0
        GameSettingsSegueHandler.prepareForSegue(
            segue,
            sender: sender,
            from: self,
            playerCount: playerCount,
            customPlayerNames: customPlayerNames
        )
        
        let customSegueIdentifiers = ["GameSettingsToCategories", "settingsToCustomPlayers"]
        if customSegueIdentifiers.contains(segue.identifier ?? "") {
            segue.destination.modalPresentationStyle = .custom
            segue.destination.transitioningDelegate = self
        }
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return StoryboardFadeToBlueUnwind()
    }
    
    @IBAction func unwindToGameSettingsWithSegue(_ segue: UIStoryboardSegue) {
        print("Unwinding to GameSettings from: \(type(of: segue.source))")
        
        if let newCustomPlayerNames = GameSettingsSegueHandler.handleUnwindSegue(segue, for: self) {
            self.customPlayerNames = newCustomPlayerNames
            print("Updated custom player names: \(newCustomPlayerNames)")
        } else if let sourceVC = segue.source as? CustomCategoriesViewController {
            let selectedCategory = sourceVC.selectedCategory
            print("Received category for current game session: \(selectedCategory)")
            updateCategoryInSettingsGroup(selectedCategory)
        } else {
            print("Unhandled segue source: \(type(of: segue.source))")
        }
    }
    
    // MARK: - Category Update Helper
    private func updateCategoryInSettingsGroup(_ selectedCategory: String) {
        guard settingsGroups.indices.contains(0) else {
            print("Category settings group not found at index 0.")
            return
        }
        
        let categoryGroup = settingsGroups[0]
        
        userSelectedCategory = selectedCategory
        print("User selected category: \(selectedCategory)")
        
        categoryGroup.value = selectedCategory
        
        print("Category updated to: '\(selectedCategory.localized)'")
    }
}

struct ViewController_Previews: PreviewProvider {
    static var previews: some View {
        ViewControllerPreview {
            GameSettingsViewController()
        }
    }
}
