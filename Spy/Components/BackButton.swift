//
//  BackButton.swift
//  Spy
//
//  Created by Zeynep Müslim on 6.03.2025.
//

import UIKit

class BackButton: UIButton {
    
    private weak var targetViewController: UIViewController?
    private var backAction: Selector?
    private var swipeGesture: UIScreenEdgePanGestureRecognizer?
    
    init(target: Any?, action: Selector) {
        super.init(frame: .zero)
        
        let backImage = UIImage(systemName: "chevron.left")
        self.setImage(backImage, for: .normal)
        self.tintColor = .spyBlue01
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.addTarget(target, action: action, for: .touchUpInside)
        
        if let viewController = target as? UIViewController {
            self.targetViewController = viewController
            self.backAction = action
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if superview != nil && swipeGesture == nil {
            setupSwipeGesture()
        }
    }
    
    func setupSwipeGesture() {
        guard let viewController = targetViewController, swipeGesture == nil else { return }
        
        let swipeGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
        swipeGesture.edges = .left
        swipeGesture.delegate = self
        viewController.view.addGestureRecognizer(swipeGesture)
        
        self.swipeGesture = swipeGesture
    }
    
    @objc private func handleSwipeGesture(_ gesture: UIScreenEdgePanGestureRecognizer) {
        switch gesture.state {
        case .ended, .cancelled:
            if let target = targetViewController, let action = backAction {
                target.perform(action)
            }
        default:
            break
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension BackButton: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Allow simultaneous recognition with other gesture recognizers
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Don't require other gesture recognizers to fail
        return false
    }
}
