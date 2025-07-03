//
//  ScoresChildCollectionViewCell.swift
//  Spy
//
//  Created by Zeynep Müslim on 6.04.2025.
//

import UIKit
import SwiftUI

// MARK: - Constants
private extension ScoresChildCollectionViewCell {
    struct Layout {
        static let stackSpacing: CGFloat = 5.0
        static let iconSideLength: CGFloat = 50
        static let spyAnimationInterval: TimeInterval = 1.5
        static let civilAnimationInterval: TimeInterval = 2.2
    }
}

// MARK: - Scores Version
class ScoresChildCollectionViewCell: UICollectionViewCell {
    static let identifier = "ScoresChildCollectionViewCell"
    
    // MARK: - UI Components
    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = Layout.stackSpacing
        stack.backgroundColor = ButtonColor.blue.color
        stack.layer.cornerRadius = GeneralConstants.Button.innerCornerRadius
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.axis = .vertical
        return stack
    }()
    
    private let iconContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()
    
    private var iconWinkView: WinkAnimationView = {
        let winkView = WinkAnimationView(role: .spy, color: .white, sideLength: Layout.iconSideLength)
        winkView.translatesAutoresizingMaskIntoConstraints = false
        return winkView
    }()
    
    // MARK: - Properties
    private let padding: CGFloat = GeneralConstants.Button.borderWidth
    private var gradientAnimationBorder: AnimatedGradientView!
    private var isSpyRole: Bool = false
    private var iconConstraints: [NSLayoutConstraint] = []
    
    private var status: ButtonStatus = .activeBlue {
        didSet {
            guard oldValue != status else { return }
            animateAppearanceChange(to: status)
        }
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    private func setupViews() {
        setupGradientBorder()
        setupIconContainer()
        setupStackView()
        setupContentView()
    }
    
    private func setupGradientBorder() {
        gradientAnimationBorder = AnimatedGradientView(
            width: contentView.frame.width,
            height: contentView.frame.height,
            gradient: .blue
        )
        gradientAnimationBorder.layer.cornerRadius = GeneralConstants.Button.outerCornerRadius
        gradientAnimationBorder.clipsToBounds = true
    }
    
    private func setupIconContainer() {
        iconContainer.addSubview(iconImageView)
        iconContainer.addSubview(iconWinkView)
        setupIconConstraints()
    }
    
    private func setupIconConstraints() {
        iconConstraints = [
            iconImageView.leadingAnchor.constraint(equalTo: iconContainer.leadingAnchor),
            iconImageView.trailingAnchor.constraint(equalTo: iconContainer.trailingAnchor),
            iconImageView.topAnchor.constraint(equalTo: iconContainer.topAnchor),
            iconImageView.bottomAnchor.constraint(equalTo: iconContainer.bottomAnchor),
            
            iconWinkView.leadingAnchor.constraint(equalTo: iconContainer.leadingAnchor),
            iconWinkView.trailingAnchor.constraint(equalTo: iconContainer.trailingAnchor),
            iconWinkView.topAnchor.constraint(equalTo: iconContainer.topAnchor),
            iconWinkView.bottomAnchor.constraint(equalTo: iconContainer.bottomAnchor)
        ]
        NSLayoutConstraint.activate(iconConstraints)
    }
    
    private func setupStackView() {
        stackView.addArrangedSubview(iconContainer)
        stackView.addArrangedSubview(label)
    }
    
    private func setupContentView() {
        contentView.addSubview(gradientAnimationBorder)
        contentView.addSubview(stackView)
        
        contentView.layer.shadowColor = ShadowColor.blue.cgColor
        contentView.layer.shadowOpacity = GeneralConstants.Button.shadowOpacity
        contentView.layer.shadowOffset = CGSize(width: 0, height: 1)
        contentView.layer.shadowRadius = 5
        contentView.layer.masksToBounds = false
        contentView.layer.cornerRadius = GeneralConstants.Button.outerCornerRadius
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding),
            
            iconContainer.centerXAnchor.constraint(equalTo: stackView.centerXAnchor),
            
            gradientAnimationBorder.topAnchor.constraint(equalTo: contentView.topAnchor),
            gradientAnimationBorder.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            gradientAnimationBorder.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            gradientAnimationBorder.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    // MARK: - Configuration Methods
    func updateLayout(isVertical: Bool, numberOfChild: Int) {
        if isVertical {
            configureVerticalLayout(numberOfChild: numberOfChild)
        } else {
            configureHorizontalLayout()
        }
    }
    
    private func configureVerticalLayout(numberOfChild: Int) {
        let iconMultiplierH = numberOfChild == 4 ? 0.6 : 0.7
        let iconMultiplierW = numberOfChild == 4 ? 0.8 : 0.5
        
        if numberOfChild == 4 {
            iconContainer.widthAnchor.constraint(equalTo: stackView.heightAnchor, multiplier: iconMultiplierW).isActive = true
        } else {
            iconContainer.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.8).isActive = true
        }
        
        iconContainer.heightAnchor.constraint(equalTo: stackView.heightAnchor, multiplier: iconMultiplierH).isActive = true
        
        let labelMultiplier = numberOfChild == 4 ? 0.4 : 0.3
        label.heightAnchor.constraint(equalTo: stackView.heightAnchor, multiplier: labelMultiplier).isActive = true
    }
    
    private func configureHorizontalLayout() {
        iconContainer.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.7).isActive = true
        iconContainer.heightAnchor.constraint(equalTo: stackView.heightAnchor, multiplier: 0.6).isActive = true
        
        label.heightAnchor.constraint(equalTo: stackView.heightAnchor, multiplier: 0.4).isActive = true
        label.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.8).isActive = true
        label.centerXAnchor.constraint(equalTo: stackView.centerXAnchor).isActive = true
        
    }
    
    func configure(id: Int, color: UIColor, isSpy: Bool) {
        label.text = String(format: "player_x".localized, id)
        contentView.backgroundColor = color
        isSpyRole = isSpy
        updateIconDisplay(isSpy: isSpy, status: status)
    }
    
    private func updateIconDisplay(isSpy: Bool, status: ButtonStatus) {
        if status == .deactive {
            showStaticIcon(isSpy: isSpy)
        } else {
            showAnimatedIcon(isSpy: isSpy)
        }
    }
    
    private func showStaticIcon(isSpy: Bool) {
        iconImageView.isHidden = false
        iconWinkView.isHidden = true
        iconWinkView.stopAnimation()
        
        let imageName = isSpy ? "spy-wink-w" : "civil-wink-w"
        iconImageView.image = UIImage(named: imageName)
    }
    
    private func showAnimatedIcon(isSpy: Bool) {
        iconImageView.isHidden = true
        iconWinkView.isHidden = false
        
        recreateWinkView(isSpy: isSpy)
        configureWinkAnimation(isSpy: isSpy)
    }
    
    private func recreateWinkView(isSpy: Bool) {
        iconWinkView.removeFromSuperview()
        
        let role: WinkAnimationView.Role = isSpy ? .spy : .civil
        iconWinkView = WinkAnimationView(role: role, color: .white, sideLength: Layout.iconSideLength)
        iconWinkView.translatesAutoresizingMaskIntoConstraints = false
        iconWinkView.isHidden = false
        
        iconContainer.addSubview(iconWinkView)
        setupIconConstraints()
    }
    
    private func configureWinkAnimation(isSpy: Bool) {
        let interval = isSpy ? Layout.spyAnimationInterval : Layout.civilAnimationInterval
        iconWinkView.setAnimationInterval(interval)
    }
    
    // MARK: - Status Management
    func setStatus(_ newStatus: ButtonStatus) {
        let oldStatus = status
        status = newStatus
        
        if oldStatus != newStatus {
            updateIconDisplay(isSpy: isSpyRole, status: newStatus)
        }
    }
    
    func getStatus() -> ButtonStatus {
        return status
    }
    
    // MARK: - Animations
    private func animateAppearanceChange(to newStatus: ButtonStatus) {
        animateStatusTransition(to: newStatus)
    }
    
    private func animateStatusTransition(to newStatus: ButtonStatus) {
        let totalDuration = GeneralConstants.Animation.duration
        let shadowColor = newStatus.shadowColor
        let gradientColor = newStatus.gradientColor
        let buttonColor = newStatus.buttonColor
        
        UIView.animateKeyframes(withDuration: totalDuration, delay: 0, options: [.allowUserInteraction]) {
            self.animateToCompressedState(shadowColor: shadowColor, gradientColor: gradientColor, buttonColor: buttonColor)
            self.animateToNormalState()
        }
    }
    
    private func animateToCompressedState(shadowColor: ShadowColor, gradientColor: GradientColor, buttonColor: ButtonColor) {
        UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5) {
            self.contentView.layer.shadowColor = shadowColor.cgColor
            self.gradientAnimationBorder.updateGradient(to: gradientColor)
            self.stackView.backgroundColor = buttonColor.color
            self.stackView.layer.cornerRadius = GeneralConstants.Button.outerCornerRadius
            self.stackView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
    
    private func animateToNormalState() {
        UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
            self.stackView.transform = .identity
            self.stackView.layer.cornerRadius = GeneralConstants.Button.innerCornerRadius
        }
    }
    
    // MARK: - Cleanup
    override func prepareForReuse() {
        super.prepareForReuse()
        resetCell()
    }
    
    private func resetCell() {
        label.text = nil
        contentView.backgroundColor = .clear
        iconImageView.image = nil
        iconWinkView.stopAnimation()
    }
}

// MARK: - Preview Provider
//struct ScoresChildCollectionViewCell_Previews: PreviewProvider {
//    static var previews: some View {
//        let viewController = UIViewController()
//        let cell = ScoresChildCollectionViewCell(frame: CGRect(x: 0, y: 0, width: 120, height: 120))
//        cell.configure(id: 1, color: .clear, isSpy: true)
//        cell.updateLayout(isVertical: true, numberOfChild: 6)
//        viewController.view.addSubview(cell)
//        return ViewControllerPreview {
//            viewController
//        }
//    }
//}
