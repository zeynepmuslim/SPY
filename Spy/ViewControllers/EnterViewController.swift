//
//  ViewController.swift
//  Spy
//
//  Created by Zeynep Müslim on 4.03.2025.
//

import UIKit
import SwiftUI
import CoreData

class EnterViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    // MARK: - Core Data Properties
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let fetchRequestCategory: NSFetchRequest<Category> = Category.fetchRequest()
    let fetchRequestPlayers: NSFetchRequest<Player> = Player.fetchRequest()
    let fetchRequestGameSession: NSFetchRequest<GameSession> = GameSession.fetchRequest()
    
    // MARK: - UI Elements
    internal let magnifyingGlassImageView = UIImageView()
    internal let magnifyingGlassStack = UIView()
    internal let backgroundImageView = UIImageView()
    internal let magnifyingGlassEmptyImageView = UIImageView()
    internal var initialLayoutDone = false
    internal let lowerStack = UIStackView()
    internal let upperStack = UIView()
    internal let backgroundImageViewNormal = UIImageView()
    internal let titleLabel = UILabel()
    internal let gradientBallView = UIView()
    
    // MARK: - Buttons
    let startGameButton: CustomGradientButton
    let settingsButton: CustomGradientButton
    let howToPlayButton: CustomGradientButton
    
    // MARK: - Easter Egg
    var winkAnimationView: WinkAnimationView!
    
    // MARK: - Managers
    private var animationManager: EnterViewAnimationManager!
    private var gestureManager: EnterViewGestureManager!
    
    // MARK: - Initialization
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let buttons = EnterViewUIManager.createMainButtons()
        self.startGameButton = buttons.start
        self.settingsButton = buttons.settings
        self.howToPlayButton = buttons.howToPlay
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        let buttons = EnterViewUIManager.createMainButtons()
        self.startGameButton = buttons.start
        self.settingsButton = buttons.settings
        self.howToPlayButton = buttons.howToPlay
        
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("EnterViewController: viewDidLoad called")
        
        setupView()
        setupManagers()
        setupUIElements()
        setupButtonActions()
        setupConstraints()
        
        // Remove any non-default sessions to guarantee a clean state on the menu screen
        purgeCustomSessionsIfNeeded()
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        let gradientView = GradientView(superView: view)
        view.addSubview(gradientView)
    }
    
    private func setupManagers() {
        animationManager = EnterViewAnimationManager(viewController: self)
        gestureManager = EnterViewGestureManager(viewController: self, animationManager: animationManager)
    }
    
    private func setupUIElements() {
        let imageViews = EnterViewUIManager.configureImageViews()
        magnifyingGlassImageView.image = imageViews.magnifyingGlass.image
        magnifyingGlassImageView.contentMode = imageViews.magnifyingGlass.contentMode
        
        magnifyingGlassEmptyImageView.image = imageViews.magnifyingGlassEmpty.image
        magnifyingGlassEmptyImageView.contentMode = imageViews.magnifyingGlassEmpty.contentMode
        
        backgroundImageView.image = imageViews.background.image
        backgroundImageView.contentMode = imageViews.background.contentMode
        backgroundImageView.clipsToBounds = imageViews.background.clipsToBounds
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        
        backgroundImageViewNormal.image = imageViews.backgroundNormal.image
        backgroundImageViewNormal.contentMode = imageViews.backgroundNormal.contentMode
        backgroundImageViewNormal.translatesAutoresizingMaskIntoConstraints = false
        
        let stackViews = EnterViewUIManager.configureStackViews()
        upperStack.translatesAutoresizingMaskIntoConstraints = stackViews.upper.translatesAutoresizingMaskIntoConstraints
        lowerStack.axis = stackViews.lower.axis
        lowerStack.spacing = stackViews.lower.spacing
        lowerStack.translatesAutoresizingMaskIntoConstraints = stackViews.lower.translatesAutoresizingMaskIntoConstraints
        magnifyingGlassStack.translatesAutoresizingMaskIntoConstraints = stackViews.magnifyingGlass.translatesAutoresizingMaskIntoConstraints
        
        let configuredTitleLabel = EnterViewUIManager.configureTitleLabel()
        titleLabel.text = configuredTitleLabel.text
        titleLabel.textColor = configuredTitleLabel.textColor
        titleLabel.font = configuredTitleLabel.font
        titleLabel.textAlignment = configuredTitleLabel.textAlignment
        titleLabel.translatesAutoresizingMaskIntoConstraints = configuredTitleLabel.translatesAutoresizingMaskIntoConstraints
        
        view.addSubview(upperStack)
        view.addSubview(magnifyingGlassStack)
        view.addSubview(lowerStack)
        
        magnifyingGlassStack.insertSubview(backgroundImageView, at: 0)
        magnifyingGlassStack.mask = magnifyingGlassImageView
        magnifyingGlassStack.addSubview(magnifyingGlassEmptyImageView)
        
        upperStack.addSubview(backgroundImageViewNormal)
        
        lowerStack.addSubview(titleLabel)
        lowerStack.addSubview(startGameButton)
        lowerStack.addSubview(settingsButton)
        lowerStack.addSubview(howToPlayButton)
        
        winkAnimationView = WinkAnimationView(role: .spy, color: .white, sideLength: EnterViewConstants.easterEggImageSize)
        winkAnimationView.translatesAutoresizingMaskIntoConstraints = false
        magnifyingGlassStack.insertSubview(winkAnimationView, at: 2)
        
        EnterViewUIManager.configureGradientBall(
            gradientBallView: gradientBallView,
            winkAnimationView: winkAnimationView,
            magnifyingGlassStack: magnifyingGlassStack,
            viewWidth: view.bounds.width
        )
        
        view.bringSubviewToFront(magnifyingGlassStack)
        gestureManager.setupPanGesture(for: magnifyingGlassStack)
    }
    
    private func setupButtonActions() {
        startGameButton.onClick = { [weak self] in
            guard let self = self else { return }
            print("Start Game Button Clicked!")
            self.performSegue(withIdentifier: "menuToGameSettings", sender: self)
        }
        
        settingsButton.onClick = { [weak self] in
            guard let self = self else { return }
            print("Settings Button Clicked!")
            self.performSegue(withIdentifier: "EnterToDefaultSettings", sender: self)
        }
        
        howToPlayButton.onClick = { [weak self] in
            guard let self = self else { return }
            print("How to Play Button Clicked!")
            self.performSegue(withIdentifier: "EnterToHowToPlay", sender: self)
                }
    }
    
    // MARK: - View Lifecycle
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("EnterViewController: viewDidLayoutSubviews called")
        
        if !initialLayoutDone {
            initialLayoutDone = EnterViewLayoutManager.performInitialLayout(
                magnifyingGlassStack: magnifyingGlassStack,
                magnifyingGlassEmptyImageView: magnifyingGlassEmptyImageView
            )
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("EnterViewController: viewDidAppear called")
        animationManager.animateMaskRandomly()
        animationManager.startMaskAnimationTimer(magnifyingGlassStack: magnifyingGlassStack, initialLayoutDone: initialLayoutDone)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("EnterViewController: viewWillDisappear called")
        animationManager.stopMaskAnimationTimer()
    }
    
    deinit {
        print("EnterViewController: Deinit called")
        animationManager?.stopMaskAnimationTimer()
    }
    
    // MARK: - Navigation
    @IBAction func unwindToEnter(segue: UIStoryboardSegue) {
        print("EnterViewController: unwindToEnter called")
        print("Enter View Controller'a unwind ile dönüldü!")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("EnterViewController: prepare for segue called - Identifier: \(segue.identifier ?? "nil")")
        animationManager.stopMaskAnimationTimer()
        
        let customSegueIdentifiers = ["menuToGameSettings", "EnterToDefaultSettings", "EnterToHowToPlay"]
        if customSegueIdentifiers.contains(segue.identifier ?? "") {
            if segue is StoryboardFadeToBlueSegue {
                let destinationVC = segue.destination
                destinationVC.modalPresentationStyle = .custom
                destinationVC.transitioningDelegate = self
            } else {
                let destinationVC = segue.destination
                destinationVC.modalPresentationStyle = .custom
                destinationVC.transitioningDelegate = self
            }
        }
    }
    
    // MARK: - UIViewControllerTransitioningDelegate
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        print("EnterViewController: animationController forPresented called (returning nil as StoryboardFadeToBlueSegue handles it)")
        return nil
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        print("EnterViewController: Providing StoryboardFadeToBlueUnwind for dismissal.")
        return StoryboardFadeToBlueUnwind()
    }
    
    // MARK: - Helper Methods
    private func purgeCustomSessionsIfNeeded() {
        let customSessions = GameStateManager.shared.getCustomSessions()
        if !customSessions.isEmpty {
            print("EnterViewController: Found \(customSessions.count) custom session(s). Deleting…")
            GameStateManager.shared.deleteAllCustomSessions()
        }
    }
}

// MARK: - SwiftUI Preview
struct ViewController_Previews1: PreviewProvider {
    static var previews: some View {
        ViewControllerPreview {
            EnterViewController()
        }
    }
}

// MARK: - String Extension
extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func localizedPlural(count: Int) -> String {
        let languageCode = Locale.current.languageCode ?? "en"

        let pluralLanguages: Set<String> = ["en"]

        if pluralLanguages.contains(languageCode) {
            let format = NSLocalizedString(self, comment: "")
            return String.localizedStringWithFormat(format, count)
        } else { // tr
            return String(format: NSLocalizedString(self, comment: ""), count)
        }
    }
    
    func staticPlural(count: Int) -> String {
        let singularKey = self + "_singular"
        let pluralKey = self + "_plural"
        
        let singularTranslation = NSLocalizedString(singularKey, comment: "")
        if singularTranslation != singularKey {
            if count == 1 {
                return singularTranslation
            } else {
                let pluralTranslation = NSLocalizedString(pluralKey, comment: "")
                if pluralTranslation != pluralKey {
                    return pluralTranslation
                } else { // fallback
                    return NSLocalizedString(self, comment: "")
                }
            }
        } else {
            return NSLocalizedString(self, comment: "")
        }
    }
}
