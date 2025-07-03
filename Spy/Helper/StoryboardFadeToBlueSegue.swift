import UIKit
import Foundation

class StoryboardFadeToBlueSegue: UIStoryboardSegue {

  override func perform() {
      // Updated window finding logic for iOS 13+
      guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
          // Fallback or error handling if window cannot be found
          print("FadeToBlueSegue: Could not find key window.")
          super.perform()
          return
      }
      let overlay = GradientView(superView: window)
      overlay.layer.zPosition = CGFloat(Float.greatestFiniteMagnitude) // Ensure overlay is on top initially
      overlay.alpha = 0.0
      window.addSubview(overlay)

      // Notify source VC it's beginning to disappear
      source.beginAppearanceTransition(false, animated: true)

      UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut], animations: {
          overlay.alpha = 1.0
      }, completion: { _ in
          // Present destination non-animatedly WITHIN the completion
          self.source.present(self.destination, animated: false, completion: {
              // Notify source VC it has finished disappearing AFTER presentation is complete
              self.source.endAppearanceTransition()

              // Now fade out the overlay
              UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseIn], animations: {
                  overlay.alpha = 0.0
              }, completion: { _ in
                  overlay.removeFromSuperview()
              })
          })
      })
  }
} 
