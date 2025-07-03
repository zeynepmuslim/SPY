//
//  DefaultSettingsViewController+Constraints.swift
//  Spy
//
//  Created by Zeynep Müslim on 8.04.2025.
//

import UIKit

// MARK: - DefaultSettingsViewController Constraints Extension
extension DefaultSettingsViewController {
    
    func setupMainConstraints() {
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 8),
            backButton.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40),
            
            bottomView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: DefaultSettingsConstants.bigMargin),
            bottomView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -DefaultSettingsConstants.bigMargin),
            bottomView.topAnchor.constraint(
                equalTo: backButton.bottomAnchor, constant: 10),
            
            titleVCLabel.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: DefaultSettingsConstants.bigMargin),
            titleVCLabel.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: DefaultSettingsConstants.bigMargin),
            titleVCLabel.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -DefaultSettingsConstants.bigMargin),
            
            saveDefaultButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: DefaultSettingsConstants.bigMargin),
            saveDefaultButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -DefaultSettingsConstants.bigMargin),
            saveDefaultButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -DefaultSettingsConstants.bigMargin),
            
            customizeButton.topAnchor.constraint(
                equalTo: playerGroup?.minusButton.bottomAnchor ?? bottomView.topAnchor,
                constant: DefaultSettingsConstants.littleMargin),
            customizeButton.leadingAnchor.constraint(
                equalTo: playerGroup?.minusButton.leadingAnchor ?? bottomView.leadingAnchor),
            customizeButton.trailingAnchor.constraint(
                equalTo: playerGroup?.plusButton.trailingAnchor ?? bottomView.trailingAnchor),
        ])
        
        setupBottomViewConstraint()
    }
    
    private func setupBottomViewConstraint() {
        if let lastSettingsGroup = settingsGroups.last {
            bottomView.bottomAnchor.constraint(
                equalTo: lastSettingsGroup.stackView.bottomAnchor, constant: 20).isActive = true
        } else {
            bottomView.bottomAnchor.constraint(
                equalTo: saveDefaultButton.topAnchor, constant: -20).isActive = true
        }
    }
    
    func setupGroupConstraints(_ group: PlayerSettingsGroupManager.PlayerGroup, previousGroup: PlayerSettingsGroupManager.PlayerGroup?) {
        if let previous = previousGroup {
            NSLayoutConstraint.activate([
                group.label.topAnchor.constraint(
                    equalTo: previous.stackView.bottomAnchor,
                    constant: DefaultSettingsConstants.littleMargin),
                group.stackView.topAnchor.constraint(
                    equalTo: group.label.bottomAnchor,
                    constant: DefaultSettingsConstants.littleMargin),
            ])
        } else {
            NSLayoutConstraint.activate([
                group.label.topAnchor.constraint(
                    equalTo: titleVCLabel.bottomAnchor,
                    constant: DefaultSettingsConstants.littleMargin),
                group.stackView.topAnchor.constraint(
                    equalTo: group.label.bottomAnchor,
                    constant: DefaultSettingsConstants.littleMargin),
            ])
        }
        
        setupGroupHorizontalConstraints(group)
        setupGroupVerticalConstraints(group)
    }
    
    private func setupGroupHorizontalConstraints(_ group: PlayerSettingsGroupManager.PlayerGroup) {
        NSLayoutConstraint.activate([
            group.label.leadingAnchor.constraint(
                equalTo: bottomView.leadingAnchor,
                constant: DefaultSettingsConstants.bigMargin),
            group.label.heightAnchor.constraint(
                equalToConstant: DefaultSettingsConstants.buttonsHeight),
            group.label.trailingAnchor.constraint(
                equalTo: group.minusButton.leadingAnchor,
                constant: -DefaultSettingsConstants.bigMargin),
            
            group.stackView.trailingAnchor.constraint(
                equalTo: group.minusButton.leadingAnchor,
                constant: -DefaultSettingsConstants.littleMargin),
            group.stackView.heightAnchor.constraint(
                equalToConstant: DefaultSettingsConstants.buttonsHeight),
            group.stackView.leadingAnchor.constraint(
                equalTo: bottomView.leadingAnchor,
                constant: DefaultSettingsConstants.bigMargin),
            
            group.minusButton.trailingAnchor.constraint(
                equalTo: group.plusButton.leadingAnchor, constant: -8),
            group.plusButton.trailingAnchor.constraint(
                equalTo: bottomView.trailingAnchor,
                constant: -DefaultSettingsConstants.bigMargin),
            group.minusButton.widthAnchor.constraint(
                equalToConstant: DefaultSettingsConstants.buttonsHeight),
            group.plusButton.widthAnchor.constraint(
                equalToConstant: DefaultSettingsConstants.buttonsHeight),
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
                    constant: -DefaultSettingsConstants.bigMargin),
                group.plusButton.centerYAnchor.constraint(
                    equalTo: group.stackView.centerYAnchor,
                    constant: -DefaultSettingsConstants.bigMargin),
            ])
        }
    }
    
    func setupSettingsGroupConstraints(_ group: GameSettingsGroupManager.SettingsGroup, previousPlayerGroup: PlayerSettingsGroupManager.PlayerGroup?) {
        if let previousGroup = previousPlayerGroup {
            NSLayoutConstraint.activate([
                group.stackView.topAnchor.constraint(
                    equalTo: previousGroup.stackView.bottomAnchor,
                    constant: DefaultSettingsConstants.bigMargin),
                group.stackView.leadingAnchor.constraint(
                    equalTo: bottomView.leadingAnchor,
                    constant: DefaultSettingsConstants.bigMargin),
                group.stackView.trailingAnchor.constraint(
                    equalTo: bottomView.trailingAnchor,
                    constant: -DefaultSettingsConstants.bigMargin)
            ])
        } else {
            if let currentIndex = settingsGroups.firstIndex(of: group), currentIndex > 0 {
                let previousSettingsGroup = settingsGroups[currentIndex - 1]
                NSLayoutConstraint.activate([
                    group.stackView.topAnchor.constraint(
                        equalTo: previousSettingsGroup.stackView.bottomAnchor,
                        constant: DefaultSettingsConstants.bigMargin),
                    group.stackView.leadingAnchor.constraint(
                        equalTo: bottomView.leadingAnchor,
                        constant: DefaultSettingsConstants.bigMargin),
                    group.stackView.trailingAnchor.constraint(
                        equalTo: bottomView.trailingAnchor,
                        constant: -DefaultSettingsConstants.bigMargin)
                ])
            }
        }
    }
} 
