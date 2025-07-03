//
//  CustomPlayersViewController+CollectionView.swift
//  Spy
//
//  Created by Zeynep Müslim on 8.04.2025.
//

import UIKit

// MARK: - UICollectionViewDataSource
extension CustomPlayersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playerCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CustomPlayerCell.identifier,
            for: indexPath) as? CustomPlayerCell else {
            fatalError("Unable to dequeue CustomPlayerCell")
        }
        
        if indexPath.item < playerNames.count {
            cell.configure(playerNumber: indexPath.item + 1, color: .clear, iconName: "civil-right-w")
            cell.label.text = playerNames[indexPath.item]
        } else {
            cell.configure(playerNumber: indexPath.item + 1, color: .red, iconName: "exclamationmark.triangle.fill")
            cell.label.text = "error".localized
        }
        
        cell.delegate = self
        cell.setStatus(.activeBlue)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension CustomPlayersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let currentEditingIndexPath = customPlayersEditingManager.currentEditingIndexPath {
            if currentEditingIndexPath != indexPath {
                guard let currentEditingCell = collectionView.cellForItem(at: currentEditingIndexPath) as? CustomPlayerCell,
                      let newCell = collectionView.cellForItem(at: indexPath) as? CustomPlayerCell else { return }
                
                customPlayersEditingManager.switchEditing(
                    toCell: newCell,
                    toIndexPath: indexPath,
                    fromCell: currentEditingCell,
                    fromIndexPath: currentEditingIndexPath
                )
                customPlayersKeyboardManager.setEditingIndexPath(indexPath)
            }
            return
        }
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? CustomPlayerCell else { return }
        customPlayersEditingManager.startEditing(cell: cell, indexPath: indexPath)
        customPlayersKeyboardManager.setEditingIndexPath(indexPath)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CustomPlayersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = CustomPlayersConstants.sectionInsets.left * (CustomPlayersConstants.itemsPerRow + 1)
        let availableWidth = darkBottomView.frame.width - paddingSpace
        let widthPerItem = availableWidth / CustomPlayersConstants.itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem * 1.4)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return CustomPlayersConstants.sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CustomPlayersConstants.sectionInsets.bottom
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CustomPlayersConstants.sectionInsets.left
    }
}
