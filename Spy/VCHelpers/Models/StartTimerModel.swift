//
//  StartTimerModel.swift
//  Spy
//
//  Created by Zeynep Müslim on 2.04.2025.
//

import UIKit

// MARK: - Start Timer Constants
enum StartTimerConstants {
    static let animationDuration: TimeInterval = 5.0
    static let maxLabelAttempts = 10
    static let minDistanceBetweenLabels: CGFloat = 100
    static let labelWidthMultiplier: CGFloat = 0.3
    static let forbiddenAreaInset: CGFloat = 30
    static let viewBoundsInset: CGFloat = 20
    
    enum FontSizes {
        static let titleSize: CGFloat = 18
        static let subtitleSize: CGFloat = 14
        static let hintMinSize: CGFloat = 12
        static let hintMaxSize: CGFloat = 16
    }
    
    enum Transforms {
        static let initialScale = CGAffineTransform(scaleX: 0.1, y: 0.1)
        static let finalScale = CGAffineTransform(scaleX: 2.0, y: 2.0)
    }
    
    enum TimerIdentifiers {
        static let spawn = "spawn_timer"
    }
}

// MARK: - Start Timer UI Manager
class StartTimerUIManager {
    
    // MARK: - Label Configuration
    static func configureTitleLabel() -> UILabel {
        let label = UILabel()
        label.text = "find_the_spy_before_time_runs_out".localized
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: StartTimerConstants.FontSizes.titleSize)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    static func configureSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.text = "tap_to_start_when_ready".localized
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: StartTimerConstants.FontSizes.subtitleSize)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    static func configureBottomView() -> CustomDarkScrollView {
        let bottomView = CustomDarkScrollView()
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        return bottomView
    }
}

// MARK: - Hint Label Spawning Manager
class HintLabelSpawningManager {
    
    private var hints: [String] = []
    private var activeLabelCenters: [CGPoint] = []
    weak var parentView: UIView?
    weak var bottomView: UIView?
    
    init(parentView: UIView, bottomView: UIView) {
        self.parentView = parentView
        self.bottomView = bottomView
        loadHints()
    }
    
    // MARK: - Hint Loading
    private func loadHints() {
        if let category = GameStateManager.shared.getCurrentGameSession()?.category {
            hints = HintManager.shared.getHints(forCategory: category)
            print("Hint category: \(category), loaded \(hints.count) hints")
        } else {
            hints = HintManager.shared.getAllHints()
            print("No category found, using all hints. Loaded \(hints.count) hints")
        }
    }
    
    // MARK: - Label Spawning
    func spawnHintLabel() {
        guard let parentView = parentView, 
              let bottomView = bottomView,
              !hints.isEmpty else { return }
        
        let hintText = hints.randomElement() ?? "Hello"
        let label = createHintLabel(with: hintText)
        
        guard let position = findSafePosition(for: label, in: parentView, avoiding: bottomView) else { return }
        
        positionAndAnimateLabel(label, at: position, in: parentView)
    }
    
    // MARK: - Label Creation
    private func createHintLabel(with text: String) -> UILabel {
        let label = UILabel()
        label.text = text.localized
        label.textColor = .white
        label.textAlignment = .center
        
        let fontSize = CGFloat.random(in: StartTimerConstants.FontSizes.hintMinSize...StartTimerConstants.FontSizes.hintMaxSize)
        label.font = UIFont.systemFont(ofSize: fontSize, weight: .thin)
        
        label.numberOfLines = 0
        let maxWidth = (parentView?.bounds.width ?? 0) * StartTimerConstants.labelWidthMultiplier
        label.preferredMaxLayoutWidth = maxWidth
        label.lineBreakMode = .byWordWrapping
        label.frame.size = label.sizeThatFits(CGSize(width: maxWidth, height: .greatestFiniteMagnitude))
        
        return label
    }
    
    // MARK: - Position Calculation
    private func findSafePosition(for label: UILabel, in parentView: UIView, avoiding bottomView: UIView) -> CGPoint? {
        let fullBounds = parentView.bounds.insetBy(dx: StartTimerConstants.viewBoundsInset, dy: StartTimerConstants.viewBoundsInset)
        let forbiddenRect = bottomView.frame.insetBy(dx: StartTimerConstants.forbiddenAreaInset, dy: StartTimerConstants.forbiddenAreaInset)
        
        for _ in 0..<StartTimerConstants.maxLabelAttempts {
            let x = CGFloat.random(in: fullBounds.minX...(fullBounds.maxX - label.bounds.width))
            let y = CGFloat.random(in: fullBounds.minY...(fullBounds.maxY - label.bounds.height))
            let center = CGPoint(x: x + label.bounds.width / 2, y: y + label.bounds.height / 2)
            let labelOrigin = CGPoint(x: x, y: y)
            
            if isPositionValid(labelOrigin: labelOrigin, labelSize: label.frame.size, center: center, forbiddenRect: forbiddenRect) {
                activeLabelCenters.append(center)
                return labelOrigin
            }
        }
        return nil
    }
    
    private func isPositionValid(labelOrigin: CGPoint, labelSize: CGSize, center: CGPoint, forbiddenRect: CGRect) -> Bool {
        let labelFrame = CGRect(origin: labelOrigin, size: labelSize)
        let isOutsideForbidden = !labelFrame.intersects(forbiddenRect)
        let isFarEnough = activeLabelCenters.allSatisfy { existing in
            hypot(center.x - existing.x, center.y - existing.y) > StartTimerConstants.minDistanceBetweenLabels
        }
        return isOutsideForbidden && isFarEnough
    }
    
    // MARK: - Animation
    private func positionAndAnimateLabel(_ label: UILabel, at position: CGPoint, in parentView: UIView) {
        label.frame.origin = position
        label.alpha = 0.0
        label.transform = StartTimerConstants.Transforms.initialScale
        parentView.addSubview(label)
        
        // Scale animation
        UIView.animate(
            withDuration: StartTimerConstants.animationDuration,
            delay: 0,
            options: [.curveEaseInOut],
            animations: {
                label.transform = StartTimerConstants.Transforms.finalScale
            }
        )
        
        // Fade animation with cleanup
        UIView.animateKeyframes(
            withDuration: StartTimerConstants.animationDuration,
            delay: 0,
            options: [],
            animations: {
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5) {
                    label.alpha = 1.0
                }
                UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                    label.alpha = 0.0
                }
            },
            completion: { _ in
                label.removeFromSuperview()
                self.removeLabelFromActiveList(at: position, labelSize: label.bounds.size)
            }
        )
    }
    
    private func removeLabelFromActiveList(at position: CGPoint, labelSize: CGSize) {
        let centerToRemove = CGPoint(
            x: position.x + labelSize.width / 2,
            y: position.y + labelSize.height / 2
        )
        activeLabelCenters.removeAll { $0 == centerToRemove }
    }
    
    // MARK: - Cleanup
    func cleanup() {
        activeLabelCenters.removeAll()
    }
} 