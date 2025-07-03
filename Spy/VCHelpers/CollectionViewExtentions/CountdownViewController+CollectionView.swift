import UIKit

// MARK: - UICollectionViewDataSource
extension CountdownViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return countdownModel.numberOfPlayers
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChildCollectionViewCell.identifier, for: indexPath) as? ChildCollectionViewCell else {
            fatalError("ChildCollectionViewCell dequeue edilemedi")
        }
        
        let playerName = countdownModel.getPlayerName(at: indexPath.item)
        let isVerticalLayout = (countdownModel.numberOfPlayers <= 6)
        let iconName = "spy-right-w"
        let isSpy = countdownModel.isPlayerSpy(indexPath.item)
        let isDeactivated = countdownModel.isPlayerDeactivated(indexPath.item)
        
        cell.updateLayout(isVertical: isVerticalLayout, numberOfChild: countdownModel.numberOfPlayers)
        
        let (status, transform) = getTargetState(for: indexPath, currentlySelectedIndex: selectedIndex)
        
        cell.setStatus(status)
        cell.transform = transform
        cell.configure(player: playerName, color: .clear, iconName: iconName)
        
        if isDeactivated {
            cell.setRole(isSpy: isSpy)
        }
        
        cell.isUserInteractionEnabled = !isDeactivated
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension CountdownViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let isDeactivated = countdownModel.isPlayerDeactivated(indexPath.item)
        guard !isDeactivated else {
            print("Cell at index \(indexPath.item + 1) is deactivated. Selection ignored.")
            return
        }
        
        if indexPath == selectedIndex {
            selectedIndex = nil
        } else {
            selectedIndex = indexPath
        }
        
        if let selected = selectedIndex {
            let selectedPlayerIndex = selected.item
            let isSpy = countdownModel.isPlayerSpy(selectedPlayerIndex)
            print("Selected cell: \(selectedPlayerIndex + 1). Is Spy: \(isSpy)")
        } else {
            print("Selection cleared")
        }
        
        let blameButtonStatus: ButtonStatus = self.isAnyCellSelected ? .activeRed : .deactive
        self.blamePlayerButton.setStatus(blameButtonStatus)
        self.blamePlayerButton.isUserInteractionEnabled = (blameButtonStatus == .activeRed)
        
        animateCellSelectionChanges()
    }
    
    private func animateCellSelectionChanges() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [.curveEaseInOut, .allowUserInteraction], animations: {
            for visibleCell in self.collectionView.visibleCells {
                guard let cell = visibleCell as? ChildCollectionViewCell,
                      let indexPathForCell = self.collectionView.indexPath(for: cell) else { continue }
                
                let (targetStatus, targetTransform) = self.getTargetState(for: indexPathForCell, currentlySelectedIndex: self.selectedIndex)
                
                cell.setStatus(targetStatus)
                cell.transform = targetTransform
            }
        }, completion: nil)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CountdownViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return .zero
        }
        
        let columns = CGFloat(self.currentColumns)
        let horizontalPadding = layout.minimumInteritemSpacing
        let sectionInsets = layout.sectionInset
        
        let totalHorizontalPadding = sectionInsets.left + sectionInsets.right + (horizontalPadding * (columns - 1))
        let availableWidth = collectionView.bounds.width - totalHorizontalPadding
        let itemWidth = max(1, availableWidth / columns)
        
        let actualRows = CGFloat((countdownModel.numberOfPlayers + Int(columns) - 1) / Int(columns))
        let verticalPadding = layout.minimumLineSpacing
        let totalVerticalPadding = sectionInsets.top + sectionInsets.bottom + (verticalPadding * (actualRows - 1))
        let availableHeight = collectionView.bounds.height - totalVerticalPadding
        let itemHeight = max(1, availableHeight / actualRows)
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
}
