//
//  GameCardsViewController.swift
//  Spy
//
//  Created by Zeynep Müslim on 10.03.2025.

import SwiftUI
import UIKit
import CoreData

class GameCardsViewController: UIViewController, CustomCardViewDelegate {
    
    // MARK: - UI Properties
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var cardViews: [CustomCardView] = []
    private let bottomLabel = UILabel()
    
    // MARK: - Animation Constants
    private let cardScale: CGFloat = 0.94
    private let verticalOffset: CGFloat = 25
    private let screenWidthMultiplier: CGFloat = 0.7
    
    private var model: GameCardsModel!
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupModel()
        setupView()
        setupUI()
        setupCards()
    }
    
    // MARK: - Setup Methods
    private func setupModel() {
        model = GameCardsModel()
    }
    
    private func setupView() {
        let gradientView = GradientView(superView: view)
        view.insertSubview(gradientView, at: 0)
        
        bottomLabel.text = "swipe_the_card_before_next_player".localized
        bottomLabel.textColor = .white
        bottomLabel.font = UIFont.systemFont(ofSize: 16)
        bottomLabel.textAlignment = .center
        bottomLabel.numberOfLines = 0
        bottomLabel.lineBreakMode = .byWordWrapping
        bottomLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomLabel)
    }
    
    private func setupUI() {
        view.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: screenWidthMultiplier),
            containerView.heightAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: screenWidthMultiplier*2),
            
            bottomLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bottomLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            bottomLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7)
        ])
    }
    
    private func setupCards() {
        for i in 0..<model.playerCount {
            let cardView = createCardView(for: i)
            setupCardConstraints(cardView)
            animateCardEntrance(cardView, index: i)
            cardViews.append(cardView)
        }
    }
    
    // MARK: - Card Creation and Setup
    private func createCardView(for index: Int) -> CustomCardView {
        let cardView = CustomCardView()
        cardView.delegate = self
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        let configuration = model.getCardConfiguration(for: index)
        cardView.configure(
            role: configuration.role,
            selectedWord: configuration.selectedWord,
            isSpy: configuration.isSpy,
            spyCount: model.spyCount
        )
        
        containerView.insertSubview(cardView, at: 0)
        cardView.alpha = 0
        cardView.transform = CGAffineTransform(translationX: 0, y: -200)
        
        return cardView
    }
    
    private func setupCardConstraints(_ cardView: CustomCardView) {
        NSLayoutConstraint.activate([
            cardView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            cardView.widthAnchor.constraint(equalTo: containerView.widthAnchor),
            cardView.heightAnchor.constraint(equalTo: containerView.heightAnchor)
        ])
    }
    
    // MARK: - Animation Methods
    private func animateCardEntrance(_ cardView: CustomCardView, index: Int) {
        let scale = pow(cardScale, CGFloat(index))
        let yOffset = CGFloat(index) * -verticalOffset
        
        UIView.animate(withDuration: 0.6,
                       delay: Double(index) * 0.12,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseInOut) {
            cardView.alpha = 1
            let scaleTransform = CGAffineTransform(scaleX: scale, y: scale)
            let translateTransform = CGAffineTransform(translationX: 0, y: yOffset)
            cardView.transform = scaleTransform.concatenating(translateTransform)
            cardView.layer.zPosition = CGFloat(self.model.playerCount - index)
        } completion: { _ in
            if index == 0 {
                cardView.isInteractionEnabled = true
            }
        }
    }
    
    private func animateCardsPosition() {
        for (index, card) in cardViews.enumerated() {
            let scale = pow(cardScale, CGFloat(index))
            let yOffset = CGFloat(index) * -verticalOffset
            
            UIView.animate(withDuration: 0.5,
                           delay: Double(index) * 0.05,
                           usingSpringWithDamping: 0.8,
                           initialSpringVelocity: 0.5,
                           options: .curveEaseInOut) {
                let scaleTransform = CGAffineTransform(scaleX: scale, y: scale)
                let translateTransform = CGAffineTransform(translationX: 0, y: yOffset)
                card.transform = scaleTransform.concatenating(translateTransform)
                
                card.layer.zPosition = CGFloat(self.cardViews.count - index)
            }
        }
    }
    
    // MARK: - CustomCardViewDelegate
    func cardViewWasDismissed(_ cardView: CustomCardView) {
        if let index = cardViews.firstIndex(of: cardView) {
            cardViews.remove(at: index)
            
            cardViews.first?.isInteractionEnabled = true
            
            animateCardsPosition()
            
            if cardViews.isEmpty {
                performSegue(withIdentifier: "CardsToTimerStart", sender: nil)
            }
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Prepare for segue called with identifier: \(segue.identifier ?? "nil")")
        
        if segue.identifier == "CardsToTimerStart" {
            print("Segue identifier matches 'CardsToTimerStart'")
        } else {
            print("Segue identifier does NOT match known identifiers")
        }
    }
}

// MARK: - SwiftUI Preview
struct ViewController_Previews6: PreviewProvider {
    static var previews: some View {
        ViewControllerPreview {
            GameCardsViewController()
        }
    }
}
