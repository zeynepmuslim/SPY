//
//  CustomPlayersViewController.swift
//  Spy
//
//  Created by Zeynep Müslim on 8.04.2025.
//

import UIKit
import SwiftUI

class CustomPlayersViewController: UIViewController {
    
    // MARK: - UI Components
    private lazy var backButton = BackButton(
        target: self, action: #selector(customBackAction))
    private lazy var savePlayersButton = createSaveButton()
    let darkBottomView = CustomDarkScrollView()
    private var collectionView: UICollectionView!
    
    // MARK: - Properties
    var playerCount: Int = 10
    var unwindSegueIdentifier: String?
    var initialPlayerNames: [String]?
    private var isShowingDefaultPlayers: Bool = false
    
    private(set) var playerNames: [String] = []
    
    // MARK: - Helper Managers
    var customPlayersKeyboardManager: CustomPlayersKeyboardManager!
    var customPlayersEditingManager: PlayerEditingManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        setupManagers()
        setupConstraints()
        setupGestureRecognizers()
        
        initializePlayerNames()
        collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        customPlayersKeyboardManager.registerForKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        customPlayersKeyboardManager.unregisterFromKeyboardNotifications()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        let gradientView = GradientView(superView: view)
        view.insertSubview(gradientView, at: 0)
        view.addSubview(savePlayersButton)
        view.addSubview(darkBottomView)
        view.addSubview(backButton)
    }
    
    private func setupManagers() {
        customPlayersKeyboardManager = CustomPlayersKeyboardManager(
            viewController: self,
            collectionView: collectionView,
            darkBottomView: darkBottomView
        )
        customPlayersEditingManager = PlayerEditingManager(
            collectionView: collectionView,
            darkBottomView: darkBottomView
        )
    }
    
    private func setupCollectionView() {
        let layout = CenteredFlowLayout()
        layout.scrollDirection = .vertical
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(CustomPlayerCell.self, forCellWithReuseIdentifier: CustomPlayerCell.identifier)
        
        darkBottomView.addSubview(collectionView)
    }
    
    private func setupGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap))
        tapGesture.delegate = self
        darkBottomView.addGestureRecognizer(tapGesture)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            backButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 8),
            backButton.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40),
            
            darkBottomView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: CustomPlayersConstants.bigMargin),
            darkBottomView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -CustomPlayersConstants.bigMargin),
            darkBottomView.bottomAnchor.constraint(
                equalTo: savePlayersButton.topAnchor,
                constant: -CustomPlayersConstants.bigMargin),
            darkBottomView.topAnchor.constraint(
                equalTo: backButton.bottomAnchor, constant: CustomPlayersConstants.littleMargin),
            
            collectionView.leadingAnchor.constraint(equalTo: darkBottomView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: darkBottomView.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: darkBottomView.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: darkBottomView.bottomAnchor),
            
            savePlayersButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: CustomPlayersConstants.bigMargin),
            savePlayersButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -CustomPlayersConstants.bigMargin),
            savePlayersButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -CustomPlayersConstants.bigMargin),
            
            savePlayersButton.heightAnchor.constraint(equalToConstant: GeneralConstants.Button.biggerHeight),
        ])
    }
    
    func configure(playerCount: Int, isDefault: Bool = false, customNames: [String]? = nil) {
        self.playerCount = playerCount
        self.isShowingDefaultPlayers = isDefault
        self.initialPlayerNames = customNames
    }
    
    private func createSaveButton() -> CustomGradientButton {
        let button = CustomGradientButton(
            labelText: "save_players".localized, width: 100,
            height: GeneralConstants.Button.biggerHeight)
        button.onClick = { [weak self] in
            guard let self = self else { return }
            customBackAction()
        }
        return button
    }
    
    // MARK: - Initialization Helpers
    private func initializePlayerNames() {
        playerNames = PlayerInitializationHelper.initializePlayerNames(
            playerCount: playerCount,
            isShowingDefaultPlayers: isShowingDefaultPlayers,
            initialPlayerNames: initialPlayerNames
        )
    }
    
    
    
    // MARK: - Actions
    @objc private func handleBackgroundTap(_ sender: UITapGestureRecognizer) {
        //Delegeate control the cell selection and editing state: only trigger when the touch is not in a cell but there is edting cell
        if let editingIndexPath = customPlayersEditingManager.currentEditingIndexPath,
           let cell = collectionView.cellForItem(at: editingIndexPath) as? CustomPlayerCell {
            customPlayersEditingManager.stopEditing(cell: cell, indexPath: editingIndexPath)
            customPlayersKeyboardManager.setEditingIndexPath(nil)
        }
    }
    
    @objc private func customBackAction() {
        guard let identifier = unwindSegueIdentifier else {
            print("Error: Unwind segue identifier not set.")
            return
        }
        self.performSegue(withIdentifier: identifier, sender: self)
    }
}

struct CustomPlayersViewController_Previews: PreviewProvider {
    static var previews: some View {
        ViewControllerPreview {
            CustomPlayersViewController()
        }
    }
}

// MARK: - CustomPlayerCellDelegate
extension CustomPlayersViewController: CustomPlayerCellDelegate {
    func playerNameDidChange(in cell: CustomPlayerCell, to newName: String) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        if indexPath.item < playerNames.count {
            playerNames[indexPath.item] = newName
            
            if isShowingDefaultPlayers {
                let defaultPlayers = PlayerManager.shared.getDefaultPlayers()
                if indexPath.item < defaultPlayers.count {
                    let player = defaultPlayers[indexPath.item]
                    PlayerManager.shared.updatePlayerName(player: player, newName: newName)
                }
            }
        } else {
            print("Error: Index out of bounds while updating player name.")
        }
    }
    
    func playerDidFinishEditing(in cell: CustomPlayerCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        customPlayersEditingManager.stopEditing(cell: cell, indexPath: indexPath)
        customPlayersKeyboardManager.setEditingIndexPath(nil)
    }
}

// MARK: - UIGestureRecognizerDelegate
extension CustomPlayersViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let location = touch.location(in: collectionView)
        
        if collectionView.indexPathForItem(at: location) != nil {
            return false
        }
        
        return customPlayersEditingManager.currentEditingIndexPath != nil
    }
}
