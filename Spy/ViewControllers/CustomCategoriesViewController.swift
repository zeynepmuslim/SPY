//
//  CustomCategoriesViewController.swift
//  Spy
//
//  Created by Zeynep Müslim on 8.04.2025.
//

import UIKit
import SwiftUI
import CoreData

class CustomCategoriesViewController: UIViewController {
    
    // MARK: - Properties
    private lazy var backButton = BackButton(target: self, action: #selector(backButtonTapped))
    private lazy var saveButton = createSaveButton()
    private let darkBottomView = CustomDarkScrollView()
    var collectionView: UICollectionView!
    let model = CustomCategoriesModel()
    
    var unwindSegueIdentifier: String?
    var playerCount: Int = 0
    var spyIndices: [Int] = []
    var isDefaultMode: Bool = false
    
    // MARK: - Public Properties
    var selectedCategory: String {
        return model.selectedCategory
    }
    
    // MARK: - Constants
    private enum Constants {
        static let bigMargin: CGFloat = GeneralConstants.Layout.bigMargin
        static let littleMargin: CGFloat = GeneralConstants.Layout.littleMargin
        static let buttonsHeight: CGFloat = GeneralConstants.Button.biggerHeight
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupModel()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateButtonText()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        let gradientView = GradientView(superView: view)
        view.insertSubview(gradientView, at: 0)
        view.addSubview(saveButton)
        view.addSubview(darkBottomView)
        view.addSubview(backButton)
        setupCollectionView()
        setupConstraints()
    }
    
    private func setupModel() {
        model.onCategoriesLoaded = { [weak self] _ in
            self?.collectionView.reloadData()
        }
    }
    
    private func loadData() {
        model.loadCategories()
        model.loadSessions()
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let spacing: CGFloat = 10
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CategoryDisplayCell.self, forCellWithReuseIdentifier: CategoryDisplayCell.identifier)
        
        darkBottomView.addSubview(collectionView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40),
            
            darkBottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.bigMargin),
            darkBottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.bigMargin),
            darkBottomView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -Constants.bigMargin),
            darkBottomView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: Constants.littleMargin),
            
            collectionView.topAnchor.constraint(equalTo: darkBottomView.topAnchor, constant: Constants.bigMargin),
            collectionView.leadingAnchor.constraint(equalTo: darkBottomView.leadingAnchor, constant: Constants.bigMargin),
            collectionView.trailingAnchor.constraint(equalTo: darkBottomView.trailingAnchor, constant: -Constants.bigMargin),
            collectionView.bottomAnchor.constraint(equalTo: darkBottomView.bottomAnchor, constant: -Constants.bigMargin),
            
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.bigMargin),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.bigMargin),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.bigMargin),
            saveButton.heightAnchor.constraint(equalToConstant: Constants.buttonsHeight),
        ])
    }
    
    // MARK: - UI Creation
    private func createSaveButton() -> CustomGradientButton {
        let buttonText = isDefaultMode ? "save_as_default".localized : "select_category".localized
        let button = CustomGradientButton(
            labelText: buttonText, 
            width: 100,
            height: Constants.buttonsHeight
        )
        button.onClick = { [weak self] in
            self?.saveAndNavigateBack()
        }
        return button
    }
    
    private func updateButtonText() {
        let buttonText = isDefaultMode ? "save_as_default".localized : "select_category".localized
        saveButton.labelText = buttonText
    }
    
    // MARK: - Actions
    @objc private func backButtonTapped() {
        saveAndNavigateBack()
    }
    
    private func saveAndNavigateBack() {
        if isDefaultMode {
            model.saveSelectedCategory()
            print("Saved category '\(model.selectedCategory)' to default settings")
        } else {
            print("Selected category '\(model.selectedCategory)' for current game session (not saving to defaults)")
        }
        
        guard let identifier = unwindSegueIdentifier else {
            print("Error: Unwind segue identifier not set.")
            return
        }
        performSegue(withIdentifier: identifier, sender: self)
    }
    
    // MARK: - Gesture Handlers
    @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        guard let indexString = gesture.accessibilityHint,
              let index = Int(indexString) else {
            print("Error: Could not determine cell index from gesture")
            return
        }
        
        let indexPath = IndexPath(item: index, section: 0)
        
        if indexPath.item < model.getCategoryCount() {
            guard let categoryEntity = model.getCategoryEntity(at: indexPath.item) else { return }
            let isCustom = !(categoryEntity.isDefault)
            
            if isCustom {
                print("Double tap detected - editing custom category at index: \(indexPath.item)")
                editCategory(at: indexPath)
            } else {
                print("Double tap detected - showing info for default category at index: \(indexPath.item)")
                showCategoryInfo(for: categoryEntity)
            }
        } else {
            print("Double tap detected - adding new category")
            performSegue(withIdentifier: "CustomCategoriesToIAddCategory", sender: nil)
        }
    }
    
    // MARK: - Helper Methods
    func editCategory(at indexPath: IndexPath) {
        guard let categoryEntity = model.getCategoryEntity(at: indexPath.item) else { return }
        performSegue(withIdentifier: "editCategorySegue", sender: categoryEntity)
    }
    
    func showCategoryInfo(for category: Category) {
        let categoryInfo = model.getCategoryInfo(for: category)
        performSegue(withIdentifier: "CustomCategoriesToInsideCategory", 
                    sender: (name: categoryInfo.name, values: categoryInfo.words))
    }
    
    func updateCategorySelection(_ selectedCategoryName: String) {
        if model.selectedCategory == selectedCategoryName { return }
        // Update previous selection visually
        if let previousSelectedIndex = model.getPreviousSelectedIndex() {
            let previousIndexPath = IndexPath(item: previousSelectedIndex, section: 0)
            if let previousCell = collectionView.cellForItem(at: previousIndexPath) as? CategoryDisplayCell {
                previousCell.setIsSelected(isSelected: false)
            }
        }
        
        // Update model (don't notify to avoid callback loop)
        model.selectCategory(selectedCategoryName, shouldNotify: false)
        
        // Find and update new selection visually
        for index in 0..<model.getCategoryCount() {
            if let displayData = model.getCategoryDisplayData(at: index),
               displayData.name == selectedCategoryName {
                let newIndexPath = IndexPath(item: index, section: 0)
                if let newCell = collectionView.cellForItem(at: newIndexPath) as? CategoryDisplayCell {
                    newCell.setIsSelected(isSelected: true)
                }
                break
            }
        }
    }
}

// MARK: - Navigation
extension CustomCategoriesViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "CustomCategoriesToInsideCategory":
            prepareForInsideCategorySegue(segue, sender: sender)
            
        case "CustomCategoriesToIAddCategory":
            prepareForAddCategorySegue(segue)
            
        case "editCategorySegue":
            prepareForEditCategorySegue(segue, sender: sender)
            
        default:
            break
        }
    }
    
    private func prepareForInsideCategorySegue(_ segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? InsideCategoryViewController,
              let data = sender as? (name: String, values: [String]) else { return }
        
        destinationVC.categoryName = data.name
        destinationVC.categoryWords = data.values
        
        destinationVC.onCategorySelected = { [weak self] selectedCategoryName in
            self?.updateCategorySelection(selectedCategoryName)
            print("Selected category: \(selectedCategoryName)")
        }
    }
    
    private func prepareForAddCategorySegue(_ segue: UIStoryboardSegue) {
        guard let destinationVC = segue.destination as? AddCategoryViewController else { return }
        
        destinationVC.onDataUpdate = { [weak self] categoryName in
            self?.model.handleCategoryUpdate(categoryName: categoryName)
        }
    }
    
    private func prepareForEditCategorySegue(_ segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? AddCategoryViewController,
              let category = sender as? Category else { return }
        
        destinationVC.categoryToEdit = category
        let originalCategoryName = category.name
        
        destinationVC.onDataUpdate = { [weak self] categoryName in
            self?.model.handleCategoryDeletion(originalCategoryName: originalCategoryName, categoryName: categoryName)
        }
    }
}

// MARK: - Preview
struct CustomCategoriesViewController_Previews: PreviewProvider {
    static var previews: some View {
        ViewControllerPreview {
            CustomCategoriesViewController()
        }
    }
}
