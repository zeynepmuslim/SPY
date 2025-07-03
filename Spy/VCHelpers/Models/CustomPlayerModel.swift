//
//  CustomPlayerModel.swift
//  Spy
//
//  Created by Zeynep Müslim on 8.04.2025.
//

import UIKit

// MARK: - Custom Player Cell Delegate Protocol
protocol CustomPlayerCellDelegate: AnyObject {
    func playerNameDidChange(in cell: CustomPlayerCell, to newName: String)
    func playerDidFinishEditing(in cell: CustomPlayerCell)
}

// MARK: - Custom Players Constants
enum CustomPlayersConstants {
    static let bigMargin: CGFloat = GeneralConstants.Layout.bigMargin
    static let littleMargin: CGFloat = GeneralConstants.Layout.littleMargin
    static let buttonsHeight: CGFloat = GeneralConstants.Button.biggerHeight
    static let itemsPerRow: CGFloat = 3
    static let sectionInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
}

// MARK: - Player Initialization Helper
class PlayerInitializationHelper {
    
    static func initializePlayerNames(
        playerCount: Int,
        isShowingDefaultPlayers: Bool,
        initialPlayerNames: [String]?
    ) -> [String] {
        if isShowingDefaultPlayers {
            let allDefaultPlayers = PlayerManager.shared.getDefaultPlayers()
            let playersToDisplay = allDefaultPlayers.prefix(playerCount)
            return playersToDisplay.map { $0.name ?? "player".localized }
        } else {
            let baseNames = initialPlayerNames ?? PlayerManager.shared.getDefaultPlayers().map { $0.name ?? "player".localized }
            var newPlayerNames: [String] = []
            
            let namesToTakeFromBase = min(playerCount, baseNames.count)
            newPlayerNames.append(contentsOf: baseNames.prefix(namesToTakeFromBase))
            
            if playerCount > baseNames.count {
                let additionalPlayerCount = playerCount - baseNames.count
                for i in 1...additionalPlayerCount {
                    let playerNumber = baseNames.count + i
                    newPlayerNames.append(String(format: "player_x".localized, playerNumber))
                }
            }
            
            return newPlayerNames
        }
    }
}

// MARK: - Custom Players Keyboard Manager
class CustomPlayersKeyboardManager {
    
    weak var viewController: UIViewController?
    weak var collectionView: UICollectionView?
    weak var darkBottomView: UIView?
    
    private var editingIndexPath: IndexPath?
    
    init(viewController: UIViewController, collectionView: UICollectionView, darkBottomView: UIView) {
        self.viewController = viewController
        self.collectionView = collectionView
        self.darkBottomView = darkBottomView
    }
    
    func setEditingIndexPath(_ indexPath: IndexPath?) {
        self.editingIndexPath = indexPath
    }
    
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    func unregisterFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let viewController = viewController,
              let collectionView = collectionView,
              let darkBottomView = darkBottomView,
              let userInfo = notification.userInfo,
              let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
              let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
        else { return }

        let keyboardFrameInView = viewController.view.convert(keyboardFrame, from: nil)
        let intersection = darkBottomView.frame.intersection(keyboardFrameInView)
        let keyboardHeightInScrollView = intersection.isNull ? 0 : intersection.height

        guard keyboardHeightInScrollView > 0 else { return }

        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeightInScrollView, right: 0)

        UIView.animate(withDuration: duration) {
            collectionView.contentInset = contentInsets
            collectionView.scrollIndicatorInsets = contentInsets
        }

        if let editingIndexPath = editingIndexPath {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                guard collectionView.cellForItem(at: editingIndexPath) != nil else {
                    collectionView.scrollToItem(at: editingIndexPath, at: .centeredVertically, animated: true)
                    return
                }
                collectionView.scrollToItem(at: editingIndexPath, at: .centeredVertically, animated: true)
            }
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        guard let collectionView = collectionView,
              let userInfo = notification.userInfo,
              let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
        else { return }

        let contentInsets = UIEdgeInsets.zero
        UIView.animate(withDuration: duration) {
            collectionView.contentInset = contentInsets
            collectionView.scrollIndicatorInsets = contentInsets
        }
    }
}

// MARK: - Player Editing Manager
class PlayerEditingManager {
    
    weak var collectionView: UICollectionView?
    weak var darkBottomView: UIView?
    
    private var editingIndexPath: IndexPath?
    
    init(collectionView: UICollectionView, darkBottomView: UIView) {
        self.collectionView = collectionView
        self.darkBottomView = darkBottomView
    }
    
    var currentEditingIndexPath: IndexPath? {
        return editingIndexPath
    }
    
    func startEditing(cell: CustomPlayerCell, indexPath: IndexPath) {
        editingIndexPath = indexPath
        collectionView?.isScrollEnabled = false
        
        if let darkBottomView = darkBottomView,
           let superview = darkBottomView.superview {
            superview.bringSubviewToFront(darkBottomView)
        }

        UIView.animate(withDuration: 0.3) {
            cell.transform = CGAffineTransform(scaleX: 1.08, y: 1.08)
            cell.layer.zPosition = 1
            
            if let collectionView = self.collectionView {
                for visibleCell in collectionView.visibleCells {
                    if visibleCell != cell {
                        visibleCell.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                        visibleCell.alpha = 0.5
                    }
                }
            }
        } completion: { _ in
            cell.startEditing()
            DispatchQueue.main.async {
                self.collectionView?.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
            }
        }
    }

    func stopEditing(cell: CustomPlayerCell, indexPath: IndexPath) {
        guard editingIndexPath == indexPath else { return }
        
        cell.stopEditing()
        editingIndexPath = nil
        collectionView?.isScrollEnabled = true
        
        UIView.animate(withDuration: 0.3) {
            cell.transform = .identity
            cell.layer.zPosition = 0

            if let collectionView = self.collectionView {
                for visibleCell in collectionView.visibleCells {
                    if visibleCell != cell {
                        visibleCell.transform = .identity
                        visibleCell.alpha = 1.0
                    }
                }
            }
        }
    }
    
    func switchEditing(
        toCell: CustomPlayerCell,
        toIndexPath: IndexPath,
        fromCell: CustomPlayerCell,
        fromIndexPath: IndexPath
    ) {
        guard editingIndexPath == fromIndexPath else { return }
        
        stopEditing(cell: fromCell, indexPath: fromIndexPath)
        startEditing(cell: toCell, indexPath: toIndexPath)
    }
} 
