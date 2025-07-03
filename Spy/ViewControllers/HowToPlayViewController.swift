//
//  HowToPlayViewController.swift
//  Spy
//
//  Created by Zeynep Müslim on 8.04.2025.
//

import UIKit
import SwiftUI

class HowToPlayViewController: UIViewController, CustomCardViewDelegate, UIViewControllerTransitioningDelegate {
    
    // MARK: - Constants
    private struct Constants {
        static let cardScale: CGFloat = 0.94
        static let verticalOffset: CGFloat = 25
        static let screenWidthMultiplier: CGFloat = 0.7
        static let backButtonSize: CGFloat = 40
        static let backButtonMargin: CGFloat = 8
        
        struct Animation {
            static let cardEntryDuration: TimeInterval = 0.6
            static let cardEntryDelay: TimeInterval = 0.12
            static let cardMoveDuration: TimeInterval = 0.5
            static let cardMoveDelay: TimeInterval = 0.05
            static let springDamping: CGFloat = 0.7
            static let moveDamping: CGFloat = 0.8
            static let springVelocity: CGFloat = 0.5
            static let cardInitialOffset: CGFloat = -200
        }
    }
    
    // MARK: - UI Components
    private lazy var backButton = BackButton(target: self, action: #selector(customBackAction))
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Data Properties
    private var howToPlayTitles: [String] = []
    private var howToPlayTexts: [String] = []
    private var cardViews: [CustomCardView] = []
    private var playerCount: Int = 0
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        setupBackButton()
        loadHowToPlayData()
        setupUI()
        setupCards()
    }
    
    // MARK: - Setup Methods
    private func setupGradientBackground() {
        let gradientView = GradientView(superView: view)
        view.insertSubview(gradientView, at: 0)
    }
    
    private func setupBackButton() {
        view.addSubview(backButton)
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.backButtonMargin),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            backButton.widthAnchor.constraint(equalToConstant: Constants.backButtonSize),
            backButton.heightAnchor.constraint(equalToConstant: Constants.backButtonSize)
        ])
    }
    
    private func setupUI() {
        view.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: Constants.screenWidthMultiplier),
            containerView.heightAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: Constants.screenWidthMultiplier * 2)
        ])
    }
    
    private func setupCards() {
        for i in 0..<playerCount {
            let cardView = createCardView(at: i)
            addCardToContainer(cardView, at: i)
            animateCardEntry(cardView, at: i)
        }
    }
    
    // MARK: - Data Loading
    private func loadHowToPlayData() {
        guard let url = Bundle.main.url(forResource: "how_to_play", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let howToPlayData = try? JSONDecoder().decode(HowToPlayData.self, from: data) else {
            print("Failed to load HowToPlay.json")
            return
        }
        
        howToPlayTitles = howToPlayData.howToPlay.map { $0.title }
        howToPlayTexts = howToPlayData.howToPlay.map { $0.text }
        playerCount = howToPlayTitles.count
    }
    
    // MARK: - Card Creation and Management
    private func createCardView(at index: Int) -> CustomCardView {
        let cardView = CustomCardView()
        cardView.delegate = self
        cardView.isFlipEnabled = false
        cardView.setStatus(.activeBlue)
        cardView.configure(role: howToPlayTitles[index].localized, frontText: howToPlayTexts[index].localized, spyCount: 1)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        return cardView
    }
    
    private func addCardToContainer(_ cardView: CustomCardView, at index: Int) {
        containerView.insertSubview(cardView, at: 0)
        cardViews.append(cardView)
        
        cardView.alpha = 0
        cardView.transform = CGAffineTransform(translationX: 0, y: Constants.Animation.cardInitialOffset)
        
        NSLayoutConstraint.activate([
            cardView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            cardView.widthAnchor.constraint(equalTo: containerView.widthAnchor),
            cardView.heightAnchor.constraint(equalTo: containerView.heightAnchor)
        ])
    }
    
    // MARK: - Animation Methods
    private func animateCardEntry(_ cardView: CustomCardView, at index: Int) {
        let transform = calculateCardTransform(for: index)
        
        UIView.animate(
            withDuration: Constants.Animation.cardEntryDuration,
            delay: Double(index) * Constants.Animation.cardEntryDelay,
            usingSpringWithDamping: Constants.Animation.springDamping,
            initialSpringVelocity: Constants.Animation.springVelocity,
            options: .curveEaseInOut
        ) {
            cardView.alpha = 1
            cardView.transform = transform
            cardView.layer.zPosition = CGFloat(self.playerCount - index)
        } completion: { _ in
            if index == 0 {
                cardView.isInteractionEnabled = true
            }
        }
    }
    
    private func calculateCardTransform(for index: Int) -> CGAffineTransform {
        let scale = pow(Constants.cardScale, CGFloat(index))
        let yOffset = CGFloat(index) * -Constants.verticalOffset
        
        let scaleTransform = CGAffineTransform(scaleX: scale, y: scale)
        let translateTransform = CGAffineTransform(translationX: 0, y: yOffset)
        
        return scaleTransform.concatenating(translateTransform)
    }
    
    private func animateCardsPosition() {
        for (index, card) in cardViews.enumerated() {
            let transform = calculateCardTransform(for: index)
            
            UIView.animate(
                withDuration: Constants.Animation.cardMoveDuration,
                delay: Double(index) * Constants.Animation.cardMoveDelay,
                usingSpringWithDamping: Constants.Animation.moveDamping,
                initialSpringVelocity: Constants.Animation.springVelocity,
                options: .curveEaseInOut
            ) {
                card.transform = transform
                card.layer.zPosition = CGFloat(self.cardViews.count - index)
            }
        }
    }
    
    // MARK: - CustomCardViewDelegate
    func cardViewWasDismissed(_ cardView: CustomCardView) {
        guard let index = cardViews.firstIndex(of: cardView) else { return }
        
        cardViews.remove(at: index)
        cardViews.first?.isInteractionEnabled = true
        animateCardsPosition()
        
        if cardViews.isEmpty {
            setupCards()
        }
    }
    
    // MARK: - UIViewControllerTransitioningDelegate
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return StoryboardFadeToBlueUnwind()
    }
    
    // MARK: - Actions
    @objc private func customBackAction() {
        performSegue(withIdentifier: "unwindFromHowToPlay", sender: self)
    }
}

// MARK: - SwiftUI Preview
struct HowToPlayViewController_Previews: PreviewProvider {
    static var previews: some View {
        ViewControllerPreview {
            HowToPlayViewController()
        }
    }
}
