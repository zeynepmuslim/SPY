import UIKit

class PlayerSettingsGroupManager {
    enum Constants {
        static let iconSpacing: CGFloat = 10
        static let animationDuration: TimeInterval = 0.4
        static let fadeInDuration: TimeInterval = 0.15
        static let titleSize: CGFloat = 18
        static let maxIconSize: CGFloat = 45
        static let iconThreshold: Int = 6
        static let waveDelay: TimeInterval = 0.05
        
        static let scaleUpValue: CGFloat = 1.15
        static let scaleDownValue: CGFloat = 0.01
        static let springDamping: CGFloat = 0.55
        static let springVelocity: CGFloat = 0.3
        static let bounceBackDamping: CGFloat = 0.7
        static let bounceBackVelocity: CGFloat = 0.2
        static let spacerWidth: CGFloat = 5
        
        static let addAnimationFirstPhase: TimeInterval = 0.6
        static let addAnimationSecondPhase: TimeInterval = 0.4
        static let removeAnimationPhase: TimeInterval = 0.5
    }
    
    class PlayerGroup {
        // MARK: - UI Components
        let stackView: UIStackView
        let horizontalStackView: UIStackView
        var imageViews: [UIImageView]
        let label: VerticalAlignedLabel
        let minusButton: CustomGradientButton
        let plusButton: CustomGradientButton
        let spacerView: UIView
        let imagesStackView: UIStackView
        
        let minSpyCount: Int
        let maxSpyCount: Int
        let buttonBorderColor: GradientColor
        let index: Int
        
        private var isAnimating: Bool = false
        private var spacerWidthConstraint: NSLayoutConstraint?
        
        // MARK: - Initialization
        init(title: String,
             index: Int,
             buttonBorderColor: GradientColor = .blue,
             buttonShadow: ShadowColor = .blue,
             buttonColor: ButtonColor = .blue,
             minSpyCount: Int = 1,
             maxSpyCount: Int = 8,
             initialValue: Int? = nil) {
            
            self.minSpyCount = max(1, minSpyCount)
            self.maxSpyCount = max(self.minSpyCount, maxSpyCount)
            self.index = index
            self.buttonBorderColor = buttonBorderColor
            
            stackView = UIStackView()
            horizontalStackView = UIStackView()
            imagesStackView = UIStackView()
            spacerView = UIView()
            imageViews = []
            label = VerticalAlignedLabel()
            
            minusButton = CustomGradientButton(
                labelText: "-",
                gradientColor: buttonBorderColor,
                width: GeneralConstants.Button.miniHeight,
                height: GeneralConstants.Button.miniHeight,
                shadowColor: buttonShadow,
                buttonColor: buttonColor
            )
            
            plusButton = CustomGradientButton(
                labelText: "+",
                gradientColor: buttonBorderColor,
                width: GeneralConstants.Button.miniHeight,
                height: GeneralConstants.Button.miniHeight,
                shadowColor: buttonShadow,
                buttonColor: buttonColor
            )
            
            setupUI(title: title)
            setupConstraints()
            setupButtonActions()
            
            createSpyImages(initialValue: initialValue)
            updateButtonStates()
            updateSpacerState(animated: false)
        }
        
        // MARK: - UI Setup
        private func setupUI(title: String) {
            setupStackViews()
            setupLabel(title: title)
            setupButtons()
            setupSpacerView()
            assembleHierarchy()
        }
        
        private func setupStackViews() {
            stackView.axis = .vertical
            stackView.spacing = Constants.iconSpacing
            stackView.alignment = .fill
            stackView.distribution = .fill
            stackView.translatesAutoresizingMaskIntoConstraints = false
            
            horizontalStackView.axis = .horizontal
            horizontalStackView.spacing = Constants.iconSpacing
            horizontalStackView.alignment = .center
            horizontalStackView.distribution = .fill
            horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
            
            imagesStackView.axis = .horizontal
            imagesStackView.spacing = Constants.iconSpacing
            imagesStackView.alignment = .center
            imagesStackView.distribution = .fillEqually
            imagesStackView.translatesAutoresizingMaskIntoConstraints = false
        }
        
        private func setupLabel(title: String) {
            label.text = title
            label.textColor = .white
            label.numberOfLines = 0
            label.font = UIFont.boldSystemFont(ofSize: Constants.titleSize)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            label.verticalAlignment = .custom(5)
        }
        
        private func setupButtons() {
            minusButton.translatesAutoresizingMaskIntoConstraints = false
            plusButton.translatesAutoresizingMaskIntoConstraints = false
        }
        
        private func setupSpacerView() {
            spacerView.translatesAutoresizingMaskIntoConstraints = false
            spacerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
            spacerView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        }
        
        private func assembleHierarchy() {
            stackView.addArrangedSubview(label)
            stackView.addArrangedSubview(horizontalStackView)
            
            horizontalStackView.addArrangedSubview(imagesStackView)
            horizontalStackView.addArrangedSubview(spacerView)
            horizontalStackView.addArrangedSubview(minusButton)
            horizontalStackView.addArrangedSubview(plusButton)
        }
        
        private func setupConstraints() {
            imagesStackView.widthAnchor.constraint(equalTo: label.widthAnchor).isActive = true
            horizontalStackView.widthAnchor.constraint(equalTo: label.widthAnchor).isActive = true
            
            spacerWidthConstraint = spacerView.widthAnchor.constraint(equalToConstant: Constants.spacerWidth)
            spacerWidthConstraint?.priority = .defaultHigh
        }
        
        private func setupButtonActions() {
            minusButton.onClick = { [weak self] in
                self?.removeSpyImage()
            }
            
            plusButton.onClick = { [weak self] in
                self?.addSpyImage()
            }
        }
        
        // MARK: - Image Management
        private func createSpyImages(initialValue: Int? = nil) {
            let count = initialValue.map { max(minSpyCount, min($0, maxSpyCount)) } ?? minSpyCount
            for _ in 0..<count {
                addSpyImage(animated: false)
            }
        }
        
        private func createSpyImageView() -> UIImageView {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.setContentHuggingPriority(.defaultLow, for: .horizontal)
            imageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            
            imageView.heightAnchor.constraint(lessThanOrEqualToConstant: Constants.maxIconSize).isActive = true
            imageView.widthAnchor.constraint(lessThanOrEqualToConstant: Constants.maxIconSize).isActive = true
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
            
            return imageView
        }
        
        private func updateImageIcon(_ imageView: UIImageView, shouldUseCircle: Bool) {
            if shouldUseCircle {
                imageView.image = UIImage(systemName: "circle.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
            } else {
                let imageName = index == 0 ? "civil-right-w" : "spy-right-w"
                imageView.image = UIImage(named: imageName)
            }
        }
        
        private var shouldUseCircleIcons: Bool {
            return imageViews.count > Constants.iconThreshold
        }
        
        private func updateAllImages(completion: (() -> Void)? = nil) {
            let shouldUseCircle = shouldUseCircleIcons
            let totalDuration = Double(imageViews.count) * Constants.waveDelay + Constants.animationDuration
            
            for (index, imageView) in imageViews.enumerated() {
                let delay = Double(index) * Constants.waveDelay
                
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    UIView.transition(with: imageView,
                                      duration: Constants.animationDuration,
                                      options: .transitionCrossDissolve,
                                      animations: {
                        self.updateImageIcon(imageView, shouldUseCircle: shouldUseCircle)
                    })
                }
            }
            
            completion.map { completion in
                DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration, execute: completion)
            }
        }
        
        // MARK: - Animation Helpers
        private func performAddAnimation(for imageView: UIImageView, completion: @escaping () -> Void) {
            imageView.alpha = 0
            imageView.transform = CGAffineTransform(scaleX: Constants.scaleDownValue, y: Constants.scaleDownValue)
            
            UIView.animate(
                withDuration: Constants.animationDuration * Constants.addAnimationFirstPhase,
                delay: 0,
                usingSpringWithDamping: Constants.springDamping,
                initialSpringVelocity: Constants.springVelocity,
                options: .curveEaseOut,
                animations: {
                    imageView.alpha = 1
                    imageView.transform = CGAffineTransform(scaleX: Constants.scaleUpValue, y: Constants.scaleUpValue)
                }
            ) { _ in
                UIView.animate(
                    withDuration: Constants.animationDuration * Constants.addAnimationSecondPhase,
                    delay: 0,
                    usingSpringWithDamping: Constants.bounceBackDamping,
                    initialSpringVelocity: Constants.bounceBackVelocity,
                    options: .curveEaseOut,
                    animations: {
                        imageView.transform = .identity
                    },
                    completion: { _ in completion() }
                )
            }
        }
        
        private func performRemoveAnimation(for imageView: UIImageView, completion: @escaping () -> Void) {
            UIView.animate(
                withDuration: Constants.animationDuration * Constants.removeAnimationPhase,
                delay: 0,
                usingSpringWithDamping: Constants.springDamping,
                initialSpringVelocity: Constants.springVelocity,
                options: .curveEaseOut,
                animations: {
                    imageView.transform = CGAffineTransform(scaleX: Constants.scaleUpValue, y: Constants.scaleUpValue)
                }
            ) { _ in
                UIView.animate(
                    withDuration: Constants.animationDuration * Constants.removeAnimationPhase,
                    delay: 0,
                    options: [.curveEaseIn],
                    animations: {
                        imageView.alpha = 0
                        imageView.transform = CGAffineTransform(scaleX: Constants.scaleDownValue, y: Constants.scaleDownValue)
                    },
                    completion: { _ in completion() }
                )
            }
        }
        
        private func handlePostImageChange(willCrossThreshold: Bool, wasAlreadyPastThreshold: Bool = false) {
            if willCrossThreshold && !wasAlreadyPastThreshold {
                updateAllImages()
            }
            isAnimating = false
            updateButtonStates()
            updateSpacerState(animated: true)
        }
        
        // MARK: - Image Operations
        private func addSpyImage(animated: Bool = true) {
            guard imageViews.count < maxSpyCount else { return }
            
            let willCrossThreshold = imageViews.count + 1 > Constants.iconThreshold
            let isAlreadyPastThreshold = shouldUseCircleIcons
            
            let imageView = createSpyImageView()
            updateImageIcon(imageView, shouldUseCircle: isAlreadyPastThreshold)
            imagesStackView.addArrangedSubview(imageView)
            imageViews.append(imageView)
            
            if animated {
                performAddAnimation(for: imageView) { [weak self] in
                    self?.handlePostImageChange(willCrossThreshold: willCrossThreshold, wasAlreadyPastThreshold: isAlreadyPastThreshold)
                }
            } else {
                handlePostImageChange(willCrossThreshold: willCrossThreshold, wasAlreadyPastThreshold: isAlreadyPastThreshold)
            }
        }
        
        private func removeSpyImage(animated: Bool = true) {
            guard imageViews.count > minSpyCount,
                  let lastImageView = imageViews.last,
                  !isAnimating else { return }
            
            let willCrossThreshold = imageViews.count == Constants.iconThreshold + 1
            
            if animated {
                isAnimating = true
                updateButtonStates()
                
                performRemoveAnimation(for: lastImageView) { [weak self] in
                    lastImageView.removeFromSuperview()
                    self?.imageViews.removeLast()
                    self?.handlePostImageChange(willCrossThreshold: willCrossThreshold)
                }
            } else {
                lastImageView.removeFromSuperview()
                imageViews.removeLast()
                handlePostImageChange(willCrossThreshold: willCrossThreshold)
            }
        }
        
        // MARK: - Button State Management
        private func updateButtonStates() {
            let currentCount = imageViews.count
            let minusEnabled = currentCount > minSpyCount && !isAnimating
            let plusEnabled = currentCount < maxSpyCount && !isAnimating
            
            updateButtonVisuals(minusButton, isEnabled: currentCount > minSpyCount)
            updateButtonVisuals(plusButton, isEnabled: currentCount < maxSpyCount)
            
            minusButton.isUserInteractionEnabled = minusEnabled
            plusButton.isUserInteractionEnabled = plusEnabled
        }
        
        private func updateButtonVisuals(_ button: CustomGradientButton, isEnabled: Bool) {
            button.setStatus(isEnabled
                             ? (buttonBorderColor == .red ? .activeRed : .activeBlue)
                             : .deactive)
        }
        
        // MARK: - Spacer Management
        private func updateSpacerState(animated: Bool) {
            let shouldHaveSmallWidth = imageViews.count > Constants.iconThreshold - 1
            let isCurrentlySmall = spacerWidthConstraint?.isActive ?? false
            
            guard isCurrentlySmall != shouldHaveSmallWidth else { return }
            
            let updateLayout = { [weak self] in
                self?.spacerWidthConstraint?.isActive = shouldHaveSmallWidth
                self?.horizontalStackView.layoutIfNeeded()
            }
            
            if animated {
                UIView.animate(withDuration: Constants.animationDuration * Constants.removeAnimationPhase,
                               delay: 0,
                               options: .curveEaseInOut,
                               animations: updateLayout)
            } else {
                updateLayout()
            }
        }
    }
}
