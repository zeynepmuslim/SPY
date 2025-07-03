//
//  EnterViewController+Constraints.swift
//  Spy
//
//  Created by Zeynep Müslim on 8.04.2025.
//

import UIKit

extension EnterViewController {
    
    internal func setupConstraints() {
        NSLayoutConstraint.activate([
            upperStack.topAnchor.constraint(equalTo: view.topAnchor),
            upperStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            upperStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            upperStack.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4),
            
            backgroundImageView.widthAnchor.constraint(equalTo: upperStack.widthAnchor),
            backgroundImageView.heightAnchor.constraint(equalTo: upperStack.heightAnchor),
            
            magnifyingGlassStack.topAnchor.constraint(equalTo: upperStack.topAnchor),
            magnifyingGlassStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            magnifyingGlassStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            magnifyingGlassStack.heightAnchor.constraint(equalTo: upperStack.heightAnchor),
            
            backgroundImageViewNormal.topAnchor.constraint(equalTo: upperStack.topAnchor),
            backgroundImageViewNormal.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageViewNormal.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageViewNormal.heightAnchor.constraint(equalTo: upperStack.heightAnchor),
            
            lowerStack.topAnchor.constraint(equalTo: upperStack.bottomAnchor, constant: 20),
            lowerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            lowerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            lowerStack.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            lowerStack.widthAnchor.constraint(equalTo: view.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: lowerStack.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: lowerStack.centerXAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 60),
            
            startGameButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            startGameButton.centerXAnchor.constraint(equalTo: lowerStack.centerXAnchor),
            
            settingsButton.topAnchor.constraint(equalTo: startGameButton.bottomAnchor, constant: 20),
            settingsButton.centerXAnchor.constraint(equalTo: lowerStack.centerXAnchor),
            
            howToPlayButton.topAnchor.constraint(equalTo: settingsButton.bottomAnchor, constant: 20),
            howToPlayButton.centerXAnchor.constraint(equalTo: lowerStack.centerXAnchor),
            
            winkAnimationView.widthAnchor.constraint(equalToConstant: EnterViewConstants.easterEggImageSize),
            winkAnimationView.heightAnchor.constraint(equalToConstant: EnterViewConstants.easterEggImageSize),
            winkAnimationView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            winkAnimationView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ])
    }
} 
