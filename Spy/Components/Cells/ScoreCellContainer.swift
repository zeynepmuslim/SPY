import UIKit
import SwiftUI

// MARK: - ScoreCellContainer
class ScoreCellContainer: UICollectionViewCell {
    
    static let identifier = "ScoreCellContainer"
    
    // MARK: - Constants
    private enum Layout {
        static let verticalSpacing: CGFloat = 4.0
        static let labelHeight: CGFloat = 20.0
    }
    
    // MARK: - UI Components
    private lazy var topLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var bottomLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var childCellWrapper: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.layer.shadowOpacity = GeneralConstants.Button.shadowOpacity
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.layer.shadowRadius = 5
        view.layer.masksToBounds = false
        view.layer.cornerRadius = GeneralConstants.Button.outerCornerRadius
        return view
    }()
    
    private lazy var childCell: ScoresChildCollectionViewCell = {
        let cell = ScoresChildCollectionViewCell(frame: .zero)
        cell.translatesAutoresizingMaskIntoConstraints = false
        cell.clipsToBounds = true
        cell.contentView.clipsToBounds = true
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
        return cell
    }()
    
    // MARK: - Gradient Properties
    private var containerGradientBorder: AnimatedGradientView!
    private var currentStatus: ButtonStatus = .activeBlue
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        configureAppearance()
        createGradientBorder()
        addSubviews()
        setupConstraints()
    }
    
    private func configureAppearance() {
        contentView.backgroundColor = .clear
        backgroundColor = .clear
    }
    
    private func createGradientBorder() {
        containerGradientBorder = AnimatedGradientView(
            width: 100,
            height: 100,
            gradient: currentStatus.gradientColor
        )
        containerGradientBorder.translatesAutoresizingMaskIntoConstraints = false
        containerGradientBorder.layer.cornerRadius = GeneralConstants.Button.outerCornerRadius
        containerGradientBorder.clipsToBounds = true
    }
    
    private func addSubviews() {
        childCellWrapper.addSubview(containerGradientBorder)
        childCellWrapper.addSubview(childCell)
        
        contentView.addSubview(topLabel)
        contentView.addSubview(childCellWrapper)
        contentView.addSubview(bottomLabel)
        
        childCellWrapper.layer.shadowColor = currentStatus.shadowColor.cgColor
    }
    
    private func setupConstraints() {
        setupLabelConstraints()
        setupWrapperConstraints()
        setupChildCellConstraints()
    }
    
    private func setupLabelConstraints() {
        NSLayoutConstraint.activate([
            topLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            topLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            topLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            topLabel.heightAnchor.constraint(equalToConstant: Layout.labelHeight),
            
            bottomLabel.topAnchor.constraint(equalTo: childCellWrapper.bottomAnchor, constant: Layout.verticalSpacing),
            bottomLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            bottomLabel.heightAnchor.constraint(equalToConstant: Layout.labelHeight)
        ])
    }
    
    private func setupWrapperConstraints() {
        NSLayoutConstraint.activate([
            childCellWrapper.topAnchor.constraint(equalTo: topLabel.bottomAnchor, constant: Layout.verticalSpacing),
            childCellWrapper.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            childCellWrapper.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            containerGradientBorder.topAnchor.constraint(equalTo: childCellWrapper.topAnchor),
            containerGradientBorder.leadingAnchor.constraint(equalTo: childCellWrapper.leadingAnchor),
            containerGradientBorder.trailingAnchor.constraint(equalTo: childCellWrapper.trailingAnchor),
            containerGradientBorder.bottomAnchor.constraint(equalTo: childCellWrapper.bottomAnchor)
        ])
    }
    
    private func setupChildCellConstraints() {
        NSLayoutConstraint.activate([
            childCell.topAnchor.constraint(equalTo: childCellWrapper.topAnchor),
            childCell.leadingAnchor.constraint(equalTo: childCellWrapper.leadingAnchor),
            childCell.trailingAnchor.constraint(equalTo: childCellWrapper.trailingAnchor),
            childCell.bottomAnchor.constraint(equalTo: childCellWrapper.bottomAnchor)
        ])
    }
    
    // MARK: - Configuration
    func configure(
        childId: Int,
        iconName: String,
        topLabelText: String,
        bottomLabelText: String,
        isVerticalLayout: Bool,
        numberOfChildren: Int,
        status: ButtonStatus,
        isSpy: Bool
    ) {
        configureLabels(topText: topLabelText, bottomText: bottomLabelText)
        configureChildCell(
            id: childId,
            isVertical: isVerticalLayout,
            numberOfChildren: numberOfChildren,
            status: status,
            isSpy: isSpy
        )
        updateAppearance(status: status, isSpy: isSpy)
    }
    
    private func configureLabels(topText: String, bottomText: String) {
        topLabel.text = topText
        bottomLabel.text = bottomText
    }
    
    private func configureChildCell(
        id: Int,
        isVertical: Bool,
        numberOfChildren: Int,
        status: ButtonStatus,
        isSpy: Bool
    ) {
        childCell.updateLayout(isVertical: isVertical, numberOfChild: numberOfChildren)
        childCell.configure(id: id, color: .clear, isSpy: isSpy)
        childCell.setStatus(status)
    }
    
    private func updateAppearance(status: ButtonStatus, isSpy: Bool) {
        updateTextColors(status: status, isSpy: isSpy)
        updateContainerAppearance(status: status)
    }
    
    private func updateTextColors(status: ButtonStatus, isSpy: Bool) {
        topLabel.textColor = switch status {
        case .deactive:
                .spyGray01
        case .activeRed, .activeBlue:
            isSpy ? .spyRed01 : .spyBlue01
        }
    }
    
    private func updateContainerAppearance(status: ButtonStatus) {
        currentStatus = status
        containerGradientBorder.updateGradient(to: status.gradientColor)
        childCellWrapper.layer.shadowColor = status.shadowColor.cgColor
    }
    
    // MARK: - Cell Lifecycle
    override func prepareForReuse() {
        super.prepareForReuse()
        topLabel.text = nil
        bottomLabel.text = nil
        childCell.prepareForReuse()
    }
}

// MARK: - SwiftUI Preview
//struct ScoreCellContainer_Previews: PreviewProvider {
//    static var previews: some View {
//        ScoreCellContainerPreview()
//            .edgesIgnoringSafeArea(.all)
//            .background(Color.black)
//    }
//}
//
//private struct ScoreCellContainerPreview: UIViewControllerRepresentable {
//    func makeUIViewController(context: Context) -> UIViewController {
//        let viewController = UIViewController()
//        let collectionView = createCollectionView(in: viewController.view)
//        collectionView.dataSource = context.coordinator
//        viewController.view.addSubview(collectionView)
//        return viewController
//    }
//    
//    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
//    
//    func makeCoordinator() -> PreviewCoordinator {
//        PreviewCoordinator()
//    }
//    
//    private func createCollectionView(in parentView: UIView) -> UICollectionView {
//        let layout = UICollectionViewFlowLayout()
//        layout.itemSize = CGSize(width: 120, height: 180)
//        layout.scrollDirection = .vertical
//        layout.minimumLineSpacing = 16
//        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
//        
//        let collectionView = UICollectionView(frame: parentView.bounds, collectionViewLayout: layout)
//        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        collectionView.backgroundColor = .clear
//        collectionView.register(ScoreCellContainer.self, forCellWithReuseIdentifier: ScoreCellContainer.identifier)
//        
//        return collectionView
//    }
//}
//
//private class PreviewCoordinator: NSObject, UICollectionViewDataSource {
//    private let numberOfItems = 6
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        numberOfItems
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(
//            withReuseIdentifier: ScoreCellContainer.identifier,
//            for: indexPath
//        ) as? ScoreCellContainer else {
//            fatalError("Couldn't dequeue ScoreCellContainer")
//        }
//        
//        configurePreviewCell(cell, at: indexPath)
//        return cell
//    }
//    
//    private func configurePreviewCell(_ cell: ScoreCellContainer, at indexPath: IndexPath) {
//        let childId = indexPath.item + 1
//        let status: ButtonStatus = (indexPath.item % 2 == 0) ? .activeBlue : .activeRed
//        let isSpy = (indexPath.item % 2 != 0)
//        
//        cell.configure(
//            childId: childId,
//            iconName: "spy-right-w",
//            topLabelText: String(format: "player_x".localized, childId),
//            bottomLabelText: "score".localized + ": \(childId * 10)",
//            isVerticalLayout: true,
//            numberOfChildren: numberOfItems,
//            status: status,
//            isSpy: isSpy
//        )
//    }
//}
