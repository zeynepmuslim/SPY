//
//  EnterModel.swift
//  Spy
//
//  Created by Zeynep Müslim on 8.04.2025.
//

import UIKit

// MARK: - Enter View Constants
enum EnterViewConstants {
    static let animationInterval: TimeInterval = 1.0
    static let animationDuration: TimeInterval = 1.0
    static let maskSizeMultiplier: CGFloat = 0.3
    static let stackHeightMultiplier: CGFloat = 0.4
    static let easterEggImageSize: CGFloat = 70
    static let gradientBallSizeMultiplier: CGFloat = 3.0
    
    enum TimerIdentifiers {
        static let maskAnimation = "mask_animation_timer"
    }
}

// MARK: - Enter View UI Manager
class EnterViewUIManager {
    
    // MARK: - Button Creation
    static func createMainButtons() -> (start: CustomGradientButton, settings: CustomGradientButton, howToPlay: CustomGradientButton) {
        let startGameButton = CustomGradientButton(
            labelText: "new_game".localized,
            gradientColor: .red,
            width: 150,
            height: GeneralConstants.Button.biggerHeight,
            shadowColor: .red,
            buttonColor: .red
        )
        
        let settingsButton = CustomGradientButton(
            labelText: "settings".localized,
            height: GeneralConstants.Button.biggerHeight
        )
        
        let howToPlayButton = CustomGradientButton(
            labelText: "how_to_play".localized,
            height: GeneralConstants.Button.biggerHeight
        )
        
        return (startGameButton, settingsButton, howToPlayButton)
    }
    
    // MARK: - UI Element Configuration
    static func configureImageViews() -> (magnifyingGlass: UIImageView, magnifyingGlassEmpty: UIImageView, background: UIImageView, backgroundNormal: UIImageView) {
        let magnifyingGlassImageView = UIImageView(image: UIImage(named: "magnifyingGlass"))
        magnifyingGlassImageView.contentMode = .scaleAspectFit
        
        let magnifyingGlassEmptyImageView = UIImageView(image: UIImage(named: "magnifyingGlassEmptyGlass"))
        magnifyingGlassEmptyImageView.contentMode = .scaleAspectFit
        
        let backgroundImageView = UIImageView()
        backgroundImageView.image = UIImage(named: "maskImage")
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let backgroundImageViewNormal = UIImageView(image: UIImage(named: "normalImage"))
        backgroundImageViewNormal.contentMode = .scaleAspectFill
        backgroundImageViewNormal.translatesAutoresizingMaskIntoConstraints = false
        
        return (magnifyingGlassImageView, magnifyingGlassEmptyImageView, backgroundImageView, backgroundImageViewNormal)
    }
    
    static func configureTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.text = "SPY"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 70)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }
    
    static func configureStackViews() -> (upper: UIView, lower: UIStackView, magnifyingGlass: UIView) {
        let upperStack = UIView()
        upperStack.translatesAutoresizingMaskIntoConstraints = false
        
        let lowerStack = UIStackView()
        lowerStack.axis = .vertical
        lowerStack.spacing = 20
        lowerStack.translatesAutoresizingMaskIntoConstraints = false
        
        let magnifyingGlassStack = UIView()
        magnifyingGlassStack.translatesAutoresizingMaskIntoConstraints = false
        
        return (upperStack, lowerStack, magnifyingGlassStack)
    }
    
    // MARK: - Gradient Ball Configuration
    static func configureGradientBall(
        gradientBallView: UIView,
        winkAnimationView: UIView,
        magnifyingGlassStack: UIView,
        viewWidth: CGFloat
    ) {
        gradientBallView.translatesAutoresizingMaskIntoConstraints = false
        magnifyingGlassStack.insertSubview(gradientBallView, at: 1)
        
        let ballSize = viewWidth * EnterViewConstants.gradientBallSizeMultiplier
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.type = .radial
        gradientLayer.colors = [
            UIColor.spyRed02.cgColor,
            UIColor.spyRed02.withAlphaComponent(0.6).cgColor,
            UIColor.spyRed02.withAlphaComponent(0.3).cgColor,
            UIColor.clear.cgColor
        ]
        gradientLayer.locations = [0.0, 0.3, 0.7, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        
        gradientBallView.layer.addSublayer(gradientLayer)
        
        NSLayoutConstraint.activate([
            gradientBallView.centerXAnchor.constraint(equalTo: winkAnimationView.centerXAnchor),
            gradientBallView.centerYAnchor.constraint(equalTo: winkAnimationView.centerYAnchor),
            gradientBallView.widthAnchor.constraint(equalToConstant: ballSize),
            gradientBallView.heightAnchor.constraint(equalToConstant: ballSize)
        ])
        
        gradientBallView.layer.cornerRadius = ballSize / 2
        gradientBallView.clipsToBounds = true
        
        gradientLayer.frame = CGRect(x: 0, y: 0, width: ballSize, height: ballSize)
    }
}

// MARK: - Enter View Animation Manager
class EnterViewAnimationManager {
    
    private let timerManager = TimerManager.shared
    weak var viewController: EnterViewController?
    
    init(viewController: EnterViewController) {
        self.viewController = viewController
    }
    
    // MARK: - Timer Management
    func startMaskAnimationTimer(magnifyingGlassStack: UIView, initialLayoutDone: Bool) {
        guard initialLayoutDone else {
            print("EnterViewController: Cannot start timer - initial layout not done")
            return
        }
        guard !timerManager.isTimerActive(identifier: EnterViewConstants.TimerIdentifiers.maskAnimation) else {
            print("EnterViewController: Timer already active, skipping start")
            return
        }
        print("EnterViewController: Starting animation timer")
        timerManager.createTimer(
            identifier: EnterViewConstants.TimerIdentifiers.maskAnimation,
            timeInterval: EnterViewConstants.animationInterval,
            target: self,
            selector: #selector(animateMaskRandomly)
        )
    }
    
    func stopMaskAnimationTimer() {
        print("EnterViewController: Stopping animation timer")
        timerManager.stopTimer(identifier: EnterViewConstants.TimerIdentifiers.maskAnimation)
    }
    
    // MARK: - Animation Methods
    @objc func animateMaskRandomly() {
        guard let viewController = viewController,
              let maskView = viewController.magnifyingGlassStack.mask else {
            print("Mask view not found")
            return
        }
        
        let stackBounds = viewController.magnifyingGlassStack.bounds
        let maskSize = maskView.frame.size
        
        guard stackBounds != .zero, maskSize != .zero else {
            print("Cannot animate mask: Zero bounds or size")
            return
        }
        
        let maxX = stackBounds.width - maskSize.width
        let maxY = stackBounds.height - maskSize.height
        let minX: CGFloat = maskSize.width/5
        let minY: CGFloat = maskSize.height/5
        
        guard maxX >= 0, maxY >= 0 else {
            print("Cannot animate mask: Stack smaller than mask")
            return
        }
        
        let randomX = CGFloat.random(in: minX...maxX)
        let randomY = CGFloat.random(in: minY...maxY)
        let newOrigin = CGPoint(x: randomX, y: randomY)
        
        UIView.animate(withDuration: EnterViewConstants.animationDuration, delay: 0, options: [.curveEaseInOut], animations: {
            maskView.frame.origin = newOrigin
            viewController.magnifyingGlassEmptyImageView.frame.origin = newOrigin
        }, completion: { completed in
            if !completed {
                print("Mask/Deneme animation interrupted")
            }
        })
    }
}

// MARK: - Enter View Gesture Manager
class EnterViewGestureManager {
    
    weak var viewController: EnterViewController?
    weak var animationManager: EnterViewAnimationManager?
    
    init(viewController: EnterViewController, animationManager: EnterViewAnimationManager) {
        self.viewController = viewController
        self.animationManager = animationManager
    }
    
    func setupPanGesture(for magnifyingGlassStack: UIView) {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        magnifyingGlassStack.addGestureRecognizer(panGesture)
        magnifyingGlassStack.isUserInteractionEnabled = true
    }
    
    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let viewController = viewController,
              let maskView = viewController.magnifyingGlassStack.mask,
              let containerView = gestureRecognizer.view else { return }
        
        let location = gestureRecognizer.location(in: containerView)
        let minX: CGFloat = -maskView.frame.width
        let minY: CGFloat = -maskView.frame.height
        let maxX = containerView.bounds.width
        let maxY = containerView.bounds.height
        
        switch gestureRecognizer.state {
        case .began:
            animationManager?.stopMaskAnimationTimer()
            print("Pan gesture began - initial location: \(location)")
            var newOrigin = CGPoint(x: location.x - maskView.frame.width / 6, y: location.y - maskView.frame.height / 1.1)
            
            newOrigin.x = max(minX, min(newOrigin.x, maxX))
            newOrigin.y = max(minY, min(newOrigin.y, maxY))
            
            UIView.animate(withDuration: 0.2, animations: {
                maskView.frame.origin = newOrigin
                viewController.magnifyingGlassEmptyImageView.frame.origin = newOrigin
            })
            
        case .changed:
            var newOrigin = CGPoint(x: location.x - maskView.frame.width / 6, y: location.y - maskView.frame.height / 1.1)
            
            newOrigin.x = max(minX, min(newOrigin.x, maxX))
            newOrigin.y = max(minY, min(newOrigin.y, viewController.view.frame.height))
            
            maskView.frame.origin = newOrigin
            viewController.magnifyingGlassEmptyImageView.frame.origin = newOrigin
            
            print("Pan gesture changed - new origin: \(newOrigin)")
            
        case .ended, .cancelled:
            animationManager?.startMaskAnimationTimer(magnifyingGlassStack: viewController.magnifyingGlassStack, initialLayoutDone: viewController.initialLayoutDone)
            animationManager?.animateMaskRandomly()
            print("Pan gesture ended/cancelled, animation restarted immediately")
            
        default:
            break
        }
    }
}

// MARK: - Enter View Layout Manager
class EnterViewLayoutManager {
    
    static func performInitialLayout(
        magnifyingGlassStack: UIView,
        magnifyingGlassEmptyImageView: UIImageView
    ) -> Bool {
        guard let maskView = magnifyingGlassStack.mask, magnifyingGlassStack.bounds != .zero else {
            return false
        }
        
        let stackBounds = magnifyingGlassStack.bounds
        let maskWidth = stackBounds.width * EnterViewConstants.maskSizeMultiplier
        let maskHeight = maskWidth
        let maskX = stackBounds.width
        let maskY = stackBounds.height
        let initialFrame = CGRect(x: maskX, y: maskY, width: maskWidth, height: maskHeight)
        
        maskView.frame = initialFrame
        magnifyingGlassEmptyImageView.frame = initialFrame
        
        return true
    }
} 
