//
//  InsideCategoryViewController.swift
//  Spy
//
//  Created by Zeynep Müslim on 8.04.2025.
//

import UIKit
import SwiftUI

class InsideCategoryViewController: UIViewController {
    
    // MARK: - Properties
    var categoryName: String = "basic"
    var categoryWords: [String] = [
        "book", "pen", "table", "chair", "glass", "plate", "fork", "knife", "spoon", "phone",
        "computer", "glasses", "watch", "key", "wallet", "umbrella", "television", "lamp", "mirror", "door"
    ]
    var onCategorySelected: ((String) -> Void)?
    
    // MARK: - UI Components
    private lazy var selectCategoryButton = createSelectButton()
    private let darkBottomView = CustomDarkScrollView()
    
    private let categoryNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let wordsTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.backgroundColor = .clear
        textView.textColor = .white
        textView.layer.cornerRadius = 8
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return textView
    }()
    
    // MARK: - Constants
    private enum Constants {
        static let bigMargin: CGFloat = GeneralConstants.Layout.bigMargin
        static let littleMargin: CGFloat = GeneralConstants.Layout.littleMargin
        static let buttonsHeight: CGFloat = GeneralConstants.Button.biggerHeight
        static let fontSize: CGFloat = 18
        static let lineSpacing: CGFloat = 8
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureContent()
        setupConstraints()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        let gradientView = GradientView(superView: view)
        view.insertSubview(gradientView, at: 0)
        view.addSubview(selectCategoryButton)
        view.addSubview(darkBottomView)
        view.addSubview(categoryNameLabel)
        darkBottomView.addSubview(wordsTextView)
    }
    
    private func configureContent() {
        categoryNameLabel.text = categoryName.localized
        setupWordsTextView()
    }
    
    private func setupWordsTextView() {
        let localizedWords = categoryWords.map { $0.localized }
        let fullText = localizedWords.joined(separator: "\n")
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = Constants.lineSpacing
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: Constants.fontSize),
            .foregroundColor: UIColor.white,
            .paragraphStyle: paragraphStyle
        ]
        
        let attributedString = NSAttributedString(string: fullText, attributes: attributes)
        wordsTextView.attributedText = attributedString
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            categoryNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: Constants.bigMargin),
            categoryNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: Constants.bigMargin),
            categoryNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -Constants.bigMargin),
            
            darkBottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: Constants.bigMargin),
            darkBottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -Constants.bigMargin),
            darkBottomView.bottomAnchor.constraint(equalTo: selectCategoryButton.topAnchor,constant: -Constants.bigMargin),
            darkBottomView.topAnchor.constraint(equalTo: categoryNameLabel.bottomAnchor,constant: Constants.bigMargin),
            
            wordsTextView.topAnchor.constraint(equalTo: darkBottomView.topAnchor,constant: Constants.littleMargin),
            wordsTextView.leadingAnchor.constraint(equalTo: darkBottomView.leadingAnchor,constant: Constants.littleMargin),
            wordsTextView.trailingAnchor.constraint(
                equalTo: darkBottomView.trailingAnchor,
                constant: -Constants.littleMargin),
            wordsTextView.bottomAnchor.constraint(equalTo: darkBottomView.bottomAnchor,constant: -Constants.littleMargin),
            
            selectCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: Constants.bigMargin),
            selectCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -Constants.bigMargin),
            selectCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,constant: -Constants.bigMargin),
            selectCategoryButton.heightAnchor.constraint(equalToConstant: Constants.buttonsHeight),
        ])
    }
    
    // MARK: - UI Creation
    private func createSelectButton() -> CustomGradientButton {
        let button = CustomGradientButton(
            labelText: "select_category".localized,
            width: 100,
            height: Constants.buttonsHeight
        )
        button.onClick = { [weak self] in
            guard let self = self else { return }
            self.onCategorySelected?(self.categoryName)
            self.dismiss(animated: true)
        }
        return button
    }
}

// MARK: - SwiftUI Preview
struct InsideCategoryViewController_Previews: PreviewProvider {
    static var previews: some View {
        ViewControllerPreview {
            InsideCategoryViewController()
        }
    }
}

