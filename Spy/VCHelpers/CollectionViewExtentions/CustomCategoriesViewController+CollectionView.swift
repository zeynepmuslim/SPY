//
//  CustomCategoriesViewController+CollectionView.swift
//  Spy
//
//  Created by Zeynep Müslim on 8.04.2025.
//

import UIKit

// MARK: - UICollectionViewDataSource
extension CustomCategoriesViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.getTotalItemCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryDisplayCell.identifier, for: indexPath) as? CategoryDisplayCell else {
            fatalError("Unable to dequeue CategoryDisplayCell")
        }
        
        cell.gestureRecognizers?.forEach { cell.removeGestureRecognizer($0) }
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.delaysTouchesBegan = true
        doubleTapGesture.accessibilityHint = "\(indexPath.item)"
        cell.addGestureRecognizer(doubleTapGesture)
        
        if indexPath.item < model.getCategoryCount() {
            configureExistingCategoryCell(cell, at: indexPath)
        } else {
            configureAddCategoryCell(cell)
        }
        
        return cell
    }
    
    func configureExistingCategoryCell(_ cell: CategoryDisplayCell, at indexPath: IndexPath) {
        guard let displayData = model.getCategoryDisplayData(at: indexPath.item),
              let categoryEntity = model.getCategoryEntity(at: indexPath.item) else { return }
        
        let iconImage = UIImage(systemName: displayData.icon)
        cell.configure(categoryName: displayData.name, icon: iconImage, isCustom: displayData.isCustom)
        cell.setIsSelected(isSelected: displayData.isSelected)
        
        if displayData.isCustom {
            cell.onEditButtonTapped = { [weak self] in
                print("Edit button tapped via closure for index: \(indexPath.item)")
                self?.editCategory(at: indexPath)
            }
            cell.onInfoButtonTapped = nil
        } else {
            cell.onEditButtonTapped = nil
            cell.onInfoButtonTapped = { [weak self] in
                print("Info button tapped for default category: \(displayData.name)")
                self?.showCategoryInfo(for: categoryEntity)
            }
        }
    }
    
    func configureAddCategoryCell(_ cell: CategoryDisplayCell) {
        let addIcon = UIImage(systemName: "plus.circle.fill")
        cell.configure(categoryName: "new".localized, icon: addIcon, isCustom: false)
        cell.iconImageView.tintColor = .white
        cell.onEditButtonTapped = nil
        cell.onInfoButtonTapped = nil
        cell.setIsSelected(isSelected: false)
    }
}

// MARK: - UICollectionViewDelegate
extension CustomCategoriesViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item < model.getCategoryCount() {
            guard let displayData = model.getCategoryDisplayData(at: indexPath.item) else { return }
            
            if displayData.isSelected { return }
            
            // Update previous selection
            if let previousSelectedIndex = model.getPreviousSelectedIndex() {
                let previousIndexPath = IndexPath(item: previousSelectedIndex, section: 0)
                if let previousCell = collectionView.cellForItem(at: previousIndexPath) as? CategoryDisplayCell {
                    previousCell.setIsSelected(isSelected: false)
                }
            }
            
            // Update new selection (don't notify to avoid reloadData during animation)
            model.selectCategory(displayData.name, shouldNotify: false)
            
            if let newCell = collectionView.cellForItem(at: indexPath) as? CategoryDisplayCell {
                newCell.setIsSelected(isSelected: true)
            }
        } else {
            print("Add New Category selected")
            performSegue(withIdentifier: "CustomCategoriesToIAddCategory", sender: nil)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CustomCategoriesViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return CGSize(width: 100, height: 120)
        }
        
        let numberOfColumns: CGFloat = 3
        let totalHorizontalSpacing = layout.minimumInteritemSpacing * (numberOfColumns - 1)
        let contentInsets = collectionView.contentInset
        let availableWidth = collectionView.bounds.width - contentInsets.left - contentInsets.right - totalHorizontalSpacing
        
        let itemWidth = availableWidth / numberOfColumns
        let itemHeight = itemWidth * 1.2
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
} 
