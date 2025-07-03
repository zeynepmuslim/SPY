import UIKit

class CustomGradientSwitch: UIView {
    
    // MARK: - Constants
    private enum SwitchConstants {
        static let width: CGFloat = 90
        static let fontSizeMultiplier: CGFloat = 0.4
        static let onText = "I"
        static let offText = "0"
    }
    
    // MARK: - UI Components
    private let switchContainer = UIView()
    private let indicatorLabel = UILabel()
    private var gradientAnimationBorder: AnimatedGradientView!
    private var currentAnimator: UIViewPropertyAnimator?
    
    // MARK: - Properties
    private let switchHeight: CGFloat
    private let borderWidth: CGFloat = GeneralConstants.Button.borderWidth
    
    private var innerSize: CGFloat {
        return switchHeight - 2 * borderWidth
    }
    
    private var switchWidth: CGFloat {
        return SwitchConstants.width
    }
    
    private var onPosition: CGFloat {
        return switchWidth - innerSize - borderWidth * 2
    }
    
    private var offPosition: CGFloat {
        return 0
    }
    
    var isOn: Bool = true {
        didSet {
            guard oldValue != isOn else { return }
            updateSwitchState()
        }
    }
    
    var state: Bool {
        return isOn
    }
    
    private var status: ButtonStatus = .activeBlue {
        didSet {
            updateAppearance()
        }
    }
    
    // MARK: - Initialization
    init(switchHeight: CGFloat = GeneralConstants.Button.miniHeight, 
         gradientColor: GradientColor = .blue, 
         shadowColor: ShadowColor = .blue, 
         buttonColor: ButtonColor = .blue) {
        self.switchHeight = switchHeight
        super.init(frame: .zero)
        commonInit()
        updateAppearance(shadowColor: shadowColor, gradientColor: gradientColor, buttonColor: buttonColor)
    }
    
    required init?(coder: NSCoder) {
        self.switchHeight = GeneralConstants.Button.miniHeight
        super.init(coder: coder)
        commonInit()
        updateAppearance(shadowColor: .blue, gradientColor: .blue, buttonColor: .blue)
    }
    
    // MARK: - Setup
    private func commonInit() {
        setupViews()
        setupConstraints()
        setupTapGesture()
        setInitialState()
    }
    
    private func setupViews() {
        switchContainer.backgroundColor = .spyBlue04
        switchContainer.layer.cornerRadius = GeneralConstants.Button.innerCornerRadius
        
        gradientAnimationBorder = AnimatedGradientView(width: switchWidth, height: switchHeight, gradient: .blue)
        gradientAnimationBorder.layer.cornerRadius = GeneralConstants.Button.outerCornerRadius
        gradientAnimationBorder.clipsToBounds = true
        
        configureIndicatorLabel()
        
        addSubview(gradientAnimationBorder)
        addSubview(switchContainer)
        switchContainer.addSubview(indicatorLabel)
        
        [gradientAnimationBorder, switchContainer, indicatorLabel, self].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func configureIndicatorLabel() {
        indicatorLabel.textColor = .white
        indicatorLabel.font = .boldSystemFont(ofSize: switchHeight * SwitchConstants.fontSizeMultiplier)
        indicatorLabel.textAlignment = .center
        indicatorLabel.text = SwitchConstants.onText
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            gradientAnimationBorder.topAnchor.constraint(equalTo: topAnchor),
            gradientAnimationBorder.leadingAnchor.constraint(equalTo: leadingAnchor),
            gradientAnimationBorder.trailingAnchor.constraint(equalTo: trailingAnchor),
            gradientAnimationBorder.bottomAnchor.constraint(equalTo: bottomAnchor),
            gradientAnimationBorder.widthAnchor.constraint(equalToConstant: switchWidth),
            gradientAnimationBorder.heightAnchor.constraint(equalToConstant: switchHeight),
            
            switchContainer.centerYAnchor.constraint(equalTo: centerYAnchor),
            switchContainer.widthAnchor.constraint(equalToConstant: innerSize),
            switchContainer.heightAnchor.constraint(equalToConstant: innerSize),
            switchContainer.leadingAnchor.constraint(equalTo: gradientAnimationBorder.leadingAnchor, constant: borderWidth),
            
            indicatorLabel.centerXAnchor.constraint(equalTo: switchContainer.centerXAnchor),
            indicatorLabel.centerYAnchor.constraint(equalTo: switchContainer.centerYAnchor)
        ])
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
    }
    
    private func setInitialState() {
        switchContainer.transform = CGAffineTransform(translationX: onPosition, y: 0)
        status = .activeBlue
    }
    
    // MARK: - Actions
    @objc private func handleTap() {
        isOn.toggle()
    }
    
    // MARK: - Public Methods
    func setState(_ state: Bool, animated: Bool = true) {
        guard state != isOn else { return }
        isOn = state
        if !animated {
            switchContainer.transform = CGAffineTransform(translationX: isOn ? onPosition : offPosition, y: 0)
        }
    }
    
    // MARK: - Private Methods
    private func updateSwitchState() {
        status = isOn ? .activeBlue : .deactive
        animateSwitch()
    }
    
    private func animateSwitch() {
        stopCurrentAnimation()
        
        let targetX = isOn ? onPosition : offPosition
        let targetText = isOn ? SwitchConstants.onText : SwitchConstants.offText
        
        UIView.transition(with: indicatorLabel, 
                         duration: GeneralConstants.Animation.duration, 
                         options: .transitionFlipFromRight) {
            self.indicatorLabel.text = targetText
        }
        
        let animator = UIViewPropertyAnimator(duration: GeneralConstants.Animation.duration, curve: .easeInOut) {
            self.switchContainer.transform = CGAffineTransform(translationX: targetX, y: 0)
            self.layoutIfNeeded()
        }
        
        animator.addCompletion { [weak self] _ in
            self?.currentAnimator = nil
        }
        
        currentAnimator = animator
        animator.startAnimation()
    }
    
    private func stopCurrentAnimation() {
        currentAnimator?.stopAnimation(true)
        currentAnimator?.finishAnimation(at: .current)
        currentAnimator = nil
    }
    
    private func updateAppearance(shadowColor: ShadowColor? = nil, 
                                 gradientColor: GradientColor? = nil, 
                                 buttonColor: ButtonColor? = nil) {
        UIView.animate(withDuration: GeneralConstants.Animation.duration) {
            if let gradientColor = gradientColor {
                self.gradientAnimationBorder.updateGradient(to: gradientColor)
            }
            if let buttonColor = buttonColor {
                self.switchContainer.backgroundColor = buttonColor.color
            }
            self.indicatorLabel.textColor = self.isOn ? .white : .spyGray01
        }
    }
    
    private func updateAppearance() {
        updateAppearance(shadowColor: status.shadowColor, 
                        gradientColor: status.gradientColor, 
                        buttonColor: status.buttonColor)
    }
} 
