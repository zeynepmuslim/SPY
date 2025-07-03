//
//  AddCategoryViewController.swift
//  Spy
//
//  Created by Zeynep Müslim on 16.04.2025.
//
import UIKit
import SwiftUI
import CoreData

class AddCategoryViewController: UIViewController {
    
    // MARK: - Properties
    var categoryToEdit: Category?
    var onDataUpdate: ((String?) -> Void)?
    
    // MARK: - UI Components
    internal lazy var saveButton = ButtonFactory.createSaveButton { [weak self] in 
        self?.saveCategoryTapped() 
    }
    internal lazy var deleteButton = ButtonFactory.createDeleteButton { [weak self] in 
        self?.deleteButtonTapped() 
    }
    internal let darkBottomView = CustomDarkScrollView()
    internal lazy var addValueFieldButton = ButtonFactory.createAddValueButton { [weak self] in 
        self?.addValueFieldTapped() 
    }
    private let titleTextField = UITextField()
    private var valueTextFields: [UITextField] = []
    internal let stackView = UIStackView()
    
    // MARK: - Managers
    private var keyboardManager: KeyboardManager?
    
    // MARK: - Constraints
    internal var saveButtonLeadingConstraintWithDelete: NSLayoutConstraint!
    internal var saveButtonLeadingConstraintWithoutDelete: NSLayoutConstraint!
    
    // MARK: - Constants
    internal enum Constants {
        static let bigMargin: CGFloat = GeneralConstants.Layout.bigMargin
        static let littleMargin: CGFloat = GeneralConstants.Layout.littleMargin
        static let buttonsHeight: CGFloat = GeneralConstants.Button.biggerHeight
        static let defaultBottomInset: CGFloat = 90
    }
    
    internal var scrollView: UIScrollView { darkBottomView.scrollView }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        configureForEditing()
        setupKeyboardDismissal()
        setupScrollViewInsets()
        setupKeyboardManager()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardManager?.registerKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardManager?.unregisterKeyboardNotifications()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        let gradientView = GradientView(superView: view)
        view.insertSubview(gradientView, at: 0)
        
        view.addSubview(saveButton)
        view.addSubview(darkBottomView)
        view.addSubview(deleteButton)
        
        setupTextFields()
        setupStackView()
        setupScrollView()
    }
    
    private func setupTextFields() {
        configureTitleTextField()
        createInitialValueTextFields()
        updateReturnKeyTypes()
    }
    
    private func configureTitleTextField() {
        titleTextField.attributedPlaceholder = NSAttributedString(
            string: "category_title".localized,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.spyBlue01G.withAlphaComponent(0.5)]
        )
        styleTextField(titleTextField)
    }
    
    private func createInitialValueTextFields() {
        valueTextFields.removeAll()
        for i in 1...5 {
            let textField = TextFieldFactory.createValueTextField(
                placeholder: "value".localized + String(i), 
                isDefault: true, 
                removeAction: #selector(removeValueFieldTapped(_:)), 
                target: self
            )
            textField.delegate = self
            valueTextFields.append(textField)
        }
    }
    
    private func setupStackView() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        stackView.axis = .vertical
        stackView.spacing = Constants.littleMargin
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(titleTextField)
        valueTextFields.forEach { stackView.addArrangedSubview($0) }
    }
    
    private func setupScrollView() {
        scrollView.addSubview(stackView)
        darkBottomView.addSubview(addValueFieldButton)
    }
    
    private func setupScrollViewInsets() {
        scrollView.contentInset.bottom = Constants.defaultBottomInset
        scrollView.verticalScrollIndicatorInsets.bottom = Constants.defaultBottomInset
    }
    
    private func setupKeyboardManager() {
        keyboardManager = KeyboardManager(
            viewController: self, 
            scrollView: scrollView, 
            addButton: addValueFieldButton,
            containerView: darkBottomView
        )
    }
    
    // MARK: - TextField Styling (Local Method)
    private func styleTextField(_ textField: UITextField) {
        textField.backgroundColor = .clear
        textField.textAlignment = .center
        textField.font = UIFont.boldSystemFont(ofSize: 16)
        textField.tintColor = .white
        textField.textColor = .white
        textField.borderStyle = .roundedRect
        textField.layer.borderColor = UIColor.spyBlue02.cgColor
        textField.layer.borderWidth = 1.0
        textField.layer.cornerRadius = 5.0
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
    }
    

    
    // MARK: - Configuration 
    private func configureForEditing() {
        if let category = categoryToEdit {
            configureEditMode(for: category)
        } else {
            configureAddMode()
        }
    }
    
    private func configureEditMode(for category: Category) {
        guard let categoryName = category.name else { return }
        
        title = String(format: "edit_category_title".localized, categoryName)
        titleTextField.text = categoryName
        saveButton.labelText = "save_changes".localized
        
        setupEditingTextFields(for: category)
        showDeleteButton()
    }
    
    private func configureAddMode() {
        title = "add_new_category".localized
        saveButton.labelText = "save_category".localized
        hideDeleteButton()
    }
    
    private func setupEditingTextFields(for category: Category) {
        valueTextFields.forEach { $0.removeFromSuperview() }
        valueTextFields.removeAll()
        
        let initialValues = category.words?.allObjects.compactMap { ($0 as? Word)?.text } ?? []
        
        for (index, value) in initialValues.enumerated() {
            let isDefault = index < 5
            let textField = TextFieldFactory.createValueTextField(
                placeholder: "value".localized + String(index + 1),
                isDefault: isDefault,
                removeAction: #selector(removeValueFieldTapped(_:)),
                target: self
            )
            textField.text = value
            textField.delegate = self
            valueTextFields.append(textField)
            stackView.addArrangedSubview(textField)
        }
        
        updateReturnKeyTypes()
    }
    
    private func showDeleteButton() {
        deleteButton.isHidden = false
        showDeleteButtonConstraints()
    }
    
    private func hideDeleteButton() {
        deleteButton.isHidden = true
        hideDeleteButtonConstraints()
    }
    
    // MARK: - Actions
    @objc private func addValueFieldTapped() {
        let newValueIndex = valueTextFields.count + 1
        let textField = TextFieldFactory.createValueTextField(
            placeholder: "value".localized + String(newValueIndex),
            isDefault: false,
            removeAction: #selector(removeValueFieldTapped(_:)),
            target: self
        )
        textField.delegate = self
        
        valueTextFields.append(textField)
        stackView.addArrangedSubview(textField)
        updateReturnKeyTypes()
        
        AddCategoryAnimationHelper.animateTextFieldAddition(textField) { [weak self] in
            self?.focusNewTextField(textField)
        }
    }
    
    private func focusNewTextField(_ textField: UITextField) {
        if valueTextFields.contains(where: { $0.isFirstResponder }) {
            textField.becomeFirstResponder()
            keyboardManager?.scrollToTextField(textField)
        }
    }
    
    @objc private func removeValueFieldTapped(_ sender: UIButton) {
        guard let index = valueTextFields.firstIndex(where: {
            $0.rightView === sender || $0.rightView?.subviews.contains(sender) == true
        }) else { return }
        
        let textField = valueTextFields[index]
        
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
        
        AddCategoryAnimationHelper.animateTextFieldRemoval(textField) { [weak self] in
            self?.stackView.removeArrangedSubview(textField)
            textField.removeFromSuperview()
            self?.valueTextFields.remove(at: index)
            self?.updateReturnKeyTypes()
        }
    }
    
    // MARK: - Save & Delete
    @objc private func saveCategoryTapped() {
        let title = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let values = valueTextFields.compactMap {
            $0.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        }.filter { !$0.isEmpty }
        
        let validationResult = ValidationManager.validateCategoryInput(title: title, values: values)
        
        switch validationResult {
        case .success(let (validTitle, validValues)):
            guard !ValidationManager.isDuplicateCategory(title: validTitle, excludingCategory: categoryToEdit) else {
                UIHelper.showAlert(on: self, message: "name_is_already_in_usage_pick_another".localized)
                return
            }
            
            saveCategory(title: validTitle, values: validValues)
            
        case .failure(let message):
            UIHelper.showAlert(on: self, message: message)
        }
    }
    
    private func saveCategory(title: String, values: [String]) {
        if let category = categoryToEdit {
            print("Saving Changes...")
            CategoryManager.shared.updateCategory(category, newName: title, newIcon: "seal", newWords: values)
            onDataUpdate?(title)
        } else {
            print("Saving Category...")
            CategoryManager.shared.addCategory(name: title, icon: "seal", words: values)
            onDataUpdate?(title)
        }
        
        print("Title: \(title), Values: \(values)")
        dismissVC()
    }
    
    @objc private func deleteButtonTapped() {
        guard let category = categoryToEdit, let categoryName = category.name else { return }
        
        UIHelper.showDeleteConfirmation(on: self, categoryName: categoryName) { [weak self] in
            CategoryManager.shared.deleteCategory(category)
            self?.onDataUpdate?(nil)
            self?.dismissVC()
        }
    }
    
    // MARK: - Helper Methods
    private func updateReturnKeyTypes() {
        let allFields: [UITextField] = [titleTextField] + valueTextFields
        TextFieldFactory.updateReturnKeyTypes(for: allFields)
    }
    
    private func setupKeyboardDismissal() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func dismissVC() {
        dismiss(animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension AddCategoryViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let allFields: [UITextField] = [titleTextField] + valueTextFields
        
        if let currentIndex = allFields.firstIndex(of: textField) {
            if currentIndex < allFields.count - 1 {
                allFields[currentIndex + 1].becomeFirstResponder()
            } else {
                textField.resignFirstResponder()
            }
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }
}

// MARK: - UIGestureRecognizerDelegate
extension AddCategoryViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view?.isDescendant(of: addValueFieldButton) != true
    }
}

// MARK: - SwiftUI Preview
struct AddCategoryViewController_Previews: PreviewProvider {
    static var previews: some View {
        ViewControllerPreview {
            AddCategoryViewController()
        }
    }
}
