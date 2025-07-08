//
//  ScoresViewController.swift
//  Spy
//
//  Created by Zeynep Müslim on 8.04.2025.
//

import UIKit
import SwiftUI

class ScoresViewController: UIViewController {
    
    // MARK: - Properties
    internal let model = ScoresModel()
    internal lazy var newRoundButton = createNewRoundButton()
    internal let darkBottomView = CustomDarkScrollView()
    
    // MARK: - UI Elements
    internal let winnerLabel = UILabel()
    internal let selectedWordLabel = UILabel()
    internal let scoreLabelsContainer = UIView()
    internal let civilPointLabel = UILabel()
    internal let spyPointLabel = UILabel()
    internal let bottomInfoLabel = UILabel()
    internal let remainHandlabel = UILabel()
    internal let containerView = UIView()
    
    // MARK: - Collection View
    private var centeredFlowLayout = CenteredFlowLayout()
    private var currentColumns: Int = 3
    private var lastKnownCollectionViewSize: CGSize = .zero
    
    internal lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: centeredFlowLayout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.register(ScoreCellContainer.self, forCellWithReuseIdentifier: ScoreCellContainer.identifier)
        cv.dataSource = self
        cv.delegate = self
        cv.allowsMultipleSelection = false
        return cv
    }()
    
    // MARK: - Constants
    internal enum Constants {
        static let bigMargin: CGFloat = GeneralConstants.Layout.bigMargin
        static let littleMargin: CGFloat = GeneralConstants.Layout.littleMargin
        static let buttonsHeight: CGFloat = GeneralConstants.Button.biggerHeight
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateContent()
        setupCollectionView()
        
        print("--- ScoresViewController viewDidLoad ---")
        GameStateManager.shared.printGameState("Round End - Scores")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        handleCollectionViewSizeChange()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setupGradientBackground()
        setupMainViews()
        setupLabels()
        setupConstraints()
    }
    
    private func setupGradientBackground() {
        let gradientView = GradientView(superView: view)
        view.insertSubview(gradientView, at: 0)
    }
    
    private func setupMainViews() {
        view.addSubview(newRoundButton)
        view.addSubview(darkBottomView)
        
        [winnerLabel, selectedWordLabel, containerView, scoreLabelsContainer, bottomInfoLabel, remainHandlabel].forEach {
            darkBottomView.addSubview($0)
        }
        
        scoreLabelsContainer.addSubview(civilPointLabel)
        scoreLabelsContainer.addSubview(spyPointLabel)
        containerView.addSubview(collectionView)
    }
    
    private func setupLabels() {
        [winnerLabel, selectedWordLabel, containerView, scoreLabelsContainer,
         civilPointLabel, spyPointLabel, bottomInfoLabel, remainHandlabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [winnerLabel, selectedWordLabel, civilPointLabel, spyPointLabel, bottomInfoLabel, remainHandlabel].forEach {
            $0.textColor = .white
        }
        
        civilPointLabel.font = .systemFont(ofSize: 30, weight: .regular)
        spyPointLabel.font = .systemFont(ofSize: 30, weight: .regular)
        
        bottomInfoLabel.text = "score_bottom_info_text".localized
        bottomInfoLabel.numberOfLines = 0
        bottomInfoLabel.lineBreakMode = .byWordWrapping
        bottomInfoLabel.textAlignment = .center
        bottomInfoLabel.font = .systemFont(ofSize: GeneralConstants.Font.size01, weight: .regular)
        
        remainHandlabel.font = .systemFont(ofSize: GeneralConstants.Font.size01, weight: .regular)
        remainHandlabel.textAlignment = .center
    }
    
    // MARK: - Content Updates
    private func updateContent() {
        updateLabels()
        updateCollectionViewLayout()
    }
    
    private func updateLabels() {
        winnerLabel.text = model.getWinnerText()
        selectedWordLabel.text = model.getSelectedWordText()
        civilPointLabel.text = model.getCivilianPointsText()
        spyPointLabel.text = model.getSpyPointsText()
        remainHandlabel.text = model.getRemainingRoundsText()
    }
    
    // MARK: - Collection View Setup
    private func setupCollectionView() {
        updateCollectionViewLayout()
        collectionView.reloadData()
    }
    
    private func updateCollectionViewLayout() {
        currentColumns = model.determineColumns(for: model.numberOfChildren)
        configureLayout(columns: currentColumns)
    }
    
    private func handleCollectionViewSizeChange() {
        let currentSize = collectionView.bounds.size
        if currentSize != .zero && currentSize != lastKnownCollectionViewSize {
            lastKnownCollectionViewSize = currentSize
            centeredFlowLayout.invalidateLayout()
        }
    }
    
    private func configureLayout(columns: Int) {
        guard let layout = collectionView.collectionViewLayout as? CenteredFlowLayout else { return }
        
        self.currentColumns = columns
        let horizontalPadding: CGFloat = 10
        let verticalPadding: CGFloat = 20
        layout.sectionInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
        layout.minimumInteritemSpacing = horizontalPadding
        layout.minimumLineSpacing = verticalPadding
        layout.invalidateLayout()
    }
    
    // MARK: - Button Creation
    private func createNewRoundButton() -> CustomGradientButton {
        let button = CustomGradientButton(
            labelText: getButtonText(), width: 100,
            height: GeneralConstants.Button.biggerHeight)
        
        button.onClick = { [weak self] in
            self?.handleNewRoundButtonTap()
        }
        return button
    }
    
    private func getButtonText() -> String {
        return model.hasNextRound() ? "next_round".localized : "view_final_scores".localized
    }
    
    private func handleNewRoundButtonTap() {
        model.proceedToNextStep { [weak self] navigationType in
            switch navigationType {
            case .nextRound:
                self?.performSegue(withIdentifier: "ScoresToGameCards", sender: self)
            case .totalScores:
                self?.performSegue(withIdentifier: "ScoresToTotalScores", sender: self)
            }
        }
    }
    
    
}

// MARK: - UICollectionViewDataSource
extension ScoresViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.numberOfChildren
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ScoreCellContainer.identifier, for: indexPath) as? ScoreCellContainer else {
            fatalError("ScoreCellContainer dequeue failed")
        }
        
        let configuration = model.getCellConfiguration(for: indexPath)
        let isVerticalLayout = model.shouldUseVerticalLayout()
        
        cell.configure(
            childId: configuration.childId,
            iconName: configuration.iconName,
            topLabelText: configuration.topLabelText,
            bottomLabelText: configuration.bottomLabelText,
            isVerticalLayout: isVerticalLayout,
            numberOfChildren: model.numberOfChildren,
            status: configuration.status,
            isSpy: configuration.isSpy
        )
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ScoresViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return .zero
        }
        
        let columns = CGFloat(self.currentColumns)
        let horizontalPadding = layout.minimumInteritemSpacing
        let sectionInsets = layout.sectionInset
        let totalHorizontalPadding = sectionInsets.left + sectionInsets.right + (horizontalPadding * (columns - 1))
        let availableWidth = max(1, collectionView.bounds.width - totalHorizontalPadding)
        let itemWidth = availableWidth / columns
        
        let actualRows = ceil(CGFloat(model.numberOfChildren) / columns)
        let verticalPadding = layout.minimumLineSpacing
        let totalVerticalPadding = sectionInsets.top + sectionInsets.bottom + (verticalPadding * (actualRows - 1))
        let availableHeight = max(1, collectionView.bounds.height - totalVerticalPadding)
        let itemHeight = availableHeight / actualRows
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
}

// MARK: - Navigation
extension ScoresViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Segue performed: \(segue.identifier ?? "unknown")")
    }
}

// MARK: - SwiftUI Preview
struct ScoresViewController_Previews: PreviewProvider {
    static var previews: some View {
        ViewControllerPreview {
            ScoresViewController()
        }
    }
}
