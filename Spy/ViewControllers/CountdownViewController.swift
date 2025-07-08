//
//  CountdownViewController.swift
//  Spy
//
//  Created by Zeynep Müslim on 4.04.2025.
//

import SwiftUI
import UIKit
import CoreData

class CountdownViewController: UIViewController {
    
    // MARK: - Constants
    internal enum Constants {
        static let bigMargin: CGFloat = GeneralConstants.Layout.bigMargin
        static let littleMargin: CGFloat = GeneralConstants.Layout.littleMargin
        static let buttonsHeight: CGFloat = GeneralConstants.Button.biggerHeight
        
        static let shrinkTransform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        static let biggerTransform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        static let normalTransform = CGAffineTransform.identity
    }
    
    private enum TimerIdentifiers {
        static let countdown = "countdown_timer"
        static let hint = "hint_timer"
    }
    
    // MARK: - UI Components
    private lazy var gradientView = GradientView(superView: view)
    internal let darkBottomView = CustomDarkScrollView()
    internal lazy var blamePlayerButton = createBlamePlayerButton()
    
    internal let timeAndHintContainer = UIView()
    internal let hintContainer = UIView()
    internal let hintTitle = UILabel()
    internal let hintLabel = UILabel()
    internal let timeContainer = UIView()
    internal let timeLabel = UILabel()
    
    internal let topContainer = UIView()
    internal let bottomContainer = UIView()
    internal let containerView = UIView()
    
    internal let findSpyContainer = UIView()
    internal let findSpyTitle = UILabel()
    internal let findSpyLabel = UILabel()
    internal let pointsContainer = UIView()
    internal let pointsTitle = UILabel()
    internal let civilPointsLabel = UILabel()
    internal let spyPointsLabel = UILabel()
    internal let bottomLabel = UILabel()
    
    private let centeredFlowLayout = CenteredFlowLayout()
    internal lazy var collectionView = createCollectionView()
    
    // MARK: - Properties
    internal let countdownModel = CountdownModel()
    private let timerManager = TimerManager.shared
    
    private var timeLeftInSeconds: Int = 0
    private var currentHintIndex = 0
    internal var currentColumns: Int = 3
    private var lastKnownCollectionViewSize: CGSize = .zero
    internal var selectedIndex: IndexPath? = nil
    
    internal var isAnyCellSelected: Bool {
        return selectedIndex != nil
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupTimers()
        configureInitialState()
        
        GameStateManager.shared.printGameState("Round Start - Countdown")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        handleCollectionViewLayoutUpdate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAllTimers()
    }
    
    deinit {
        print("CountdownViewController: Deinit called")
        stopAllTimers()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setupMainViews()
        setupTimeAndHintViews()
        setupGameInfoViews()
    }
    
    private func setupMainViews() {
        darkBottomView.addSubview(containerView)
        containerView.addSubview(collectionView)
        
        [gradientView, darkBottomView, blamePlayerButton, timeAndHintContainer].forEach {
            view.addSubview($0)
        }
    }
    
    private func setupTimeAndHintViews() {
        timeAndHintContainer.addSubview(timeContainer)
        timeContainer.addSubview(timeLabel)
        
        configureLabel(timeLabel, text: "2:28", color: .white, font: .systemFont(ofSize: 70, weight: .black), alignment: .center)
        
        if countdownModel.isHintAvailable {
            timeAndHintContainer.addSubview(hintContainer)
            [hintTitle, hintLabel].forEach { hintContainer.addSubview($0) }
            
            configureLabel(hintTitle, text: "hints".localized, color: .white, font: .systemFont(ofSize: 20, weight: .bold), alignment: .center)
            configureLabel(hintLabel, text: "", color: .white, font: .systemFont(ofSize: 16, weight: .light), alignment: .center, numberOfLines: 0)
        }
        
        [timeAndHintContainer, hintContainer, timeContainer].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setupGameInfoViews() {
        darkBottomView.addSubview(topContainer)
        darkBottomView.addSubview(bottomContainer)
        
        topContainer.addSubview(findSpyContainer)
        topContainer.addSubview(pointsContainer)
        bottomContainer.addSubview(bottomLabel)
        
        findSpyContainer.addSubview(findSpyTitle)
        findSpyContainer.addSubview(findSpyLabel)
        
        pointsContainer.addSubview(pointsTitle)
        pointsContainer.addSubview(civilPointsLabel)
        pointsContainer.addSubview(spyPointsLabel)
        
        configureGameInfoLabels()
        
        [topContainer, bottomContainer, findSpyContainer, pointsContainer].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func configureGameInfoLabels() {
        let spyCount = countdownModel.spyIndices.count
        configureLabel(findSpyTitle, text: "find_the_spies".staticPlural(count: spyCount), color: .white, font: .systemFont(ofSize: 16, weight: .bold), alignment: .left)
        configureLabel(findSpyLabel, text: "select_a_player_to_blame".localized, color: .spyBlue01, font: .systemFont(ofSize: 12, weight: .regular), alignment: .left, numberOfLines: 0)
        configureLabel(pointsTitle, text: "player_was_a_civilian".localized.uppercased(), color: .white, font: .systemFont(ofSize: 14, weight: .heavy), alignment: .right)
        configureLabel(civilPointsLabel, text: "-1_point_for_each_civilian".localized, color: .spyBlue01, font: .systemFont(ofSize: 14, weight: .regular), alignment: .right)
        configureLabel(spyPointsLabel, text: "+1_point_for_each_spy".staticPlural(count: spyCount), color: .spyRed01, font: .systemFont(ofSize: 16, weight: .regular), alignment: .right)
        configureLabel(bottomLabel, text: "false_blame_warning_label".localized, color: .white, font: .systemFont(ofSize: 10, weight: .regular), alignment: .left, numberOfLines: 0)
    }
    
    // MARK: - Helper Methods
    private func configureLabel(_ label: UILabel, text: String, color: UIColor, font: UIFont, alignment: NSTextAlignment, numberOfLines: Int = 1) {
        label.text = text
        label.textColor = color
        label.textAlignment = alignment
        label.font = font
        label.numberOfLines = numberOfLines
        if numberOfLines == 0 {
            label.lineBreakMode = .byWordWrapping
        }
        label.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func createCollectionView() -> UICollectionView {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: centeredFlowLayout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.register(ChildCollectionViewCell.self, forCellWithReuseIdentifier: ChildCollectionViewCell.identifier)
        cv.dataSource = self
        cv.delegate = self
        cv.allowsMultipleSelection = false
        return cv
    }
    
    private func createBlamePlayerButton() -> CustomGradientButton {
        let button = CustomGradientButton(
            labelText: "blame_the_player".localized,
            height: GeneralConstants.Button.biggerHeight
        )
        
        button.setStatus(.deactive)
        button.isUserInteractionEnabled = false
        
        button.onClick = { [weak self] in
            self?.handleBlameButtonTapped()
        }
        return button
    }
    

    
    // MARK: - Configuration
    private func configureInitialState() {
        pointsContainer.isHidden = true
        currentColumns = determineColumns(for: countdownModel.numberOfPlayers)
        configureLayout(columns: currentColumns)
        collectionView.reloadData()
    }
    
    private func handleCollectionViewLayoutUpdate() {
        let currentSize = collectionView.bounds.size
        if currentSize != .zero && currentSize != lastKnownCollectionViewSize {
            lastKnownCollectionViewSize = currentSize
            centeredFlowLayout.invalidateLayout()
        }
    }
    
    private func determineColumns(for count: Int) -> Int {
        if count == 4 { return 2 }
        return (count <= 6) ? 3 : 2
    }
    
    private func configureLayout(columns: Int) {
        guard let layout = collectionView.collectionViewLayout as? CenteredFlowLayout else { return }
        
        self.currentColumns = columns
        let horizontalPadding: CGFloat = 10
        let verticalPadding: CGFloat = 10
        layout.sectionInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
        layout.minimumInteritemSpacing = horizontalPadding
        layout.minimumLineSpacing = verticalPadding
        layout.invalidateLayout()
    }
    
    // MARK: - Timer Management
    private func setupTimers() {
        setupCountdownTimer()
        if countdownModel.isHintAvailable {
            setupHintTimer()
        }
    }
    
    private func setupCountdownTimer() {
        guard let durationMinutes = Int(countdownModel.roundDuration) else {
            print("Error: Could not parse round duration: \(countdownModel.roundDuration)")
            timeLeftInSeconds = 60
            updateTimeLabel()
            return
        }
        
        timeLeftInSeconds = durationMinutes * 60
        updateTimeLabel()
        
        timerManager.createCountdownTimer(identifier: TimerIdentifiers.countdown, target: self, selector: #selector(updateTimer))
    }
    
    @objc private func updateTimer() {
        if timeLeftInSeconds > 0 {
            timeLeftInSeconds -= 1
            updateTimeLabel()
        } else {
            handleTimerFinished()
        }
    }
    
    private func updateTimeLabel() {
        let minutes = timeLeftInSeconds / 60
        let seconds = timeLeftInSeconds % 60
        timeLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func handleTimerFinished() {
        stopAllTimers()
        print("Timer finished!")
        
        let result = countdownModel.processTimeUp()
        showEndGameUI(message: result.endMessage)
        
        blamePlayerButton.isUserInteractionEnabled = false
        collectionView.isUserInteractionEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.performSegue(withIdentifier: "CountdownToScores", sender: self)
        }
    }
    
    private func setupHintTimer() {
        guard !countdownModel.hints.isEmpty else {
            hintLabel.text = "there_is_no_hints_for_this_category".localized
            return
        }
        
        updateHint()
        timerManager.createHintTimer(identifier: TimerIdentifiers.hint, target: self, selector: #selector(updateHint))
    }
    
    @objc private func updateHint() {
        guard !countdownModel.hints.isEmpty else { return }
        
        UIView.transition(with: hintLabel, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.hintLabel.text = self.countdownModel.hints[self.currentHintIndex].localized
        }, completion: nil)
        print("Hint spawn: \(countdownModel.hints[currentHintIndex])")
        
        currentHintIndex = (currentHintIndex + 1) % countdownModel.hints.count
    }
    
    private func stopAllTimers() {
        timerManager.stopTimer(identifier: TimerIdentifiers.countdown)
        timerManager.stopTimer(identifier: TimerIdentifiers.hint)
    }
    
    // MARK: - Game Actions
    @objc private func handleBlameButtonTapped() {
        guard let selected = selectedIndex else {
            print("Blame button tapped but no player selected.")
            return
        }
        
        let selectedPlayerIndex = selected.item
        let result = countdownModel.processPlayerBlame(selectedPlayerIndex: selectedPlayerIndex)
        
        updateUIAfterBlame(result: result)
        updateCollectionViewAfterBlame()
        
        if result.shouldEndGame {
            handleGameEnd(result: result)
        } else {
            showTemporaryPointsDisplay(result: result)
        }
    }
    
    private func updateUIAfterBlame(result: BlameResult) {
        let displayInfo = result.getPointsDisplayInfo()
        
        pointsTitle.text = displayInfo.title
        civilPointsLabel.isHidden = !displayInfo.showCivilianPoints
        spyPointsLabel.isHidden = !displayInfo.showSpyPoints
        
        selectedIndex = nil
        blamePlayerButton.setStatus(.deactive)
        blamePlayerButton.isUserInteractionEnabled = false
    }
    
    private func updateCollectionViewAfterBlame() {
        UIView.animate(withDuration: 0.3) {
            for visibleCell in self.collectionView.visibleCells {
                guard let cell = visibleCell as? ChildCollectionViewCell,
                      let indexPathForCell = self.collectionView.indexPath(for: cell) else { continue }
                
                let (targetStatus, targetTransform) = self.getTargetState(for: indexPathForCell, currentlySelectedIndex: nil)
                
                let isDeactivated = self.countdownModel.isPlayerDeactivated(indexPathForCell.item)
        if isDeactivated {
                    let isSpy = self.countdownModel.isPlayerSpy(indexPathForCell.item)
            cell.setRole(isSpy: isSpy)
        }
        
                cell.setStatus(targetStatus)
                cell.transform = targetTransform
        cell.isUserInteractionEnabled = !isDeactivated
            }
        }
    }
    
    private func handleGameEnd(result: BlameResult) {
        if result.shouldEndGame {
            stopAllTimers()
            showEndGameUI(message: result.endMessage ?? "")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.performSegue(withIdentifier: "CountdownToScores", sender: self)
                self.blamePlayerButton.isUserInteractionEnabled = false
                self.collectionView.isUserInteractionEnabled = false
            }
        }
    }
    
    private func showEndGameUI(message: String) {
        pointsTitle.text = message.uppercased()
        civilPointsLabel.isHidden = true
        spyPointsLabel.isHidden = true
        pointsContainer.alpha = 0
        pointsContainer.isHidden = false
        UIView.animate(withDuration: 0.5, delay: 0.1) {
            self.pointsContainer.alpha = 1
        }
    }
    
    private func showTemporaryPointsDisplay(result: BlameResult) {
        pointsContainer.alpha = 0
        pointsContainer.isHidden = false
        UIView.animate(withDuration: 0.5, delay: 0.1, animations: {
            self.pointsContainer.alpha = 1
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                UIView.animate(withDuration: 0.5, animations: {
                    self.pointsContainer.alpha = 0
                }) { _ in
                    self.pointsContainer.isHidden = true
                }
            }
        }
    }
    
    // MARK: - Helper for Cell States
    internal func getTargetState(for indexPath: IndexPath, currentlySelectedIndex: IndexPath?) -> (status: ButtonStatus, transform: CGAffineTransform) {
        let isCurrentCellSelected = (indexPath == currentlySelectedIndex)
        let anyCellSelected = self.isAnyCellSelected
        
        if countdownModel.isPlayerDeactivated(indexPath.item) {
            return (.deactive, Constants.shrinkTransform)
        }
        
        if isCurrentCellSelected {
            return (.activeRed, Constants.biggerTransform)
        } else {
            let status: ButtonStatus = .activeBlue
            let transform = anyCellSelected ? Constants.shrinkTransform : Constants.normalTransform
            return (status, transform)
        }
    }
}



// MARK: - Navigation
extension CountdownViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Segue performed: \(segue.identifier ?? "unknown")")
    }
}

// MARK: - SwiftUI Preview
struct VCountdownViewController_Previews: PreviewProvider {
    static var previews: some View {
        ViewControllerPreview {
            CountdownViewController()
        }
    }
}
