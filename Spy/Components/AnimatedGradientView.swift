import UIKit

class AnimatedGradientView: UIView {
    
    // MARK: - Constants
    private enum Constants {
        static let gradientScaleFactor: CGFloat = 1.3
        static let rotationAnimationDuration: TimeInterval = 5.0
        static let rotationAnimationKey = "rotation"
        static let colorChangeAnimationKey = "colorChange"
    }
    
    // MARK: - Properties
    private let gradientLayer = CAGradientLayer()
    
    // MARK: - Initialization
    init(width: CGFloat, height: CGFloat, gradient: GradientColor) {
        super.init(frame: .zero)
        setupView(width: width, height: height)
        setupGradient(gradient: gradient)
        startRotationAnimation()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        updateGradientLayerFrame()
    }
    
    // MARK: - Setup Methods
    private func setupView(width: CGFloat, height: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: width),
            heightAnchor.constraint(equalToConstant: height)
        ])
    }
    
    private func setupGradient(gradient: GradientColor) {
        gradientLayer.colors = gradient.colors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        layer.addSublayer(gradientLayer)
    }
    
    private func updateGradientLayerFrame() {
        let maxSide = max(bounds.width, bounds.height)
        let scaledSize = maxSide * Constants.gradientScaleFactor
        
        gradientLayer.frame = CGRect(
            x: bounds.midX - scaledSize / 2,
            y: bounds.midY - scaledSize / 2,
            width: scaledSize,
            height: scaledSize
        )
    }
    
    // MARK: - Animation Methods
    private func startRotationAnimation() {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = CGFloat.pi * 2
        rotationAnimation.duration = Constants.rotationAnimationDuration
        rotationAnimation.repeatCount = .infinity
        rotationAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        
        gradientLayer.add(rotationAnimation, forKey: Constants.rotationAnimationKey)
    }
    
    // MARK: - Public Methods
    func updateGradient(to gradient: GradientColor) {
        let colorAnimation = CABasicAnimation(keyPath: "colors")
        colorAnimation.fromValue = gradientLayer.colors
        colorAnimation.toValue = gradient.colors
        colorAnimation.duration = GeneralConstants.Animation.duration
        colorAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        gradientLayer.add(colorAnimation, forKey: Constants.colorChangeAnimationKey)
        gradientLayer.colors = gradient.colors
    }
}
