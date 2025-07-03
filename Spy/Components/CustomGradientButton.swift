import UIKit
import SwiftUI

class CustomGradientButton: UIView {
    
    // MARK: - Public Properties
    
    /// Button interaction callback
    var onClick: (() -> Void)?
    
    /// Text displayed on the button (triggers animation when changed)
    var labelText: String {
        didSet {
            titleLabel.text = labelText
            animateLabelChange()
        }
    }
    
    /// Icon displayed on the button (hides text when set)
    var iconImage: UIImage? {
        didSet {
            updateIcon()
        }
    }
    
    // MARK: - Style Properties
    
    var gradientColor: GradientColor
    var buttonColor: ButtonColor
    var shadowColor: ShadowColor
    var width: CGFloat
    var height: CGFloat
    var innerCornerRadius: CGFloat
    var outerCornerRadius: CGFloat
    var borderWidth: CGFloat
    var isBorderlessButton: Bool
    
    // MARK: - Private Properties
    
    private let contentView = UIView()
    private let shadowView = UIView()
    private let titleLabel = UILabel()
    private let iconImageView = UIImageView()
    private var gradientAnimationBorder: AnimatedGradientView!
    private var currentAnimator: UIViewPropertyAnimator?
    
    private var contentViewConstraints: [NSLayoutConstraint] = []
    
    private var status: ButtonStatus = .activeBlue {
        didSet {
            updateAppearance(
                shadowColor: status.shadowColor,
                gradientColor: status.gradientColor,
                buttonColor: status.buttonColor
            )
        }
    }
    
    private struct Constants {
        static let iconSizeMultiplier: CGFloat = 0.4
        static let shadowOffsetY: CGFloat = 1
    }
    
    init(
        labelText: String = "Hiii",
        iconImage: UIImage? = nil,
        gradientColor: GradientColor = .blue,
        width: CGFloat = GeneralConstants.Button.defaultWidth,
        height: CGFloat = GeneralConstants.Button.defaultHeight,
        innerCornerRadius: CGFloat = GeneralConstants.Button.innerCornerRadius,
        outerCornerRadius: CGFloat = GeneralConstants.Button.outerCornerRadius,
        shadowColor: ShadowColor = .blue,
        buttonColor: ButtonColor = .blue,
        borderWidth: CGFloat = GeneralConstants.Button.borderWidth,
        fontSize: CGFloat = GeneralConstants.Font.size04,
        isBorderlessButton: Bool = false
    ) {
        self.gradientColor = gradientColor
        self.buttonColor = buttonColor
        self.shadowColor = shadowColor
        self.width = width
        self.height = height
        self.innerCornerRadius = innerCornerRadius
        self.outerCornerRadius = outerCornerRadius
        self.borderWidth = borderWidth
        self.isBorderlessButton = isBorderlessButton
        self.labelText = labelText
        self.iconImage = iconImage
        super.init(frame: .zero)
        setupViews(fontSize: fontSize)
        setupConstraints()
        setupTapGesture()
        updateIcon()
    }
    
    required init?(coder: NSCoder) {
        self.gradientColor = .blue
        self.buttonColor = .blue
        self.shadowColor = .blue
        self.width = GeneralConstants.Button.defaultWidth
        self.height = GeneralConstants.Button.defaultHeight
        self.innerCornerRadius = GeneralConstants.Button.innerCornerRadius
        self.outerCornerRadius = GeneralConstants.Button.outerCornerRadius
        self.borderWidth = GeneralConstants.Button.borderWidth
        self.isBorderlessButton = false
        self.labelText = "Button"
        self.iconImage = nil
        super.init(coder: coder)
        setupViews(fontSize: GeneralConstants.Font.size04)
        setupConstraints()
        setupTapGesture()
        updateIcon()
    }
    
    private func setupViews(fontSize: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        
        gradientAnimationBorder = AnimatedGradientView(
            width: width,
            height: height,
            gradient: gradientColor
        )
        configureView(gradientAnimationBorder, cornerRadius: outerCornerRadius)
        gradientAnimationBorder.clipsToBounds = true
        
        configureShadowView()
        configureContentView()
        configureTitleLabel(fontSize: fontSize)
        configureIconImageView()
        addSubviews()
    }
    
    private func configureShadowView() {
        configureView(shadowView, cornerRadius: outerCornerRadius)
        shadowView.backgroundColor = .gray
        shadowView.layer.shadowColor = shadowColor.cgColor
        shadowView.layer.shadowOpacity = GeneralConstants.Button.shadowOpacity
        shadowView.layer.shadowOffset = CGSize(width: 0, height: Constants.shadowOffsetY)
        shadowView.layer.shadowRadius = outerCornerRadius
    }
    
    private func configureContentView() {
        configureView(contentView, cornerRadius: innerCornerRadius)
        contentView.backgroundColor = buttonColor.color
        contentView.isHidden = isBorderlessButton
    }
    
    private func configureTitleLabel(fontSize: CGFloat) {
        configureView(titleLabel)
        titleLabel.text = labelText
        titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: fontSize)
        titleLabel.textAlignment = .center
    }
    
    private func configureIconImageView() {
        configureView(iconImageView)
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .white
    }
    
    private func configureView(_ view: UIView, cornerRadius: CGFloat = 0) {
        view.translatesAutoresizingMaskIntoConstraints = false
        if cornerRadius > 0 {
            view.layer.cornerRadius = cornerRadius
        }
    }
    
    private func addSubviews() {
        [shadowView, gradientAnimationBorder, contentView, titleLabel, iconImageView].forEach {
            addSubview($0)
        }
    }
    
    // MARK: - Constraints Setup
    
    private func setupConstraints() {
        // Store content view constraints for animation
        contentViewConstraints = [
            contentView.topAnchor.constraint(equalTo: gradientAnimationBorder.topAnchor, constant: borderWidth),
            contentView.bottomAnchor.constraint(equalTo: gradientAnimationBorder.bottomAnchor, constant: -borderWidth),
            contentView.leadingAnchor.constraint(equalTo: gradientAnimationBorder.leadingAnchor, constant: borderWidth),
            contentView.trailingAnchor.constraint(equalTo: gradientAnimationBorder.trailingAnchor, constant: -borderWidth)
        ]
        
        NSLayoutConstraint.activate([
            gradientAnimationBorder.topAnchor.constraint(equalTo: topAnchor),
            gradientAnimationBorder.leadingAnchor.constraint(equalTo: leadingAnchor),
            gradientAnimationBorder.trailingAnchor.constraint(equalTo: trailingAnchor),
            gradientAnimationBorder.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            shadowView.topAnchor.constraint(equalTo: gradientAnimationBorder.topAnchor),
            shadowView.leadingAnchor.constraint(equalTo: gradientAnimationBorder.leadingAnchor),
            shadowView.trailingAnchor.constraint(equalTo: gradientAnimationBorder.trailingAnchor),
            shadowView.bottomAnchor.constraint(equalTo: gradientAnimationBorder.bottomAnchor),
            
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
                        iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: Constants.iconSizeMultiplier),
            iconImageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: Constants.iconSizeMultiplier)
        ])
        
        NSLayoutConstraint.activate(contentViewConstraints)
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap() {
        stopCurrentAnimation()
        animateButtonPress()
        onClick?()
    }
    
    private func stopCurrentAnimation() {
        currentAnimator?.stopAnimation(true)
        currentAnimator?.finishAnimation(at: .current)
    }
    
    private func animateButtonPress() {
        let animator = UIViewPropertyAnimator(
            duration: GeneralConstants.Animation.duration,
            curve: .easeInOut
        ) {
            AnimationHelper.animateButton(
                firstView: self.contentView,
                thirdView: self.shadowView,
                firstViewTopConstraint: self.contentViewConstraints[0],
                firstViewBottomConstraint: self.contentViewConstraints[1],
                firstViewLeadingConstraint: self.contentViewConstraints[2],
                firstViewTrailingConstraint: self.contentViewConstraints[3],
                outerCornerRadius: self.outerCornerRadius,
                innerCornerRadius: self.innerCornerRadius,
                borderWidth: self.borderWidth
            )
            self.layoutIfNeeded()
        }
        
        animator.addCompletion { [weak self] _ in
            self?.currentAnimator = nil
        }
        
        currentAnimator = animator
        animator.startAnimation()
    }
    
    private func animateLabelChange() {
        UIView.transition(
            with: titleLabel,
            duration: GeneralConstants.Animation.duration,
            options: .transitionCrossDissolve,
            animations: {
                self.titleLabel.text = self.labelText
            }
        )
    }
    
    private func updateIcon() {
        let hasIcon = iconImage != nil
        iconImageView.image = iconImage
        iconImageView.isHidden = !hasIcon
        titleLabel.isHidden = hasIcon
    }
    
    private func updateAppearance(
        shadowColor: ShadowColor,
        gradientColor: GradientColor,
        buttonColor: ButtonColor
    ) {
        UIView.animate(withDuration: GeneralConstants.Animation.duration) {
            self.shadowColor = shadowColor
            self.shadowView.layer.shadowColor = shadowColor.cgColor
            self.gradientAnimationBorder.updateGradient(to: gradientColor)
            self.contentView.backgroundColor = buttonColor.color
        }
    }
    
    func setStatus(_ newStatus: ButtonStatus) {
        status = newStatus
    }
    
    var currentStatus: ButtonStatus {
        return status
    }
}

//struct CustomGradientButtonViewController: UIViewControllerRepresentable {
//    func makeUIViewController(context: Context) -> UIViewController {
//        let viewController = UIViewController()
//        viewController.view.backgroundColor = .systemGray
//        
//        let buttons = createSampleButtons()
//        let stackView = createStackView(with: buttons)
//        
//        viewController.view.addSubview(stackView)
//        NSLayoutConstraint.activate([
//            stackView.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
//            stackView.centerYAnchor.constraint(equalTo: viewController.view.centerYAnchor)
//        ])
//        
//        return viewController
//    }
//    
//    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
//    
//    private func createSampleButtons() -> [CustomGradientButton] {
//        let activeRedButton = CustomGradientButton(
//            labelText: "Active Red",
//            gradientColor: .red,
//            shadowColor: .red
//        )
//        activeRedButton.setStatus(.activeRed)
//        
//        let activeBlueButton = CustomGradientButton(
//            labelText: "Active Blue",
//            gradientColor: .blue,
//            shadowColor: .blue
//        )
//        activeBlueButton.setStatus(.activeBlue)
//        
//        let deactiveButton = CustomGradientButton(
//            labelText: "Deactive",
//            gradientColor: .gray,
//            shadowColor: .gray
//        )
//        deactiveButton.setStatus(.deactive)
//        
//        return [activeRedButton, activeBlueButton, deactiveButton]
//    }
//    
//    private func createStackView(with buttons: [CustomGradientButton]) -> UIStackView {
//        let stackView = UIStackView(arrangedSubviews: buttons)
//        stackView.axis = .vertical
//        stackView.spacing = 20
//        stackView.alignment = .center
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        return stackView
//    }
//}
//
//struct ViewController_Previews4: PreviewProvider {
//    static var previews: some View {
//        CustomGradientButtonViewController()
//    }
//}
