//
//  ChildCollectionViewCell.swift
//  Spy
//
//  Created by Zeynep Müslim on 6.04.2025.
//

import UIKit
import SwiftUI

// MARK: - ChildCollectionViewCell Class

class ChildCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let identifier = "ChildCollectionViewCell"
    
    var gradientColor: GradientColor
    var buttonColor: ButtonColor
    var shadowColor: ShadowColor
    
    private var isSpy = false
    private var currentVisualState = false
    
    private var status: ButtonStatus = .activeBlue {
        didSet {
            guard oldValue != status else { return }
            animateAppearanceChange(to: status)
        }
    }
    
    // MARK: - UI Elements
    
    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let spacerView1 = UIView()
    private let spacerView2 = UIView()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 5.0
        stack.backgroundColor = ButtonColor.blue.color
        stack.layer.cornerRadius = GeneralConstants.Button.innerCornerRadius
        stack.alignment = .center
        return stack
    }()
    
    private let iconContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private var gradientAnimationBorder: AnimatedGradientView!
    
    // MARK: - Shape Layers
    
    private let shapeLayerHat = CAShapeLayer()
    private let shapeLayerRightEye = CAShapeLayer()
    private let shapeLayerLeftEye = CAShapeLayer()
    
    // MARK: - Morph Manager
    
    private lazy var morphManager = MorphManager(
        layers: MorphManager.MorphLayers(
            hat: shapeLayerHat,
            rightEye: shapeLayerRightEye,
            leftEye: shapeLayerLeftEye
        ),
        iconContainer: iconContainer
    )
    
    // MARK: - Constraints
    
    private var stackViewTopConstraint: NSLayoutConstraint!
    private var stackViewBottomConstraint: NSLayoutConstraint!
    private var stackViewLeadingConstraint: NSLayoutConstraint!
    private var stackViewTrailingConstraint: NSLayoutConstraint!
    
    // Dynamic layout constraints
    private var iconContainerWidthConstraint: NSLayoutConstraint?
    private var labelHeightConstraint: NSLayoutConstraint?
    
    // MARK: - Constants
    
    private let padding: CGFloat = GeneralConstants.Button.borderWidth
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        self.gradientColor = GradientColor.blue
        self.buttonColor = ButtonColor.blue
        self.shadowColor = ShadowColor.blue
        
        super.init(frame: frame)
        
        setupUI()
        setupConstraints()
        setupShadow()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        gradientAnimationBorder = AnimatedGradientView(
            width: contentView.frame.width * 1,
            height: contentView.frame.height * 1,
            gradient: gradientColor
        )
        gradientAnimationBorder.layer.cornerRadius = GeneralConstants.Button.outerCornerRadius
        gradientAnimationBorder.clipsToBounds = true
        
        [shapeLayerHat, shapeLayerRightEye, shapeLayerLeftEye].forEach { layer in
            layer.fillColor = UIColor.white.cgColor
            iconContainer.layer.addSublayer(layer)
        }
        
        stackView.addArrangedSubview(spacerView1)
        stackView.addArrangedSubview(iconContainer)
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(spacerView2)
        
        contentView.addSubview(gradientAnimationBorder)
        contentView.addSubview(stackView)
        
        contentView.layer.cornerRadius = GeneralConstants.Button.outerCornerRadius
    }
    
    private func setupShadow() {
        contentView.layer.shadowColor = self.shadowColor.cgColor
        contentView.layer.shadowOpacity = GeneralConstants.Button.shadowOpacity
        contentView.layer.shadowOffset = CGSize(width: 0, height: 1)
        contentView.layer.shadowRadius = 5
        contentView.layer.masksToBounds = false
    }
    
    private func setupConstraints() {
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
            
            iconContainer.widthAnchor.constraint(equalTo: iconContainer.heightAnchor),
        ])
    }
    
    // MARK: - Layout Methods
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layoutIfNeeded()
        applyPathTransform()
    }
    
    func updateLayout(isVertical: Bool, numberOfChild: Int) {
        deactivateDynamicConstraints()
        
        stackView.axis = isVertical ? .vertical : .horizontal
        
        if isVertical {
            setupVerticalLayout(numberOfChild: numberOfChild)
        } else {
            setupHorizontalLayout()
        }
        
        activateDynamicConstraints()
    }
    
    private func deactivateDynamicConstraints() {
        iconContainerWidthConstraint?.isActive = false
        labelHeightConstraint?.isActive = false
    }
    
    private func activateDynamicConstraints() {
        iconContainerWidthConstraint?.isActive = true
        labelHeightConstraint?.isActive = true
    }
    
    private func setupVerticalLayout(numberOfChild: Int) {
        let widthMultiplier = (numberOfChild == 4) ? 0.5 : 0.8
        
        iconContainerWidthConstraint = iconContainer.widthAnchor.constraint(
            equalTo: stackView.widthAnchor,
            multiplier: widthMultiplier
        )
        
        labelHeightConstraint = label.heightAnchor.constraint(
            equalTo: stackView.heightAnchor,
            multiplier: 0.2
        )
        
        stackView.distribution = .equalSpacing
    }
    
    private func setupHorizontalLayout() {
        iconContainerWidthConstraint = iconContainer.widthAnchor.constraint(
            equalTo: stackView.heightAnchor,
            multiplier: 1.0
        )
        
        labelHeightConstraint = nil
        
        stackView.distribution = .equalSpacing
    }
    
    // MARK: - Configuration Methods
    
    func configure(player: String, color: UIColor, iconName: String) {
        label.text = player
        contentView.backgroundColor = color
        setNeedsLayout()
    }
    
    func configure(with player: Player) {
        label.text = player.name
        isSpy = player.isSpy
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        label.text = nil
        contentView.backgroundColor = .clear
        
        morphManager.stopAnimations()
        cleanupDynamicConstraints()
        
        stackView.axis = .vertical
        stackView.distribution = .fill
        
        isSpy = false
        currentVisualState = false
    }
    
    private func cleanupDynamicConstraints() {
        iconContainerWidthConstraint?.isActive = false
        iconContainerWidthConstraint = nil
        
        labelHeightConstraint?.isActive = false
        labelHeightConstraint = nil
    }
    
    // MARK: - Status Management
    func setStatus(_ newStatus: ButtonStatus) {
        status = newStatus
    }
    
    func getStatus() -> ButtonStatus {
        return status
    }
    
    func setRole(isSpy: Bool) {
        print(" SET ROLE called: isSpy = \(isSpy)")
        print("   Before: isSpy = \(self.isSpy), currentVisualState = \(self.currentVisualState)")
        self.isSpy = isSpy
        print("   After: isSpy = \(self.isSpy), currentVisualState = \(self.currentVisualState) (visual unchanged)")
        setNeedsLayout() // This will trigger layoutSubviews which will apply the path transform
    }
    
    // MARK: - Morph Control Methods
    
    func morphTo(isSpy: Bool, type: MorphManager.MorphType = .switchRole) {
        if type == .revealTrueRole {
            self.isSpy = isSpy
            morphManager.morphFrom(currentVisualState, to: isSpy, type: type)
            self.currentVisualState = isSpy
        } else {
            morphManager.morphFrom(currentVisualState, to: isSpy, type: type)
            self.currentVisualState = isSpy
        }
    }
    
    func updateMorphConfiguration(_ configuration: MorphManager.MorphConfiguration) {
        morphManager.updateConfiguration(configuration)
    }
    
    func stopMorphAnimations() {
        morphManager.stopAnimations()
    }
    
    func updateIconPaths() {
        morphManager.applyStaticPaths(for: currentVisualState)
    }
    
    // MARK: - Animation Methods
    
    private func animateAppearanceChange(to newStatus: ButtonStatus) {
        let totalDuration = GeneralConstants.Animation.duration
        let shadowColor = newStatus.shadowColor
        let gradientColor = newStatus.gradientColor
        let buttonColor = newStatus.buttonColor
        
        let shouldShowAsSpy = (newStatus == .activeRed)
        
        #if DEBUG
        print("🔍 CIVILIAN DEBUG:")
        print("   Status: \(newStatus)")
        print("   True Role (isSpy): \(isSpy)")
        print("   Current Visual: \(currentVisualState)")
        print("   Should Show As Spy: \(shouldShowAsSpy)")
        #endif
        
        if newStatus == .deactive {
            if isSpy {
                print("   → Path: SPY deactivation")
                if currentVisualState != true {
                    print("   → SPY: Morphing from \(currentVisualState) to spy")
                    let oldVisualState = currentVisualState
                    currentVisualState = true
                    morphManager.morphFrom(oldVisualState, to: true, type: .revealTrueRole)
                } else {
                    print("   → SPY: Already spy, no change")
                }
            } else {
                print("   → Path: CIVILIAN deactivation")
                if currentVisualState != false {
                    print("   → CIVILIAN: Morphing from \(currentVisualState) to civilian")
                    let oldVisualState = currentVisualState
                    currentVisualState = false
                    morphManager.morphFrom(oldVisualState, to: false, type: .revealTrueRole)
                } else {
                    print("   → CIVILIAN: Already civilian, no change")
                }
            }
        } else {
            print("   → ACTIVE state change")
            if currentVisualState != shouldShowAsSpy {
                print("   → ACTIVE: Morphing from \(currentVisualState) to \(shouldShowAsSpy)")
                let oldVisualState = currentVisualState
                currentVisualState = shouldShowAsSpy
                morphManager.morphFrom(oldVisualState, to: shouldShowAsSpy, type: .switchRole)
                print("   → State updated: currentVisualState = \(currentVisualState)")
            } else {
                print("   → ACTIVE: Already correct, no change")
            }
        }
        
        animateVisualAppearance(
            shadowColor: shadowColor,
            gradientColor: gradientColor,
            buttonColor: buttonColor,
            duration: totalDuration
        )
    }
    
    private func animateVisualAppearance(shadowColor: ShadowColor, gradientColor: GradientColor, buttonColor: ButtonColor, duration: TimeInterval) {
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: [.allowUserInteraction], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5) {
                self.shadowColor = shadowColor
                self.contentView.layer.shadowColor = shadowColor.cgColor
                self.gradientAnimationBorder.updateGradient(to: gradientColor)
                self.stackView.backgroundColor = buttonColor.color
                self.stackView.layer.cornerRadius = GeneralConstants.Button.outerCornerRadius
                
                self.stackViewTopConstraint.constant = 0
                self.stackViewBottomConstraint.constant = 0
                self.stackViewLeadingConstraint.constant = 0
                self.stackViewTrailingConstraint.constant = 0
                self.contentView.layoutIfNeeded()
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                self.stackViewTopConstraint.constant = self.padding
                self.stackViewBottomConstraint.constant = -self.padding
                self.stackViewLeadingConstraint.constant = self.padding
                self.stackViewTrailingConstraint.constant = -self.padding
                self.stackView.layer.cornerRadius = GeneralConstants.Button.innerCornerRadius
                self.contentView.layoutIfNeeded()
            }
        }, completion: nil)
    }
    
    // MARK: - Path Transformation Methods
    
    private func applyPathTransform() {
        morphManager.applyStaticPaths(for: currentVisualState)
    }
}
