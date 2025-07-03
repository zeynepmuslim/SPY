import UIKit

extension CountdownViewController {
    
    internal func setupConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            timeAndHintContainer.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: Constants.bigMargin),
            timeAndHintContainer.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: Constants.bigMargin),
            timeAndHintContainer.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -Constants.bigMargin),
            
            timeContainer.leadingAnchor.constraint(equalTo: timeAndHintContainer.leadingAnchor),
            timeContainer.trailingAnchor.constraint(equalTo: timeAndHintContainer.trailingAnchor),
            timeContainer.bottomAnchor.constraint(equalTo: timeAndHintContainer.bottomAnchor),
            
            timeLabel.leadingAnchor.constraint(equalTo: timeAndHintContainer.leadingAnchor),
            timeLabel.trailingAnchor.constraint(equalTo: timeAndHintContainer.trailingAnchor),
            timeLabel.centerYAnchor.constraint(equalTo: timeContainer.centerYAnchor),
            
            darkBottomView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: Constants.bigMargin),
            darkBottomView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -Constants.bigMargin),
            darkBottomView.bottomAnchor.constraint(
                equalTo: blamePlayerButton.topAnchor, constant: -Constants.bigMargin),
            darkBottomView.topAnchor.constraint(equalTo: timeAndHintContainer.bottomAnchor),
            
            topContainer.leadingAnchor.constraint(
                equalTo: darkBottomView.leadingAnchor, constant: Constants.bigMargin),
            topContainer.trailingAnchor.constraint(
                equalTo: darkBottomView.trailingAnchor, constant: -Constants.bigMargin),
            topContainer.topAnchor.constraint(
                equalTo: darkBottomView.topAnchor, constant: Constants.bigMargin),
            topContainer.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.09),
            
            containerView.leadingAnchor.constraint(
                equalTo: darkBottomView.leadingAnchor, constant: Constants.littleMargin),
            containerView.trailingAnchor.constraint(
                equalTo: darkBottomView.trailingAnchor, constant: -Constants.littleMargin),
            containerView.topAnchor.constraint(equalTo: topContainer.bottomAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomContainer.topAnchor),
            
            collectionView.topAnchor.constraint(equalTo: containerView.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            findSpyContainer.leadingAnchor.constraint(equalTo: topContainer.leadingAnchor),
            findSpyContainer.widthAnchor.constraint(equalTo: topContainer.widthAnchor, multiplier: 0.4),
            findSpyContainer.topAnchor.constraint(equalTo: topContainer.topAnchor),
            findSpyContainer.bottomAnchor.constraint(equalTo: topContainer.bottomAnchor),
            
            findSpyTitle.leadingAnchor.constraint(equalTo: findSpyContainer.leadingAnchor),
            findSpyTitle.topAnchor.constraint(equalTo: findSpyContainer.topAnchor),
            
            findSpyLabel.leadingAnchor.constraint(equalTo: findSpyContainer.leadingAnchor),
            findSpyLabel.topAnchor.constraint(equalTo: findSpyTitle.bottomAnchor, constant: Constants.littleMargin),
            findSpyLabel.widthAnchor.constraint(equalTo: findSpyContainer.widthAnchor),
            
            pointsContainer.leadingAnchor.constraint(equalTo: findSpyContainer.trailingAnchor),
            pointsContainer.trailingAnchor.constraint(equalTo: topContainer.trailingAnchor),
            pointsContainer.topAnchor.constraint(equalTo: topContainer.topAnchor),
            pointsContainer.bottomAnchor.constraint(equalTo: topContainer.bottomAnchor),
            
            pointsTitle.trailingAnchor.constraint(equalTo: pointsContainer.trailingAnchor),
            pointsTitle.topAnchor.constraint(equalTo: pointsContainer.topAnchor),
            
            civilPointsLabel.trailingAnchor.constraint(equalTo: pointsContainer.trailingAnchor),
            civilPointsLabel.topAnchor.constraint(equalTo: pointsTitle.bottomAnchor, constant: Constants.littleMargin),
            
            spyPointsLabel.trailingAnchor.constraint(equalTo: pointsContainer.trailingAnchor),
            spyPointsLabel.topAnchor.constraint(equalTo: civilPointsLabel.bottomAnchor, constant: 0),
            
            bottomContainer.leadingAnchor.constraint(
                equalTo: darkBottomView.leadingAnchor, constant: Constants.bigMargin),
            bottomContainer.trailingAnchor.constraint(
                equalTo: darkBottomView.trailingAnchor, constant: -Constants.bigMargin),
            bottomContainer.bottomAnchor.constraint(
                equalTo: darkBottomView.bottomAnchor, constant: -Constants.bigMargin),
            bottomContainer.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.04),
            
            bottomLabel.widthAnchor.constraint(equalTo: bottomContainer.widthAnchor),
            bottomLabel.heightAnchor.constraint(equalTo: bottomContainer.heightAnchor),
            
            blamePlayerButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: Constants.bigMargin),
            blamePlayerButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -Constants.bigMargin),
            blamePlayerButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.bigMargin),
            blamePlayerButton.heightAnchor.constraint(equalToConstant: GeneralConstants.Button.biggerHeight),
        ])
        
        setupConditionalConstraints()
    }

    private func setupConditionalConstraints() {
        if countdownModel.isHintAvailable {
            setupHintConstraints()
        } else {
            setupNoHintConstraints()
        }
        setupPlayerCountConstraints()
    }

    private func setupHintConstraints() {
        NSLayoutConstraint.activate([
            hintContainer.leadingAnchor.constraint(equalTo: timeAndHintContainer.leadingAnchor),
            hintContainer.trailingAnchor.constraint(equalTo: timeAndHintContainer.trailingAnchor),
            hintContainer.topAnchor.constraint(equalTo: timeAndHintContainer.topAnchor),
            hintContainer.heightAnchor.constraint(equalTo: timeAndHintContainer.heightAnchor, multiplier: 0.3),
            
            timeContainer.topAnchor.constraint(equalTo: hintContainer.bottomAnchor),
            
            hintTitle.leadingAnchor.constraint(equalTo: hintContainer.leadingAnchor),
            hintTitle.trailingAnchor.constraint(equalTo: hintContainer.trailingAnchor),
            hintTitle.centerXAnchor.constraint(equalTo: hintContainer.centerXAnchor),
            hintTitle.topAnchor.constraint(equalTo: hintContainer.topAnchor, constant: Constants.littleMargin),
            
            hintLabel.widthAnchor.constraint(equalTo: hintContainer.widthAnchor, multiplier: 0.9),
            hintLabel.topAnchor.constraint(equalTo: hintTitle.bottomAnchor, constant: Constants.littleMargin),
            hintLabel.centerXAnchor.constraint(equalTo: hintContainer.centerXAnchor),
        ])
    }
    
    private func setupNoHintConstraints() {
        timeContainer.topAnchor.constraint(equalTo: timeAndHintContainer.topAnchor).isActive = true
    }
    
    private func setupPlayerCountConstraints() {
        if countdownModel.numberOfPlayers < 4 {
            darkBottomView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4).isActive = true
        } else {
            darkBottomView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.55).isActive = true
        }
    }
} 
