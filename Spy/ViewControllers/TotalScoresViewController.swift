//
//  TotalScoresViewController.swift
//  Spy
//
//  Created by Zeynep Müslim on 8.04.2025.
//

import UIKit
import SwiftUI

class TotalScoresViewController: UIViewController {
    
    // MARK: - Properties
    private var model = TotalScoresModel()
    
    // MARK: - UI Elements
    private lazy var newRoundButton = createPlayAgainButton()
    private let darkBottomView = CustomDarkScrollView()
    private let tableView = UITableView()
    private let titleVCLabel = UILabel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupConstraints()
        
        tableView.reloadData()
        
        model.performGameCleanup()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        let gradientView = GradientView(superView: view)
        view.insertSubview(gradientView, at: 0)
        view.addSubview(newRoundButton)
        view.addSubview(darkBottomView)
        
        setupTitleLabel()
    }
    
    private func setupTitleLabel() {
        titleVCLabel.text = "game_end_scores_title".localized
        titleVCLabel.font = UIFont.systemFont(ofSize: GeneralConstants.Font.size05, weight: .bold)
        titleVCLabel.textColor = .spyBlue01
        titleVCLabel.translatesAutoresizingMaskIntoConstraints = false
        
        darkBottomView.addSubview(titleVCLabel)
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ScoreCell")
        darkBottomView.addSubview(tableView)
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleVCLabel.topAnchor.constraint(equalTo: darkBottomView.topAnchor, constant: TotalScoresModel.Constants.bigMargin),
            titleVCLabel.leadingAnchor.constraint(equalTo: darkBottomView.leadingAnchor, constant: TotalScoresModel.Constants.bigMargin),
            titleVCLabel.trailingAnchor.constraint(equalTo: darkBottomView.trailingAnchor, constant: -TotalScoresModel.Constants.bigMargin),
            
            darkBottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: TotalScoresModel.Constants.bigMargin),
            darkBottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -TotalScoresModel.Constants.bigMargin),
            darkBottomView.bottomAnchor.constraint(equalTo: newRoundButton.topAnchor, constant: -TotalScoresModel.Constants.bigMargin),
            darkBottomView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: TotalScoresModel.Constants.bigMargin),
            
            tableView.leadingAnchor.constraint(equalTo: darkBottomView.leadingAnchor, constant: TotalScoresModel.Constants.littleMargin),
            tableView.trailingAnchor.constraint(equalTo: darkBottomView.trailingAnchor, constant: -TotalScoresModel.Constants.littleMargin),
            tableView.topAnchor.constraint(equalTo: titleVCLabel.bottomAnchor, constant: TotalScoresModel.Constants.littleMargin),
            tableView.bottomAnchor.constraint(equalTo: darkBottomView.bottomAnchor, constant: -TotalScoresModel.Constants.littleMargin),
            
            newRoundButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: TotalScoresModel.Constants.bigMargin),
            newRoundButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -TotalScoresModel.Constants.bigMargin),
            newRoundButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -TotalScoresModel.Constants.bigMargin),
            newRoundButton.heightAnchor.constraint(equalToConstant: TotalScoresModel.Constants.buttonsHeight),
        ])
    }
    
    // MARK: - Button Creation
    private func createPlayAgainButton() -> CustomGradientButton {
        let button = CustomGradientButton(
            labelText: "play_again".localized,
            width: 100,
            height: TotalScoresModel.Constants.buttonsHeight
        )
        button.onClick = { [weak self] in
            guard let self = self else { return }
            self.performSegue(withIdentifier: "unwindToMainMenu", sender: self)
        }
        return button
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension TotalScoresViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.getNumberOfPlayers()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScoreCell", for: indexPath)
        let playerScore = model.getPlayerScore(at: indexPath.row)
        let rank = indexPath.row + 1
        
        let rankEmoji = model.getRankEmoji(for: rank)
        let scoreText = model.getScoreText(for: playerScore)
        cell.textLabel?.text = "\(rankEmoji) \(scoreText)"
        
        let styling = model.getCellStyling(for: rank)
        cell.textLabel?.font = styling.font
        cell.textLabel?.textColor = styling.color
        
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        cell.contentView.backgroundColor = .clear
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

// MARK: - SwiftUI Preview
struct TotalScoresViewController_Previews: PreviewProvider {
    static var previews: some View {
        ViewControllerPreview {
            TotalScoresViewController()
        }
    }
}
