import UIKit
import SwiftUI

// MARK: - Protocol
protocol CustomCardViewDelegate: AnyObject {
    func cardViewWasDismissed(_ cardView: CustomCardView)
}

// MARK: - CustomCardView
class CustomCardView: UIView {
    
    // MARK: - Constants
    private struct AnimationConstants {
        static let flipDuration: CGFloat = 0.3
        static let springDamping: CGFloat = 0.5
        static let springVelocity: CGFloat = 0.5
        static let dismissDuration: CGFloat = 0.3
        static let bounceValues: [CGFloat] = [1.0, 0.99, 1.02, 0.99, 1.0]
        static let bounceKeyTimes: [NSNumber] = [0, 0.2, 0.4, 0.6, 0.8]
        static let bounceDuration: CGFloat = 0.8
        static let resistance: CGFloat = 0.8
        static let velocityFactor: CGFloat = 1000.0
        static let transform3DPerspective: CGFloat = -1.0 / 500.0
        static let spyWinkAnimationInterval: CGFloat = 2.0
    }
    
    private struct InteractionConstants {
        static let maxRotation: CGFloat = .pi / 10
        static let throwVelocityThreshold: CGFloat = 1000
        static let dismissalThreshold: CGFloat = 0.4
        static let horizontalPadding: CGFloat = 20
        static let rotationDismissalAngle: CGFloat = .pi / 4
    }
    
    // MARK: - Public Properties
    weak var delegate: CustomCardViewDelegate?
    var isInteractionEnabled: Bool = false {
        didSet {
            isUserInteractionEnabled = isInteractionEnabled
        }
    }
    var isFlipEnabled: Bool = true
    
    // MARK: - Configuration Properties
    var gradientColor: GradientColor
    var width: CGFloat
    var height: CGFloat
    var innerCornerRadius: CGFloat
    var outherCornerRadius: CGFloat
    var shadowColor: ShadowColor
    var borderWidth: CGFloat
    
    // MARK: - State Properties
    private var initialCenter: CGPoint = .zero
    private var originalTransform: CGAffineTransform = .identity
    private var hasBeenFlipped = false
    private var isSpy: Bool = false
    private var status: ButtonStatus = .deactive {
        didSet {
            updateAppearance(shadowColor: status.shadowColor, gradientColor: status.gradientColor)
        }
    }
    
    // MARK: - Text Properties
    private var frontText1: String = ""
    private var frontText2: String = ""
    private var frontText3: String = ""
    private var backText1: String = ""
    private var backText2: String = ""
    private var backText3: String = ""
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let firstView = UIView()
    private let thirdView = UIView()
    private var gradientAnimationBorder: AnimatedGradientView!
    private var currentAnimator: UIViewPropertyAnimator?
    
    // MARK: - Labels
    private let label1: UILabel = {
        let label = UILabel()
        label.text = "Label 1"
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let label2: UILabel = {
        let label = UILabel()
        label.text = "Label 2"
        label.textAlignment = .center
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 18)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let label3: UILabel = {
        let label = UILabel()
        label.text = "Label 3"
        label.textAlignment = .center
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var spyWinkView: WinkAnimationView = {
        let winkView = WinkAnimationView(role: .spy, color: .white, sideLength: 100)
        winkView.translatesAutoresizingMaskIntoConstraints = false
        winkView.alpha = 0
        winkView.stopAnimation()
        return winkView
    }()
    
    // MARK: - Constraint Properties
    private var firstViewTopConstraint: NSLayoutConstraint!
    private var firstViewBottomConstraint: NSLayoutConstraint!
    private var firstViewLeadingConstraint: NSLayoutConstraint!
    private var firstViewTrailingConstraint: NSLayoutConstraint!
    
    // MARK: - Initialization
    init(labelText: String = "Hiii", gradientColor: GradientColor = .gray, width: CGFloat = GeneralConstants.Button.defaultWidth, height: CGFloat = GeneralConstants.Button.defaultHeight, innerCornerRadius: CGFloat = GeneralConstants.Button.innerCornerRadius, outherCornerRadius: CGFloat = GeneralConstants.Button.outerCornerRadius, shadowColor: ShadowColor = .gray, borderWidth: CGFloat = GeneralConstants.Button.borderWidth, fontSize: CGFloat = GeneralConstants.Font.size04, isBorderlessButton: Bool = false) {
        self.gradientColor = gradientColor
        self.width = width
        self.height = height
        self.innerCornerRadius = innerCornerRadius
        self.outherCornerRadius = outherCornerRadius
        self.shadowColor = shadowColor
        self.borderWidth = borderWidth
        super.init(frame: .zero)
        setupView(fontSize: fontSize)
        setupLabels()
        setupGestures()
        isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        self.gradientColor = .blue
        self.width = GeneralConstants.Button.defaultWidth
        self.height = GeneralConstants.Button.defaultHeight
        self.innerCornerRadius = GeneralConstants.Button.innerCornerRadius
        self.outherCornerRadius = GeneralConstants.Button.outerCornerRadius
        self.shadowColor = .red
        self.borderWidth = GeneralConstants.Button.borderWidth
        super.init(coder: coder)
        setupView(fontSize: GeneralConstants.Font.size04)
        setupLabels()
        setupGestures()
        isUserInteractionEnabled = false
    }
    
    // MARK: - Setup Methods
    private func setupView(fontSize: CGFloat) {
        setupContainerView()
        setupFirstView()
        setupGradientBorder()
        setupThirdView()
        setupViewHierarchy()
        setupConstraints()
    }
    
    private func setupContainerView() {
        addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    private func setupFirstView() {
        firstView.backgroundColor = .spyBlue04
        firstView.layer.cornerRadius = innerCornerRadius
        firstView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupGradientBorder() {
        gradientAnimationBorder = AnimatedGradientView(width: width, height: height, gradient: gradientColor)
        gradientAnimationBorder.layer.cornerRadius = outherCornerRadius
        gradientAnimationBorder.clipsToBounds = true
        gradientAnimationBorder.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupThirdView() {
        thirdView.backgroundColor = .gray
        thirdView.layer.shadowColor = shadowColor.cgColor
        thirdView.layer.shadowOpacity = GeneralConstants.Button.shadowOpacity
        thirdView.layer.shadowOffset = CGSize(width: 0, height: 1)
        thirdView.layer.shadowRadius = outherCornerRadius
        thirdView.layer.cornerRadius = outherCornerRadius
        thirdView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupViewHierarchy() {
        containerView.addSubview(thirdView)
        containerView.addSubview(gradientAnimationBorder)
        containerView.addSubview(firstView)
    }
    
    private func setupConstraints() {
        setupFirstViewConstraints()
        setupGradientBorderConstraints()
        setupThirdViewConstraints()
    }
    
    private func setupFirstViewConstraints() {
        firstViewTopConstraint = firstView.topAnchor.constraint(equalTo: gradientAnimationBorder.topAnchor, constant: borderWidth)
        firstViewBottomConstraint = firstView.bottomAnchor.constraint(equalTo: gradientAnimationBorder.bottomAnchor, constant: -borderWidth)
        firstViewLeadingConstraint = firstView.leadingAnchor.constraint(equalTo: gradientAnimationBorder.leadingAnchor, constant: borderWidth)
        firstViewTrailingConstraint = firstView.trailingAnchor.constraint(equalTo: gradientAnimationBorder.trailingAnchor, constant: -borderWidth)
        
        NSLayoutConstraint.activate([
            firstViewTopConstraint,
            firstViewLeadingConstraint,
            firstViewTrailingConstraint,
            firstViewBottomConstraint
        ])
    }
    
    private func setupGradientBorderConstraints() {
        NSLayoutConstraint.activate([
            gradientAnimationBorder.topAnchor.constraint(equalTo: containerView.topAnchor),
            gradientAnimationBorder.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            gradientAnimationBorder.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            gradientAnimationBorder.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    private func setupThirdViewConstraints() {
        NSLayoutConstraint.activate([
            thirdView.topAnchor.constraint(equalTo: gradientAnimationBorder.topAnchor),
            thirdView.leadingAnchor.constraint(equalTo: gradientAnimationBorder.leadingAnchor),
            thirdView.trailingAnchor.constraint(equalTo: gradientAnimationBorder.trailingAnchor),
            thirdView.bottomAnchor.constraint(equalTo: gradientAnimationBorder.bottomAnchor)
        ])
    }
    
    private func setupLabels() {
        addLabelsToContainer()
        setupLayoutGuides()
    }
    
    private func addLabelsToContainer() {
        containerView.addSubview(label1)
        containerView.addSubview(label2)
        containerView.addSubview(label3)
        containerView.addSubview(spyWinkView)
    }
    
    private func setupLayoutGuides() {
        let topGuide = UILayoutGuide()
        let middleGuide = UILayoutGuide()
        let bottomGuide = UILayoutGuide()
        
        containerView.addLayoutGuide(topGuide)
        containerView.addLayoutGuide(middleGuide)
        containerView.addLayoutGuide(bottomGuide)
        
        setupGuideConstraints(topGuide: topGuide, middleGuide: middleGuide, bottomGuide: bottomGuide)
        setupLabelConstraints(topGuide: topGuide, middleGuide: middleGuide, bottomGuide: bottomGuide)
    }
    
    private func setupGuideConstraints(topGuide: UILayoutGuide, middleGuide: UILayoutGuide, bottomGuide: UILayoutGuide) {
        NSLayoutConstraint.activate([
            topGuide.topAnchor.constraint(equalTo: containerView.topAnchor),
            topGuide.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            topGuide.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            topGuide.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1.0/3.0),
            
            middleGuide.topAnchor.constraint(equalTo: topGuide.bottomAnchor),
            middleGuide.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            middleGuide.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            middleGuide.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1.0/3.0),
            
            bottomGuide.topAnchor.constraint(equalTo: middleGuide.bottomAnchor),
            bottomGuide.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            bottomGuide.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            bottomGuide.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    private func setupLabelConstraints(topGuide: UILayoutGuide, middleGuide: UILayoutGuide, bottomGuide: UILayoutGuide) {
        NSLayoutConstraint.activate([
            label1.centerXAnchor.constraint(equalTo: topGuide.centerXAnchor),
            label1.centerYAnchor.constraint(equalTo: topGuide.centerYAnchor),
            label1.leadingAnchor.constraint(greaterThanOrEqualTo: topGuide.leadingAnchor, constant: InteractionConstants.horizontalPadding),
            label1.trailingAnchor.constraint(lessThanOrEqualTo: topGuide.trailingAnchor, constant: -InteractionConstants.horizontalPadding),
            
            label2.centerXAnchor.constraint(equalTo: middleGuide.centerXAnchor),
            label2.centerYAnchor.constraint(equalTo: middleGuide.centerYAnchor),
            label2.leadingAnchor.constraint(greaterThanOrEqualTo: middleGuide.leadingAnchor, constant: InteractionConstants.horizontalPadding),
            label2.trailingAnchor.constraint(lessThanOrEqualTo: middleGuide.trailingAnchor, constant: -InteractionConstants.horizontalPadding),
            
            spyWinkView.centerXAnchor.constraint(equalTo: middleGuide.centerXAnchor),
            spyWinkView.centerYAnchor.constraint(equalTo: middleGuide.centerYAnchor),
            spyWinkView.widthAnchor.constraint(equalTo: middleGuide.widthAnchor, multiplier: 0.5),
            spyWinkView.heightAnchor.constraint(equalTo: spyWinkView.widthAnchor),
            
            label3.centerXAnchor.constraint(equalTo: bottomGuide.centerXAnchor),
            label3.topAnchor.constraint(equalTo: bottomGuide.topAnchor),
            label3.leadingAnchor.constraint(greaterThanOrEqualTo: bottomGuide.leadingAnchor, constant: InteractionConstants.horizontalPadding),
            label3.trailingAnchor.constraint(lessThanOrEqualTo: bottomGuide.trailingAnchor, constant: -InteractionConstants.horizontalPadding)
        ])
    }
    
    private func setupGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Public Methods
    func setStatus(_ newStatus: ButtonStatus) {
        status = newStatus
    }
    
    func getStatus() -> ButtonStatus {
        return status
    }
    
    func updateAppearance(shadowColor: ShadowColor, gradientColor: GradientColor) {
        UIView.animate(withDuration: GeneralConstants.Animation.duration, animations: {
            self.shadowColor = shadowColor
            self.thirdView.layer.shadowColor = shadowColor.cgColor
            self.gradientAnimationBorder.updateGradient(to: gradientColor)
            self.firstView.backgroundColor = self.status.buttonColor.color
        })
    }
    
    func configure(role: String, selectedWord: String = "", isSpy: Bool = false, frontText: String = "tap_to_reveal_your_role".localized) {
        resetCardState()
        configureTexts(role: role, selectedWord: selectedWord, isSpy: isSpy, frontText: frontText)
        self.isSpy = isSpy
    }
    
    // MARK: - Private Configuration Methods
    private func resetCardState() {
        hasBeenFlipped = false
        label1.transform = .identity
        label2.transform = .identity
        label3.transform = .identity
    }
    
    private func configureTexts(role: String, selectedWord: String, isSpy: Bool, frontText: String) {
        frontText1 = role
        frontText2 = frontText
        frontText3 = ""
        
        backText1 = isSpy ? "spy".localized : "civil".localized
        backText2 = isSpy ? "" : selectedWord.localized
        backText3 = isSpy ? "try_to_blend_in".localized : "find_the_spies".localized
        
        label1.text = frontText1
        label2.text = frontText2
        label3.text = frontText3
    }
    
    // MARK: - Gesture Handlers
    @objc private func handleTap() {
        if !hasBeenFlipped && isFlipEnabled {
            guard isInteractionEnabled else { return }
            performFlipAnimation()
        } else {
            performBounceAnimation()
        }
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        let velocity = gesture.velocity(in: self.superview)
        
        switch gesture.state {
        case .began:
            initialCenter = center
            
        case .changed:
            handlePanChanged(translation: translation)
            
        case .ended:
            handlePanEnded(translation: translation, velocity: velocity)
            
        default:
            returnToOriginalPosition()
        }
    }
    
    // MARK: - Animation Methods
    private func performFlipAnimation() {
        let status: ButtonStatus = isSpy ? .activeRed : .activeBlue
        let originalZPosition = layer.zPosition
        layer.zPosition = 1000
        
        var transform3D = CATransform3DIdentity
        transform3D.m34 = AnimationConstants.transform3DPerspective
        
        isUserInteractionEnabled = false
        
        UIView.animate(withDuration: AnimationConstants.flipDuration,
                       delay: 0,
                       options: .curveEaseIn) {
            transform3D = CATransform3DRotate(transform3D, .pi / 2, 0.0, 1.0, 0.0)
            self.layer.transform = transform3D
            
            self.label1.alpha = 0
            self.label2.alpha = 0
            self.label3.alpha = 0
            self.spyWinkView.alpha = 0
        } completion: { _ in
            self.setStatus(status)
            self.label1.text = self.backText1
            self.label3.text = self.backText3
            
            self.label1.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.label2.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.label3.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.spyWinkView.transform = CGAffineTransform(scaleX: -1, y: 1)
            
            UIView.animate(withDuration: AnimationConstants.flipDuration) {
                self.label1.alpha = 1
                self.label3.alpha = 1
                if self.isSpy {
                    self.spyWinkView.alpha = 1
                    self.spyWinkView.setAnimationInterval(AnimationConstants.spyWinkAnimationInterval)
                } else {
                    self.label2.text = self.backText2
                    self.label2.textColor = .white
                    self.label2.font = UIFont.systemFont(ofSize: 28, weight: .bold)

                    self.label2.alpha = 1
                    
                }
            }
            
            UIView.animate(withDuration: AnimationConstants.flipDuration,
                           delay: 0,
                           options: .curveEaseOut) {
                transform3D = CATransform3DRotate(transform3D, .pi / 2, 0.0, 1.0, 0.0)
                self.layer.transform = transform3D
            } completion: { _ in
                self.layer.zPosition = originalZPosition
                self.isUserInteractionEnabled = true
                self.hasBeenFlipped = true
            }
        }
    }
    
    private func performBounceAnimation() {
        let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        bounceAnimation.values = AnimationConstants.bounceValues
        bounceAnimation.keyTimes = AnimationConstants.bounceKeyTimes
        bounceAnimation.duration = AnimationConstants.bounceDuration
        bounceAnimation.timingFunctions = Array(repeating: CAMediaTimingFunction(name: .easeInEaseOut), count: 4)
        layer.add(bounceAnimation, forKey: "bounce")
    }
    
    // MARK: - Pan Gesture Helpers
    private func handlePanChanged(translation: CGPoint) {
        center = CGPoint(x: initialCenter.x + (translation.x * AnimationConstants.resistance),
                         y: initialCenter.y + (translation.y * AnimationConstants.resistance))
        
        let rotationAngle = (translation.x / bounds.width) * InteractionConstants.maxRotation * AnimationConstants.resistance
        containerView.transform = CGAffineTransform(rotationAngle: rotationAngle)
    }
    
    private func handlePanEnded(translation: CGPoint, velocity: CGPoint) {
        if hasBeenFlipped || !isFlipEnabled {
            if shouldDismissCard(translation: translation, velocity: velocity) {
                dismissCard(velocity: velocity, translation: translation)
                return
            }
        }
        
        returnToOriginalPositionWithVelocity(velocity: velocity)
    }
    
    private func shouldDismissCard(translation: CGPoint, velocity: CGPoint) -> Bool {
        let horizontalVelocityHigh = abs(velocity.x) > InteractionConstants.throwVelocityThreshold
        let horizontalMovedFar = abs(translation.x) > bounds.width * InteractionConstants.dismissalThreshold
        let shouldDismissHorizontally = horizontalVelocityHigh || horizontalMovedFar
        
        let verticalVelocityHigh = abs(velocity.y) > InteractionConstants.throwVelocityThreshold
        let verticalMovedFar = abs(translation.y) > bounds.height * InteractionConstants.dismissalThreshold
        let shouldDismissVertically = verticalVelocityHigh || verticalMovedFar
        
        return shouldDismissHorizontally || shouldDismissVertically
    }
    
    private func returnToOriginalPositionWithVelocity(velocity: CGPoint) {
        let velocityFactor = CGPoint(
            x: abs(velocity.x) / AnimationConstants.velocityFactor,
            y: abs(velocity.y) / AnimationConstants.velocityFactor
        )
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: AnimationConstants.springDamping,
                       initialSpringVelocity: max(velocityFactor.x, velocityFactor.y),
                       options: [.curveEaseOut, .allowUserInteraction]) {
            self.center = self.initialCenter
            self.containerView.transform = .identity
        }
    }
    
    private func returnToOriginalPosition() {
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: AnimationConstants.springDamping,
                       initialSpringVelocity: AnimationConstants.springVelocity,
                       options: [.curveEaseOut, .allowUserInteraction]) {
            self.center = self.initialCenter
            self.containerView.transform = .identity
        }
    }
    
    private func dismissCard(velocity: CGPoint, translation: CGPoint) {
        let screenBounds = UIScreen.main.bounds
        let isVerticalDismissal = abs(translation.y) > abs(translation.x)
        
        var finalCenter = center
        var finalRotation: CGFloat = 0
        
        if isVerticalDismissal {
            let directionY: CGFloat = velocity.y >= 0 ? 1 : -1
            finalCenter.y += screenBounds.height * directionY
        } else {
            let directionX: CGFloat = velocity.x >= 0 ? 1 : -1
            finalCenter.x += screenBounds.width * directionX
            finalRotation = directionX * InteractionConstants.rotationDismissalAngle
        }
        
        UIView.animate(withDuration: AnimationConstants.dismissDuration,
                       delay: 0,
                       options: .curveEaseOut) {
            self.center = finalCenter
            self.containerView.transform = CGAffineTransform(rotationAngle: finalRotation)
            self.alpha = 1
        } completion: { _ in
            self.delegate?.cardViewWasDismissed(self)
            self.removeFromSuperview()
        }
    }
}

// MARK: - Preview Provider
//struct CustomCardPreviewViewController: UIViewControllerRepresentable {
//    func makeUIViewController(context: Context) -> UIViewController {
//        let viewController = UIViewController()
//        viewController.view.backgroundColor = .black
//
//        let cardView = CustomCardView()
//        cardView.center = viewController.view.center
//        cardView.configure(role: "Hello", selectedWord: "This is a card")
//        cardView.isInteractionEnabled = true
//
//        viewController.view.addSubview(cardView)
//        cardView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            cardView.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
//            cardView.centerYAnchor.constraint(equalTo: viewController.view.centerYAnchor),
//            cardView.widthAnchor.constraint(equalToConstant: 300),
//            cardView.heightAnchor.constraint(equalToConstant: 400)
//        ])
//
//        return viewController
//    }
//
//    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
//        // No dynamic updates for now
//    }
//}
//
//#Preview {
//    CustomCardPreviewViewController()
//}
