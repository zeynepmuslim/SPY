//
//  CustomPlayerCell.swift
//  Spy
//
//  Created by Zeynep Müslim on 6.04.2025. // Consider updating the date if needed
//

import UIKit
import SwiftUI

// MARK: - CustomPlayerCell

class CustomPlayerCell: UICollectionViewCell {
        static let identifier = "CustomPlayerCell"
    
    // MARK: - Styling Properties
    var gradientColor: GradientColor
    var buttonColor: ButtonColor
    var shadowColor: ShadowColor
    var borderWidth: CGFloat

    // MARK: - UI Components
    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .none
        textField.textAlignment = .center
        textField.font = .systemFont(ofSize: 16, weight: .medium)
        textField.textColor = .white
        textField.backgroundColor = .clear
        textField.tintColor = .white
        textField.returnKeyType = .done
        textField.isHidden = true
        return textField
    }()

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 0
        stack.backgroundColor = ButtonColor.blue.color
        stack.layer.cornerRadius = GeneralConstants.Button.innerCornerRadius
        stack.alignment = .center
        stack.axis = .vertical
        stack.distribution = .fill
        return stack
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let spacerView1 = UIView()
    private let spacerView2 = UIView()
    
    // MARK: - Properties
    private var gradientAnimationBorder: AnimatedGradientView!
    private var currentAnimator: UIViewPropertyAnimator?
    private var underlineLayer: CAShapeLayer?
    
    private var stackViewTopConstraint: NSLayoutConstraint!
    private var stackViewBottomConstraint: NSLayoutConstraint!
    private var stackViewLeadingConstraint: NSLayoutConstraint!
    private var stackViewTrailingConstraint: NSLayoutConstraint!
    
    private var status: ButtonStatus = .activeBlue {
        didSet {
            guard oldValue != status else { return }
            animateAppearanceChange(to: status)
        }
    }
    
    weak var delegate: CustomPlayerCellDelegate?
    private var originalNameBeforeEditing: String?
    private var maxNameLength: Int = 10
    private var isEditingInProgress: Bool = false
    private var isStopEditingInProgress: Bool = false
    
    private let padding: CGFloat = GeneralConstants.Button.borderWidth

    // MARK: - Initialization
    override init(frame: CGRect) {
        self.gradientColor = GradientColor.blue
        self.buttonColor = ButtonColor.blue
        self.shadowColor = ShadowColor.blue
        self.borderWidth = GeneralConstants.Button.borderWidth
        
        super.init(frame: frame)
        
        setupUI()
        setupConstraints()
        configureShadow()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        gradientAnimationBorder = AnimatedGradientView(
            width: contentView.frame.width,
            height: contentView.frame.height,
            gradient: gradientColor
        )
        gradientAnimationBorder.layer.cornerRadius = GeneralConstants.Button.outerCornerRadius
        gradientAnimationBorder.clipsToBounds = true

        stackView.addArrangedSubview(spacerView1)
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(spacerView2)
        
        contentView.addSubview(gradientAnimationBorder)
        contentView.addSubview(stackView)
        contentView.addSubview(nameTextField)
        
        contentView.bringSubviewToFront(nameTextField)

        nameTextField.delegate = self
        
        contentView.layer.cornerRadius = GeneralConstants.Button.outerCornerRadius
    }
    
    private func setupConstraints() {
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        iconImageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        deactivateExistingConstraints()

        stackViewLeadingConstraint = stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding)
        stackViewTrailingConstraint = stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding)
        stackViewTopConstraint = stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding)
        stackViewBottomConstraint = stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)

        NSLayoutConstraint.activate([
            stackViewLeadingConstraint,
            stackViewTrailingConstraint,
            stackViewTopConstraint,
            stackViewBottomConstraint,
            stackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            nameTextField.leadingAnchor.constraint(equalTo: label.leadingAnchor, constant: -10),
            nameTextField.trailingAnchor.constraint(equalTo: label.trailingAnchor, constant: 10),
            nameTextField.centerYAnchor.constraint(equalTo: label.centerYAnchor),
            nameTextField.heightAnchor.constraint(equalTo: label.heightAnchor, multiplier: 1.2),
            
            iconImageView.heightAnchor.constraint(equalTo: stackView.heightAnchor, multiplier: 0.5),
            label.heightAnchor.constraint(equalTo: stackView.heightAnchor, multiplier: 0.3),
            iconImageView.widthAnchor.constraint(equalTo: iconImageView.heightAnchor),
            spacerView1.heightAnchor.constraint(equalTo: stackView.heightAnchor, multiplier: 0.1),
            spacerView2.heightAnchor.constraint(equalTo: stackView.heightAnchor, multiplier: 0.1)
        ])
    }
    
    private func deactivateExistingConstraints() {
        [label, iconImageView, spacerView1, spacerView2].forEach { view in
            view.constraints.forEach { $0.isActive = false }
        }
    }
    
    private func configureShadow() {
        contentView.layer.shadowColor = shadowColor.cgColor
        contentView.layer.shadowOpacity = GeneralConstants.Button.shadowOpacity
        contentView.layer.shadowOffset = CGSize(width: 0, height: 1)
        contentView.layer.shadowRadius = 5
        contentView.layer.masksToBounds = false
    }
    
    // MARK: - Configuration Methods
    func configure(playerNumber: Int, color: UIColor, iconName: String) {
        label.text = String(format: "player_x".localized, playerNumber)
        iconImageView.image = UIImage(named: iconName)
    }

    func updateLayout(isVertical: Bool) {
        let newAxis: NSLayoutConstraint.Axis = isVertical ? .vertical : .horizontal
        
        if stackView.axis != newAxis {
            stackView.axis = newAxis
            contentView.layoutIfNeeded()
        }
    }
    
    // MARK: - Status Management
    func setStatus(_ newStatus: ButtonStatus) {
        status = newStatus
    }
    
    func getStatus() -> ButtonStatus {
        return status
    }
    
    // MARK: - Animation Methods
    private func animateAppearanceChange(to newStatus: ButtonStatus) {
        let totalDuration = GeneralConstants.Animation.duration
        let shadowColor = newStatus.shadowColor
        let gradientColor = newStatus.gradientColor
        let buttonColor = newStatus.buttonColor

        currentAnimator?.stopAnimation(true)

        currentAnimator = UIViewPropertyAnimator(duration: totalDuration, curve: .easeInOut) {
            self.performStatusChangeAnimation(shadowColor: shadowColor, gradientColor: gradientColor, buttonColor: buttonColor, totalDuration: totalDuration)
        }
        currentAnimator?.startAnimation()
    }
    
    private func performStatusChangeAnimation(shadowColor: ShadowColor, gradientColor: GradientColor, buttonColor: ButtonColor, totalDuration: Double) {
             UIView.animateKeyframes(withDuration: totalDuration, delay: 0, options: [.allowUserInteraction], animations: {
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5) {
                self.updateColorsAndShrinkPadding(shadowColor: shadowColor, gradientColor: gradientColor, buttonColor: buttonColor)
                }

                UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                self.restorePadding()
                }
            }, completion: nil)
    }
    
    private func updateColorsAndShrinkPadding(shadowColor: ShadowColor, gradientColor: GradientColor, buttonColor: ButtonColor) {
        self.shadowColor = shadowColor
        contentView.layer.shadowColor = shadowColor.cgColor
        gradientAnimationBorder.updateGradient(to: gradientColor)
        stackView.backgroundColor = buttonColor.color
        stackView.layer.cornerRadius = GeneralConstants.Button.outerCornerRadius
        
        stackViewTopConstraint.constant = 0
        stackViewBottomConstraint.constant = 0
        stackViewLeadingConstraint.constant = 0
        stackViewTrailingConstraint.constant = 0
        contentView.layoutIfNeeded()
    }
    
    private func restorePadding() {
        stackViewTopConstraint.constant = padding
        stackViewBottomConstraint.constant = -padding
        stackViewLeadingConstraint.constant = padding
        stackViewTrailingConstraint.constant = -padding
        stackView.layer.cornerRadius = GeneralConstants.Button.innerCornerRadius
        contentView.layoutIfNeeded()
    }
    
    // MARK: - Editing Methods
    func startEditing() {
        guard !isEditingInProgress else { return }
        
        isEditingInProgress = true
        originalNameBeforeEditing = label.text
        prepareForEditingAnimation()
        nameTextField.becomeFirstResponder()
        performEditingStartAnimation()
    }
    
    func stopEditing() {
        guard isEditingInProgress else { return }
        
        // Clean up any existing animations first to prevent conflicts
        underlineLayer?.removeAllAnimations()
        
        isEditingInProgress = false
        isStopEditingInProgress = true
        
        nameTextField.resignFirstResponder()
        handleNameChange()
        performEditingStopAnimation()
    }
    

    
    private func prepareForEditingAnimation() {
        label.isHidden = false
        nameTextField.isHidden = false
        label.alpha = 1.0
        nameTextField.alpha = 0.0
        nameTextField.text = label.text

        configureUnderline(opacity: 0, strokeStart: 0.5, strokeEnd: 0.5, removeAnimations: true) // resetUnderlineForAnimation
    }
    
    private func handleNameChange() {
        let newName = nameTextField.text ?? ""
        let trimmedName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedName.isEmpty {
            label.text = originalNameBeforeEditing
        } else {
            label.text = trimmedName
            delegate?.playerNameDidChange(in: self, to: trimmedName)
        }
    }
    
    private func performEditingStartAnimation() {
        CATransaction.begin()
        CATransaction.setCompletionBlock { [weak self] in
            if self?.isStopEditingInProgress == false {
                self?.label.isHidden = true
                self?.configureUnderline(opacity: 1.0, strokeStart: 0.0, strokeEnd: 1.0)
            }
        }
        
        animateLabelToTextField()
        animateUnderline(isAppearing: true)
        
        CATransaction.commit()
    }
    
    private func performEditingStopAnimation() {
        guard let labelText = label.text, !labelText.isEmpty else {
            forceShowLabel()
            return
        }
        
        label.isHidden = false
        nameTextField.isHidden = false
        label.alpha = 0.0
        nameTextField.alpha = 1.0
        
        configureUnderline(opacity: 1, strokeStart: 0, strokeEnd: 1, removeAnimations: true)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.label.alpha = 1
            self.nameTextField.alpha = 0
        }) { [weak self] completed in
            if completed {
                self?.nameTextField.isHidden = true
                self?.configureUnderline(opacity: 0, strokeStart: 0.5, strokeEnd: 0.5, removeAnimations: true)
                
                self?.isStopEditingInProgress = false
            } else {
                self?.isStopEditingInProgress = false
                self?.forceShowLabel()
            }
        }
        
        animateUnderline(isAppearing: false)
    }
    
    // MARK: - Animation Helper Methods
    private func animateLabelToTextField() {
        UIView.animate(withDuration: 0.3) {
            self.label.alpha = 0
            self.nameTextField.alpha = 1
        }
    }
    
    private func animateUnderline(isAppearing: Bool) {
        if isAppearing {
            createUnderlineAnimation(
                strokeStartFrom: 0.5, strokeStartTo: 0,
                strokeEndFrom: 0.5, strokeEndTo: 1,
                opacityFrom: 0, opacityTo: 1,
                timingFunction: .easeOut, keySuffix: "start"
            )
        } else {
            createUnderlineAnimation(
                strokeStartFrom: 0, strokeStartTo: 0.5,
                strokeEndFrom: 1, strokeEndTo: 0.5,
                opacityFrom: 1, opacityTo: 0,
                timingFunction: .easeIn, keySuffix: "stop"
            )
        }
    }
    
    private func configureUnderline(opacity: Float, strokeStart: CGFloat, strokeEnd: CGFloat, removeAnimations: Bool = false) {
        underlineLayer?.opacity = opacity
        underlineLayer?.strokeStart = strokeStart
        underlineLayer?.strokeEnd = strokeEnd
        if removeAnimations {
            underlineLayer?.removeAllAnimations()
        }
    }
    
    private func createUnderlineAnimation(
        strokeStartFrom: CGFloat, strokeStartTo: CGFloat,
        strokeEndFrom: CGFloat, strokeEndTo: CGFloat,
        opacityFrom: CGFloat, opacityTo: CGFloat,
        timingFunction: CAMediaTimingFunctionName, keySuffix: String
    ) {
        let animations = [
            ("strokeStart", strokeStartFrom, strokeStartTo),
            ("strokeEnd", strokeEndFrom, strokeEndTo),
            ("opacity", opacityFrom, opacityTo)
        ]
        
        animations.forEach { keyPath, fromValue, toValue in
            let animation = CABasicAnimation(keyPath: keyPath)
            animation.fromValue = fromValue
            animation.toValue = toValue
            animation.duration = 0.3
            animation.timingFunction = CAMediaTimingFunction(name: timingFunction)
            animation.fillMode = .forwards
            animation.isRemovedOnCompletion = false
            underlineLayer?.add(animation, forKey: "\(keyPath)Animation_\(keySuffix)")
        }
    }
    
    // MARK: - Lifecycle Methods
    override func prepareForReuse() {
        super.prepareForReuse()
        resetCellState()
    }
    
    private func resetCellState() {
        label.layer.removeAllAnimations()
        nameTextField.layer.removeAllAnimations()
        
        isEditingInProgress = false
        isStopEditingInProgress = false
        
        label.text = nil
        iconImageView.image = nil
        nameTextField.text = nil
        
        label.isHidden = false
        label.alpha = 1.0
        nameTextField.isHidden = true
        nameTextField.alpha = 0.0
        
        configureUnderline(opacity: 0, strokeStart: 0.5, strokeEnd: 0.5, removeAnimations: true)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupUnderlineIfNeeded()
    }
    
    private func setupUnderlineIfNeeded() {
        guard contentView.bounds.width > 0 && contentView.bounds.height > 0 &&
              label.frame.width > 0 && nameTextField.frame.height > 0 else { return }
        
        contentView.layoutIfNeeded()

        if underlineLayer == nil {
            createUnderlineLayer()
        }
        
        updateUnderlinePath()
    }
    
    private func createUnderlineLayer() {
            underlineLayer = CAShapeLayer()
            underlineLayer?.name = "nameTextFieldUnderline"
        underlineLayer?.strokeColor = UIColor.white.cgColor
        underlineLayer?.lineWidth = 1.0
        configureUnderline(opacity: 0, strokeStart: 0.5, strokeEnd: 0.5)
        contentView.layer.addSublayer(underlineLayer!)
    }
    
    private func updateUnderlinePath() {
        let underlineWidth = label.frame.width
        let underlineStartX = contentView.bounds.midX - (underlineWidth / 2)
        
        let underlineY = nameTextField.frame.maxY
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: underlineStartX, y: underlineY))
        path.addLine(to: CGPoint(x: underlineStartX + underlineWidth, y: underlineY))
        underlineLayer?.path = path.cgPath
    }
    
    // MARK: - Safety Methods
    private func forceShowLabel() {
        label.layer.removeAllAnimations()
        nameTextField.layer.removeAllAnimations()
        
        isEditingInProgress = false
        isStopEditingInProgress = false
        
        label.isHidden = false
        label.alpha = 1.0
        
        nameTextField.isHidden = true
        nameTextField.alpha = 0.0
        
        configureUnderline(opacity: 0, strokeStart: 0.5, strokeEnd: 0.5, removeAnimations: true)
    }
}

// MARK: - UITextFieldDelegate
extension CustomPlayerCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= maxNameLength
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        stopEditing()
        delegate?.playerDidFinishEditing(in: self)
        return true
    }
}

//// MARK: - SwiftUI Preview
//struct CustomPlayerCellPreviewProvider: PreviewProvider {
//    static var previews: some View {
//        CustomPlayerCellPreviewViewController()
//            .edgesIgnoringSafeArea(.all)
//            .previewLayout(.fixed(width: 400, height: 200))
//    }
//}
//
//struct CustomPlayerCellPreviewViewController: UIViewControllerRepresentable {
//    func makeUIViewController(context: Context) -> UIViewController {
//        let layout = UICollectionViewFlowLayout()
//        layout.itemSize = CGSize(width: 120, height: 160)
//        layout.scrollDirection = .vertical
//        layout.minimumLineSpacing = 16
//        layout.sectionInset = UIEdgeInsets(top: 32, left: 16, bottom: 32, right: 16)
//        
//        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        collectionView.backgroundColor = .black
//        collectionView.dataSource = context.coordinator
//        collectionView.register(CustomPlayerCell.self, forCellWithReuseIdentifier: CustomPlayerCell.identifier)
//        
//        let viewController = UIViewController()
//        viewController.view = collectionView
//        
//        return viewController
//    }
//    
//    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
//        // No dynamic updates needed for preview
//    }
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator()
//    }
//    
//    class Coordinator: NSObject, UICollectionViewDataSource {
//        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//            return 5
//        }
//        
//        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomPlayerCell.identifier, for: indexPath) as? CustomPlayerCell else {
//                fatalError("Couldn't dequeue CustomPlayerCell")
//            }
//            
//            cell.configure(
//                playerNumber: indexPath.item + 1,
//                color: .clear,
//                iconName: "civil-right-w"
//            )
//            cell.setStatus(.activeBlue)
//            
//            return cell
//        }
//    }
//}
//
//#Preview {
//    CustomPlayerCellPreviewViewController()
//}
