import UIKit
import SwiftUI

class CategoryDisplayCell: UICollectionViewCell {
    
    static let identifier = "CategoryDisplayCell"
    
    // MARK: - UI Elements
    private lazy var gradientAnimationBorder: AnimatedGradientView = {
        let gradient = AnimatedGradientView(width: 0, height: 0, gradient: gradientColor)
        gradient.translatesAutoresizingMaskIntoConstraints = false
        gradient.layer.cornerRadius = GeneralConstants.Button.outerCornerRadius
        gradient.clipsToBounds = true
        return gradient
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 5.0
        stack.backgroundColor = ButtonColor.blue.color
        stack.layer.cornerRadius = GeneralConstants.Button.innerCornerRadius
        stack.clipsToBounds = true
        return stack
    }()
    
    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return imageView
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        // Allow label to shrink but resist expansion vertically
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    private let spacerView1 = UIView()
    private let spacerView2 = UIView()
    
    private let editButton = UIButton(type: .system)
    private let infoButton = UIButton(type: .system)
    
    // MARK: - Properties
    private let padding: CGFloat = GeneralConstants.Button.borderWidth
    private var gradientColor: GradientColor = .blue
    private var shadowColor: ShadowColor = .blue
    
    // MARK: - Constraints
    private var stackViewTopConstraint: NSLayoutConstraint!
    private var stackViewBottomConstraint: NSLayoutConstraint!
    private var stackViewLeadingConstraint: NSLayoutConstraint!
    private var stackViewTrailingConstraint: NSLayoutConstraint!
    
    // MARK: - Closures
    var onEditButtonTapped: (() -> Void)?
    var onInfoButtonTapped: (() -> Void)?
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        setupConstraints()
        setupShadow()
        setupButtons()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    private func setupViews() {
        stackView.addArrangedSubview(spacerView1)
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(spacerView2)
        
        contentView.addSubview(gradientAnimationBorder)
        contentView.addSubview(stackView)
        contentView.addSubview(editButton)
        contentView.addSubview(infoButton)
    }
    
    private func setupConstraints() {
        stackViewLeadingConstraint = stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding)
        stackViewTrailingConstraint = stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding)
        stackViewTopConstraint = stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding)
        stackViewBottomConstraint = stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        
        NSLayoutConstraint.activate([
            gradientAnimationBorder.topAnchor.constraint(equalTo: contentView.topAnchor),
            gradientAnimationBorder.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            gradientAnimationBorder.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            gradientAnimationBorder.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            stackViewLeadingConstraint,
            stackViewTrailingConstraint,
            stackViewTopConstraint,
            stackViewBottomConstraint,
            
            iconImageView.heightAnchor.constraint(equalTo: stackView.heightAnchor, multiplier: 0.5),
            label.heightAnchor.constraint(equalTo: stackView.heightAnchor, multiplier: 0.25),
            spacerView1.heightAnchor.constraint(equalTo: stackView.heightAnchor, multiplier: 0.1),
            spacerView2.heightAnchor.constraint(equalTo: stackView.heightAnchor, multiplier: 0.15),
            
            iconImageView.widthAnchor.constraint(equalTo: iconImageView.heightAnchor, multiplier: 0.5),
            iconImageView.centerXAnchor.constraint(equalTo: stackView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: stackView.centerYAnchor, constant: -8),
            
            label.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 5),
            label.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 5),
            label.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -5),
            label.bottomAnchor.constraint(lessThanOrEqualTo: stackView.bottomAnchor, constant: -5),
            
            editButton.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 4),
            editButton.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -4),
            editButton.widthAnchor.constraint(equalToConstant: 25),
            editButton.heightAnchor.constraint(equalTo: editButton.widthAnchor),
            
            infoButton.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 4),
            infoButton.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -4),
            infoButton.widthAnchor.constraint(equalToConstant: 25),
            infoButton.heightAnchor.constraint(equalTo: infoButton.widthAnchor)
        ])
    }
    
    private func setupShadow() {
        contentView.layer.shadowColor = self.shadowColor.cgColor
        contentView.layer.shadowOpacity = GeneralConstants.Button.shadowOpacity
        contentView.layer.shadowOffset = CGSize(width: 0, height: 1)
        contentView.layer.shadowRadius = 5
        contentView.layer.cornerRadius = GeneralConstants.Button.outerCornerRadius
        contentView.layer.masksToBounds = false
    }
    
    private func setupButtons() {
        let pencilImage = UIImage(systemName: "square.and.pencil")
        editButton.setImage(pencilImage, for: .normal)
        editButton.tintColor = .white
        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.addTarget(self, action: #selector(editButtonAction), for: .touchUpInside)
        editButton.isHidden = true
        
        let infoImage = UIImage(systemName: "info.square")
        infoButton.setImage(infoImage, for: .normal)
        infoButton.tintColor = .white
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        infoButton.addTarget(self, action: #selector(infoButtonAction), for: .touchUpInside)
        infoButton.isHidden = true
    }
    
    // MARK: - Actions
    @objc private func editButtonAction() {
        onEditButtonTapped?()
    }
    
    @objc private func infoButtonAction() {
        onInfoButtonTapped?()
    }
    
    // MARK: - Configuration Methods
    func configure(categoryName: String, icon: UIImage?, isCustom: Bool = false) {
        label.text = categoryName.localized
        iconImageView.image = icon
        
        if isCustom {
            editButton.isHidden = false
            infoButton.isHidden = true
        } else if categoryName != "new".localized {
            editButton.isHidden = true
            infoButton.isHidden = false
        } else {
            editButton.isHidden = true
            infoButton.isHidden = true
        }
    }
    
    func setIsSelected(isSelected: Bool) {
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut, .allowUserInteraction], animations: {
            if isSelected {
                self.stackView.backgroundColor = .clear
                self.iconImageView.tintColor = .black
                self.label.textColor = .black
                self.editButton.tintColor = .black
                self.infoButton.tintColor = .black
            } else {
                self.stackView.backgroundColor = ButtonColor.blue.color
                self.iconImageView.tintColor = .white
                self.label.textColor = .white
                self.editButton.tintColor = .white
                self.infoButton.tintColor = .white
            }
        }, completion: nil)
    }
    
    // MARK: - Animation Methods
    private func animatePadding(to constant: CGFloat, duration: TimeInterval, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
            self.stackViewTopConstraint.constant = constant
            self.stackViewBottomConstraint.constant = -constant
            self.stackViewLeadingConstraint.constant = constant
            self.stackViewTrailingConstraint.constant = -constant
            self.stackView.layer.cornerRadius = (constant == 0) ? GeneralConstants.Button.outerCornerRadius : GeneralConstants.Button.innerCornerRadius
            self.contentView.layoutIfNeeded()
        }) { _ in
            completion?()
        }
    }
    
    // MARK: - Lifecycle Methods
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
        iconImageView.image = nil
        onEditButtonTapped = nil
        onInfoButtonTapped = nil
        configure(categoryName: "", icon: nil, isCustom: false)
    }
}

//// MARK: - SwiftUI Preview
//struct CategoryDisplayCellPreviewProvider: PreviewProvider {
//    static var previews: some View {
//        CategoryDisplayCellPreviewViewController()
//            .edgesIgnoringSafeArea(.all)
//            .previewLayout(.fixed(width: 400, height: 300))
//    }
//}
//
//struct CategoryDisplayCellPreviewViewController: UIViewControllerRepresentable {
//    func makeUIViewController(context: Context) -> UIViewController {
//        let layout = UICollectionViewFlowLayout()
//        layout.itemSize = CGSize(width: 120, height: 160)
//        layout.scrollDirection = .vertical
//        layout.minimumInteritemSpacing = 10
//        layout.minimumLineSpacing = 20
//        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
//        
//        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        collectionView.backgroundColor = .darkGray
//        collectionView.dataSource = context.coordinator
//        collectionView.register(CategoryDisplayCell.self, forCellWithReuseIdentifier: CategoryDisplayCell.identifier)
//        
//        let viewController = UIViewController()
//        viewController.view = collectionView
//        return viewController
//    }
//    
//    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator()
//    }
//    
//    class Coordinator: NSObject, UICollectionViewDataSource {
//        let categories: [(name: String, icon: String)] = [
//            ("basic", "category-icon-1"), ("travel", "category-icon-2"), ("food", "category-icon-3"),
//            ("history", "category-icon-4"), ("places", "category-icon-5"), ("sports", "category-icon-6")
//        ]
//        
//        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//            categories.count
//        }
//        
//        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryDisplayCell.identifier, for: indexPath) as? CategoryDisplayCell else {
//                fatalError("Couldn't dequeue CategoryDisplayCell")
//            }
//            let category = categories[indexPath.item]
//            let iconImage = UIImage(systemName: category.icon)
//            cell.configure(
//                categoryName: category.name,
//                icon: iconImage,
//            )
//            cell.setIsSelected(isSelected: true)
//            return cell
//        }
//    }
//}
//
//#Preview {
//    CategoryDisplayCellPreviewViewController()
//}
