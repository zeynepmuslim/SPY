//
//  StartTimerViewController.swift
//  Spy
//
//  Created by Zeynep Müslim on 2.04.2025.
//

import SwiftUI
import UIKit

class StartTimerViewController: UIViewController {
    
    // MARK: - UI Elements
    private let bottomView = CustomDarkScrollView()
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    
    // MARK: - Managers
    private let timerManager = TimerManager.shared
    private var hintSpawningManager: HintLabelSpawningManager?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("StartTimerViewController loaded")
        setupUI()
        setupGestures()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startHintSpawning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopHintSpawning()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        let gradientView = GradientView(superView: view)
        view.addSubview(gradientView)
        view.addSubview(bottomView)
        
        setupLabels()
        setupViewHierarchy()
        setupConstraints()
    }
    
    private func setupLabels() {
        let spyCount = GameStateManager.shared.getSpyIndicesForCurrentRound().count
        titleLabel.text = "find_the_spy_before_time_runs_out".staticPlural(count: spyCount)
        titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: StartTimerConstants.FontSizes.titleSize)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        subtitleLabel.text = "tap_to_start_when_ready".localized
        subtitleLabel.textColor = .white
        subtitleLabel.font = UIFont.systemFont(ofSize: StartTimerConstants.FontSizes.subtitleSize)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.lineBreakMode = .byWordWrapping
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupViewHierarchy() {
        bottomView.addSubview(titleLabel)
        bottomView.addSubview(subtitleLabel)
        
        view.bringSubviewToFront(bottomView)
        bottomView.bringSubviewToFront(titleLabel)
        bottomView.bringSubviewToFront(subtitleLabel)
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Hint Spawning Management
    private func startHintSpawning() {
        guard hintSpawningManager == nil else { return }
        
        hintSpawningManager = HintLabelSpawningManager(parentView: view, bottomView: bottomView)
        
        if !timerManager.isTimerActive(identifier: StartTimerConstants.TimerIdentifiers.spawn) {
            hintSpawningManager?.spawnHintLabel()
            timerManager.createSpawnTimer(
                identifier: StartTimerConstants.TimerIdentifiers.spawn,
                target: self,
                selector: #selector(spawnLabel)
            )
        }
    }
    
    private func stopHintSpawning() {
        timerManager.stopTimer(identifier: StartTimerConstants.TimerIdentifiers.spawn)
        hintSpawningManager?.cleanup()
    }
    
    @objc private func spawnLabel() {
        hintSpawningManager?.spawnHintLabel()
    }
    
    // MARK: - Actions
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "TimerStarttoCountdown", sender: self)
    }
    
    // MARK: - Cleanup
    deinit {
        timerManager.stopTimer(identifier: StartTimerConstants.TimerIdentifiers.spawn)
        hintSpawningManager?.cleanup()
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            bottomView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            bottomView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bottomView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            bottomView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            
            titleLabel.centerXAnchor.constraint(equalTo: bottomView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor, constant: -40),
            titleLabel.widthAnchor.constraint(equalTo: bottomView.widthAnchor, multiplier: 0.8),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            subtitleLabel.centerXAnchor.constraint(equalTo: bottomView.centerXAnchor),
            subtitleLabel.widthAnchor.constraint(equalTo: bottomView.widthAnchor, multiplier: 0.8),
        ])
    }
}

// MARK: - Preview
struct StartTimerViewController_Previews: PreviewProvider {
    static var previews: some View {
        ViewControllerPreview {
            StartTimerViewController()
        }
    }
}
