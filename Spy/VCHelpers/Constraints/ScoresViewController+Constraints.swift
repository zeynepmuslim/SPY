import UIKit

extension ScoresViewController {
    
    internal func setupConstraints() {
        NSLayoutConstraint.activate([
            darkBottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.bigMargin),
            darkBottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.bigMargin),
            darkBottomView.bottomAnchor.constraint(equalTo: newRoundButton.topAnchor, constant: -Constants.bigMargin),
            darkBottomView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.bigMargin),
            
            winnerLabel.leadingAnchor.constraint(equalTo: darkBottomView.leadingAnchor, constant: Constants.bigMargin),
            winnerLabel.topAnchor.constraint(equalTo: darkBottomView.topAnchor, constant: Constants.bigMargin),
            
            selectedWordLabel.leadingAnchor.constraint(equalTo: darkBottomView.leadingAnchor, constant: Constants.bigMargin),
            selectedWordLabel.topAnchor.constraint(equalTo: winnerLabel.topAnchor, constant: Constants.bigMargin),
            
            containerView.leadingAnchor.constraint(equalTo: darkBottomView.leadingAnchor, constant: Constants.bigMargin),
            containerView.trailingAnchor.constraint(equalTo: darkBottomView.trailingAnchor, constant: -Constants.bigMargin),
            containerView.topAnchor.constraint(equalTo: selectedWordLabel.bottomAnchor),
            
            collectionView.topAnchor.constraint(equalTo: containerView.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            scoreLabelsContainer.leadingAnchor.constraint(equalTo: darkBottomView.leadingAnchor, constant: Constants.bigMargin),
            scoreLabelsContainer.trailingAnchor.constraint(equalTo: darkBottomView.trailingAnchor, constant: -Constants.bigMargin),
            scoreLabelsContainer.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: Constants.bigMargin),
            scoreLabelsContainer.bottomAnchor.constraint(equalTo: bottomInfoLabel.topAnchor, constant: -Constants.bigMargin),
            
            civilPointLabel.centerXAnchor.constraint(equalTo: scoreLabelsContainer.centerXAnchor),
            civilPointLabel.bottomAnchor.constraint(equalTo: spyPointLabel.topAnchor, constant: -Constants.littleMargin),
            spyPointLabel.centerYAnchor.constraint(equalTo: scoreLabelsContainer.centerYAnchor),
            spyPointLabel.centerXAnchor.constraint(equalTo: scoreLabelsContainer.centerXAnchor),
            
            bottomInfoLabel.leadingAnchor.constraint(equalTo: darkBottomView.leadingAnchor, constant: Constants.bigMargin),
            bottomInfoLabel.topAnchor.constraint(equalTo: scoreLabelsContainer.bottomAnchor, constant: Constants.bigMargin),
            bottomInfoLabel.trailingAnchor.constraint(equalTo: darkBottomView.trailingAnchor, constant: -Constants.bigMargin),
            
            remainHandlabel.leadingAnchor.constraint(equalTo: darkBottomView.leadingAnchor, constant: Constants.bigMargin),
            remainHandlabel.topAnchor.constraint(equalTo: bottomInfoLabel.bottomAnchor, constant: Constants.bigMargin),
            remainHandlabel.trailingAnchor.constraint(equalTo: darkBottomView.trailingAnchor, constant: -Constants.bigMargin),
            remainHandlabel.bottomAnchor.constraint(equalTo: darkBottomView.bottomAnchor, constant: -Constants.bigMargin),
            
            newRoundButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.bigMargin),
            newRoundButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.bigMargin),
            newRoundButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.bigMargin),
            newRoundButton.heightAnchor.constraint(equalToConstant: GeneralConstants.Button.biggerHeight),
        ])
        
        setupConditionalConstraints()
    }
    
    private func setupConditionalConstraints() {
        if model.numberOfChildren < 4 {
            containerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3).isActive = true
        } else {
            containerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.45).isActive = true
        }
    }
} 
