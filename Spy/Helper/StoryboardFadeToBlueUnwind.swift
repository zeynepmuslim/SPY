import UIKit

class StoryboardFadeToBlueUnwind: NSObject, UIViewControllerAnimatedTransitioning {

    let fadeInDuration: TimeInterval = 0.2
    let fadeOutDuration: TimeInterval = 0.2

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return fadeInDuration + fadeOutDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        print("StoryboardFadeToBlueUnwind: animateTransition called")

        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to),
              let fromView = transitionContext.view(forKey: .from),
              let toView = transitionContext.view(forKey: .to) ?? toVC.view // Ensure toView is retrieved
        else {
            print("StoryboardFadeToBlueUnwind: Could not get VCs or Views.")
            transitionContext.completeTransition(false)
            return
        }

        let containerView = transitionContext.containerView
        // Set container background to clear to prevent black flashes
        containerView.backgroundColor = .clear 
        let finalFrame = transitionContext.finalFrame(for: toVC)

        // Add toView below fromView, initially hidden
        toView.frame = finalFrame
        toView.alpha = 0.0 // Start hidden
        if toView.superview == nil {
            containerView.insertSubview(toView, belowSubview: fromView)
        }

        // Create and add the overlay
        let overlay = GradientView(superView: containerView)
        overlay.frame = containerView.bounds
        overlay.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        overlay.layer.zPosition = CGFloat(Float.greatestFiniteMagnitude)
        overlay.alpha = 0.0
        containerView.addSubview(overlay)

        // Notify 'toVC' it's beginning to appear
        toVC.beginAppearanceTransition(true, animated: true)

        // Fade in the overlay to a slightly lower alpha
        let targetOverlayAlpha: CGFloat = 1.0
        UIView.animate(withDuration: fadeInDuration, delay: 0, options: [.curveEaseOut], animations: {
            overlay.alpha = targetOverlayAlpha // Fade to reduced alpha
        }) { _ in
            // First animation completed
            if !transitionContext.transitionWasCancelled {
                // Overlay is now visible. Remove fromView instantly.
                fromView.removeFromSuperview()

                // First, fade in the destination view while KEEPING the overlay fully opaque.
                UIView.animate(withDuration: self.fadeOutDuration, delay: 0, options: [.curveEaseIn], animations: {
                    toView.alpha = 1.0
                }) { finished in
                    // Once the destination view is fully visible, fade the overlay away.
                    UIView.animate(withDuration: self.fadeOutDuration, delay: 0, options: [.curveEaseInOut], animations: {
                        overlay.alpha = 0.0
                    }) { overlayFinished in
                        // All animations finished – clean-up overlay.
                        overlay.removeFromSuperview()

                        let completedSuccessfully = finished && overlayFinished && !transitionContext.transitionWasCancelled

                        if completedSuccessfully {
                            toView.alpha = 1.0 // Ensure correct final state
                        }

                        // Notify 'toVC' it has finished appearing
                        toVC.endAppearanceTransition()

                        // Complete the transition
                        transitionContext.completeTransition(completedSuccessfully)
                    }
                }
            } else {
                 // Transition was cancelled
                 overlay.removeFromSuperview()
                 // Ensure toView remains hidden if cancelled
                 toView.alpha = 0.0 
                 toVC.endAppearanceTransition()
                 transitionContext.completeTransition(false)
            }
        }
    }
} 
