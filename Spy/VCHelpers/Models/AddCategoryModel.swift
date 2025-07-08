import UIKit
import CoreData

// MARK: - Constants
enum ValidationConstants {
    static let minTitleLength = 3
    static let minValuesCount = 5
    static let maxValuesCount = 30
    static let minValueLength = 3
}

// MARK: - TextField Factory
class TextFieldFactory {
    
    static func createStyledTextField(placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.spyBlue01G.withAlphaComponent(0.5)]
        )
        
        styleTextField(textField)
        textField.textAlignment = .left
        return textField
    }
    
    static func createValueTextField(placeholder: String, isDefault: Bool, removeAction: Selector?, target: Any?) -> UITextField {
        let textField = createStyledTextField(placeholder: placeholder)
        
        if !isDefault {
            addRemoveButton(to: textField, action: removeAction, target: target)
        }
        
        return textField
    }
    
    private static func styleTextField(_ textField: UITextField) {
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
    }
    
    private static func addRemoveButton(to textField: UITextField, action: Selector?, target: Any?) {
        let removeButton = UIButton(type: .system)
        removeButton.setImage(UIImage(systemName: "xmark.square.fill"), for: .normal)
        removeButton.tintColor = .white
        removeButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        removeButton.imageView?.contentMode = .scaleAspectFit
        removeButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        if let action = action, let target = target {
            removeButton.addTarget(target, action: action, for: .touchUpInside)
        }
        
        textField.rightView = removeButton
        textField.rightViewMode = .always
    }
    
    static func updateReturnKeyTypes(for fields: [UITextField]) {
        for (index, field) in fields.enumerated() {
            field.returnKeyType = (index == fields.count - 1) ? .done : .next
        }
    }
}

// MARK: - Validation Manager
class ValidationManager {
    
    static func validateCategoryInput(title: String, values: [String]) -> ValidationResult {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let filteredValues = values.compactMap {
            $0.trimmingCharacters(in: .whitespacesAndNewlines)
        }.filter { !$0.isEmpty }
        
        // Validate title length
        guard trimmedTitle.count >= ValidationConstants.minTitleLength else {
            return .failure(String(format: "category_title_min_length".localized, ValidationConstants.minTitleLength))
        }
        
        // Validate values count
        guard filteredValues.count >= ValidationConstants.minValuesCount else {
            return .failure(String(format: "category_min_values_required".localized, ValidationConstants.minValuesCount))
        }
        
        guard filteredValues.count <= ValidationConstants.maxValuesCount else {
            return .failure(String(format: "category_max_values_allowed".localized, ValidationConstants.maxValuesCount))
        }
        
        // Validate individual value lengths
        for value in filteredValues {
            guard value.count >= ValidationConstants.minValueLength else {
                return .failure(String(format: "category_value_min_length".localized, ValidationConstants.minValueLength, value))
            }
        }
        
        return .success((trimmedTitle, filteredValues))
    }
    
    static func isDuplicateCategory(title: String, excludingCategory: Category? = nil) -> Bool {
        return CategorySearchUtility.isDuplicateCategory(title: title, excludingCategory: excludingCategory)
    }
}

// MARK: - Button Factory
class ButtonFactory {
    
    static func createSaveButton(action: @escaping () -> Void) -> CustomGradientButton {
        let button = CustomGradientButton(
            labelText: "",
            width: 100,
            height: GeneralConstants.Button.biggerHeight
        )
        button.onClick = action
        return button
    }
    
    static func createDeleteButton(action: @escaping () -> Void) -> CustomGradientButton {
        let button = CustomGradientButton(
            labelText: "",
            iconImage: UIImage(systemName: "trash"),
            gradientColor: .red,
            width: GeneralConstants.Button.biggerHeight,
            height: GeneralConstants.Button.biggerHeight,
            shadowColor: .red,
            buttonColor: .red,
            fontSize: GeneralConstants.Font.size06
        )
        button.onClick = action
        button.setStatus(.activeRed)
        button.isHidden = true
        return button
    }
    
    static func createAddValueButton(action: @escaping () -> Void) -> CustomGradientButton {
        let button = CustomGradientButton(
            labelText: "",
            iconImage: UIImage(systemName: "plus"),
            width: 50,
            height: 50
        )
        button.onClick = action
        return button
    }
}

// MARK: - Keyboard Manager
class KeyboardManager {
    
    weak var viewController: UIViewController?
    weak var scrollView: UIScrollView?
    weak var addButton: UIView?
    weak var containerView: UIView?
    
    private var addButtonDefaultBottomConstraint: NSLayoutConstraint?
    private var addButtonKeyboardConstraint: NSLayoutConstraint?
    private let defaultBottomInset: CGFloat = 90
    
    init(viewController: UIViewController, scrollView: UIScrollView, addButton: UIView, containerView: UIView) {
        self.viewController = viewController
        self.scrollView = scrollView
        self.addButton = addButton
        self.containerView = containerView
        setupKeyboardConstraints()
    }
    
    private func setupKeyboardConstraints() {
        guard let viewController = viewController, let addButton = addButton, let containerView = containerView else { return }
        
        addButtonDefaultBottomConstraint = addButton.bottomAnchor.constraint(
            equalTo: containerView.bottomAnchor,
            constant: -GeneralConstants.Layout.bigMargin
        )
        addButtonKeyboardConstraint = addButton.bottomAnchor.constraint(
            equalTo: viewController.view.keyboardLayoutGuide.topAnchor,
            constant: -GeneralConstants.Layout.bigMargin
        )
        addButtonDefaultBottomConstraint?.isActive = true
    }
    
    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleKeyboardWillShow(notification)
        }
        
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleKeyboardWillHide(notification)
        }
    }
    
    func unregisterKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func handleKeyboardWillShow(_ notification: Notification) {
        guard let keyboardInfo = extractKeyboardInfo(from: notification),
              let viewController = viewController,
              let scrollView = scrollView else { return }
        
        let bottomInset = keyboardInfo.frame.height - viewController.view.safeAreaInsets.bottom
        
        UIView.animate(withDuration: keyboardInfo.duration, delay: 0, options: keyboardInfo.options) {
            scrollView.contentInset.bottom = bottomInset
            scrollView.verticalScrollIndicatorInsets.bottom = bottomInset
            
            self.addButtonDefaultBottomConstraint?.isActive = false
            self.addButtonKeyboardConstraint?.isActive = true
            
            viewController.view.layoutIfNeeded()
        }
    }
    
    private func handleKeyboardWillHide(_ notification: Notification) {
        guard let keyboardInfo = extractKeyboardInfo(from: notification),
              let viewController = viewController,
              let scrollView = scrollView else { return }
        
        UIView.animate(withDuration: keyboardInfo.duration, delay: 0, options: keyboardInfo.options) {
            scrollView.contentInset.bottom = self.defaultBottomInset
            scrollView.verticalScrollIndicatorInsets.bottom = self.defaultBottomInset
            
            self.addButtonKeyboardConstraint?.isActive = false
            self.addButtonDefaultBottomConstraint?.isActive = true
            
            viewController.view.layoutIfNeeded()
        }
    }
    
    private func extractKeyboardInfo(from notification: Notification) -> (frame: CGRect, duration: TimeInterval, options: UIView.AnimationOptions)? {
        guard let viewController = viewController,
              let userInfo = notification.userInfo,
              let keyboardFrameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
              let curveRawValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return nil }
        
        let keyboardFrame = viewController.view.convert(keyboardFrameValue.cgRectValue, from: nil)
        let options = UIView.AnimationOptions(rawValue: curveRawValue << 16)
        
        return (keyboardFrame, duration, options)
    }
    
    func scrollToTextField(_ textField: UITextField) {
        guard let scrollView = scrollView else { return }
        
        let textFieldFrame = scrollView.convert(textField.bounds, from: textField)
        let scrollPointY = max(0, textFieldFrame.maxY + GeneralConstants.Layout.littleMargin - scrollView.bounds.height + scrollView.contentInset.bottom)
        
        UIView.animate(withDuration: 0.1) {
            scrollView.setContentOffset(CGPoint(x: 0, y: scrollPointY), animated: false)
        }
    }
}

// MARK: - Animation Helper
class AddCategoryAnimationHelper {
    
    static func animateTextFieldAddition(_ textField: UITextField, completion: @escaping () -> Void) {
        textField.alpha = 0
        textField.transform = CGAffineTransform(translationX: 0, y: -20)
        
        UIView.animate(withDuration: 0.3, animations: {
            textField.alpha = 1
            textField.transform = .identity
        }, completion: { _ in
            completion()
        })
    }
    
    static func animateTextFieldRemoval(_ textField: UITextField, completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.3, animations: {
            textField.alpha = 0
            textField.transform = CGAffineTransform(translationX: 0, y: -20)
        }, completion: { _ in
            completion()
        })
    }
}

// MARK: - UI Helper
class UIHelper {
    
    static func showAlert(on viewController: UIViewController, title: String = "error".localized, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "okey".localized, style: .default))
        viewController.present(alert, animated: true)
    }
    
    static func showDeleteConfirmation(on viewController: UIViewController, categoryName: String, deleteAction: @escaping () -> Void) {
        let confirmAlert = UIAlertController(
            title: "confirm_delete".localized,
            message: "are_you_sure_delete_category".localized,
            preferredStyle: .alert
        )
        
        confirmAlert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel))
        confirmAlert.addAction(UIAlertAction(title: "delete".localized, style: .destructive) { _ in
            deleteAction()
        })
        
        viewController.present(confirmAlert, animated: true)
    }
}

// MARK: - Validation Result
enum ValidationResult {
    case success((title: String, values: [String]))
    case failure(String)
} 
