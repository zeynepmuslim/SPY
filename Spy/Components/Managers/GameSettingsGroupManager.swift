import UIKit

class GameSettingsGroupManager {
    
    // MARK: - Constants
    private enum Constants {
        static let minRoundDuration: Int = 1
        static let maxRoundDuration: Int = 10
        static let minRoundCount: Int = 1
        static let maxRoundCount: Int = 10
        static let spacing: CGFloat = GeneralConstants.Layout.spacing
        static let categoryButtonWidth: CGFloat = 90
    }
    
    // MARK: - Enums
    enum SettingsGroupStyle {
        case plusMinus
        case singleButton
        case switchButton
    }
    
    // MARK: - SettingsGroup Class
    class SettingsGroup: Equatable {
        
        // MARK: - UI Components
        let stackView: UIStackView
        let label: VerticalAlignedLabel
        let valueLabel: UILabel
        var minusButton: CustomGradientButton?
        var plusButton: CustomGradientButton?
        var actionButton: CustomGradientButton?
        var switchButton: CustomGradientSwitch?
        
        // MARK: - Properties
        private var currentValue: Int
        private let minValue: Int
        private let maxValue: Int
        private let valueFormatter: (Int) -> String
        private let buttonColor: GradientColor
        private let buttonShadow: ShadowColor
        private let style: SettingsGroupStyle
        private let actionButtonTitle: String
        var onActionButtonClick: (() -> Void)?
        
        // MARK: - Value Management
        var value: Any {
            didSet {
                updateValueDisplay()
            }
        }
        
        // MARK: - Equatable
        static func == (lhs: GameSettingsGroupManager.SettingsGroup, rhs: GameSettingsGroupManager.SettingsGroup) -> Bool {
            return lhs === rhs
        }
        
        // MARK: - Initialization
        init(title: String,
             target: UIViewController,
             initialValue: Int,
             minValue: Int,
             maxValue: Int,
             style: SettingsGroupStyle = .plusMinus,
             buttonColor: GradientColor = .blue,
             buttonShadow: ShadowColor = .blue,
             valueFormatter: @escaping (Int) -> String,
             actionButtonTitle: String = "",
             onActionButtonClick: (() -> Void)? = nil) {
            
            self.currentValue = initialValue
            self.minValue = minValue
            self.maxValue = maxValue
            self.valueFormatter = valueFormatter
            self.buttonColor = buttonColor
            self.buttonShadow = buttonShadow
            self.style = style
            self.actionButtonTitle = actionButtonTitle
            self.onActionButtonClick = onActionButtonClick
            
            switch style {
            case .plusMinus:
                self.value = initialValue
            case .singleButton:
                self.value = valueFormatter(initialValue)
            case .switchButton:
                self.value = (initialValue == 1)
            }
            
            self.stackView = Self.createMainStackView()
            self.label = Self.createTitleLabel(title: title)
            self.valueLabel = Self.createValueLabel()
            
            self.setupUIHierarchy()
            self.setupControlsForStyle()
            self.updateValueDisplay()
            self.updateButtonStates()
        }
        
        // MARK: - UI Setup Methods
        private static func createMainStackView() -> UIStackView {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.spacing = Constants.spacing
            stackView.alignment = .center
            stackView.distribution = .fill
            stackView.translatesAutoresizingMaskIntoConstraints = false
            return stackView
        }
        
        private static func createTitleLabel(title: String) -> VerticalAlignedLabel {
            let label = VerticalAlignedLabel()
            label.text = title
            label.textColor = .white
            label.numberOfLines = 0
            label.font = UIFont.boldSystemFont(ofSize: GeneralConstants.Font.size04)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            return label
        }
        
        private static func createValueLabel() -> UILabel {
            let label = UILabel()
            label.textColor = .spyBlue01
            label.font = UIFont.systemFont(ofSize: GeneralConstants.Font.size02, weight: .regular)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textAlignment = .left
            return label
        }
        
        private func setupUIHierarchy() {
            let labelStack = UIStackView()
            labelStack.axis = .vertical
            labelStack.spacing = GeneralConstants.Layout.littleSpacing
            labelStack.alignment = .leading
            labelStack.distribution = .fill
            labelStack.translatesAutoresizingMaskIntoConstraints = false
            
            labelStack.addArrangedSubview(label)
            if style != .switchButton {
                labelStack.addArrangedSubview(valueLabel)
            }
            
            stackView.addArrangedSubview(labelStack)
            
            let spacerView = UIView()
            spacerView.translatesAutoresizingMaskIntoConstraints = false
            spacerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
            stackView.addArrangedSubview(spacerView)
        }
        
        private func setupControlsForStyle() {
            switch style {
            case .plusMinus:
                setupPlusMinusControls()
            case .singleButton:
                setupSingleButtonControl()
            case .switchButton:
                setupSwitchControl()
            }
        }
        
        private func setupPlusMinusControls() {
            minusButton = createControlButton(text: "-")
            plusButton = createControlButton(text: "+")
            
            let buttonsStack = UIStackView()
            buttonsStack.axis = .horizontal
            buttonsStack.spacing = Constants.spacing
            buttonsStack.alignment = .center
            buttonsStack.distribution = .fill
            buttonsStack.translatesAutoresizingMaskIntoConstraints = false
            
            if let minus = minusButton, let plus = plusButton {
                buttonsStack.addArrangedSubview(minus)
                buttonsStack.addArrangedSubview(plus)
            }
            
            stackView.addArrangedSubview(buttonsStack)
            
            minusButton?.onClick = { [weak self] in
                self?.decrementValue()
            }
            
            plusButton?.onClick = { [weak self] in
                self?.incrementValue()
            }
        }
        
        private func setupSingleButtonControl() {
            actionButton = CustomGradientButton(
                labelText: actionButtonTitle,
                gradientColor: buttonColor,
                width: Constants.categoryButtonWidth,
                height: GeneralConstants.Button.miniHeight,
                shadowColor: buttonShadow,
                fontSize: GeneralConstants.Font.size01
            )
            actionButton?.translatesAutoresizingMaskIntoConstraints = false
            
            if let action = actionButton {
                stackView.addArrangedSubview(action)
            }
            
            actionButton?.onClick = { [weak self] in
                self?.onActionButtonClick?()
            }
        }
        
        private func setupSwitchControl() {
            switchButton = CustomGradientSwitch(gradientColor: .blue, shadowColor: .blue)
            switchButton?.translatesAutoresizingMaskIntoConstraints = false
            switchButton?.isOn = (value as? Bool) ?? false
            
            if let switchButton = switchButton {
                stackView.addArrangedSubview(switchButton)
            }
        }
        
        private func createControlButton(text: String) -> CustomGradientButton {
            let button = CustomGradientButton(
                labelText: text,
                gradientColor: buttonColor,
                width: GeneralConstants.Button.miniHeight,
                height: GeneralConstants.Button.miniHeight,
                shadowColor: buttonShadow
            )
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        }
        
        // MARK: - Value Management Methods
        private func updateValueDisplay() {
            switch style {
            case .plusMinus:
                if let intValue = value as? Int {
                    currentValue = intValue
                    valueLabel.text = valueFormatter(currentValue)
                    updateButtonStates()
                }
            case .singleButton:
                if let stringValue = value as? String {
                    valueLabel.text = stringValue.localized
                }
            case .switchButton:
                if let boolValue = value as? Bool {
                    switchButton?.isOn = boolValue
                }
            }
        }
        
        private func incrementValue() {
            guard currentValue < maxValue else { return }
            currentValue += 1
            valueLabel.text = valueFormatter(currentValue)
            updateButtonStates()
            self.value = currentValue
        }
        
        private func decrementValue() {
            guard currentValue > minValue else { return }
            currentValue -= 1
            valueLabel.text = valueFormatter(currentValue)
            updateButtonStates()
            self.value = currentValue
        }
        
        private func updateButtonStates() {
            guard style == .plusMinus else { return }
            
            if let minus = minusButton {
                updateButton(minus, isEnabled: currentValue > minValue)
            }
            if let plus = plusButton {
                updateButton(plus, isEnabled: currentValue < maxValue)
            }
        }
        
        private func updateButton(_ button: CustomGradientButton, isEnabled: Bool) {
            if isEnabled {
                button.setStatus(buttonColor == .red ? .activeRed : .activeBlue)
                button.isUserInteractionEnabled = true
            } else {
                button.setStatus(.deactive)
                button.isUserInteractionEnabled = false
            }
        }
    }
    
    // MARK: - Factory Methods
    static func createCategoryGroup(target: UIViewController, action: @escaping () -> Void, initialCategory: String = "basic") -> SettingsGroup {
        return SettingsGroup(
            title: "category".localized,
            target: target,
            initialValue: 0,
            minValue: 0,
            maxValue: 0,
            style: .singleButton,
            valueFormatter: { _ in initialCategory },
            actionButtonTitle: "select".localized,
            onActionButtonClick: action
        )
    }
    
    static func createRoundDurationGroup(target: UIViewController, initialDuration: Int = 3) -> SettingsGroup {
        return SettingsGroup(
            title: "round_time".localized,
            target: target,
            initialValue: initialDuration,
            minValue: Constants.minRoundDuration,
            maxValue: Constants.maxRoundDuration,
            valueFormatter: { value in String(format: "minutes_format".localized, value) }
        )
    }
    
    static func createRoundCountGroup(target: UIViewController, initialCount: Int = 5) -> SettingsGroup {
        return SettingsGroup(
            title: "round_count".localized,
            target: target,
            initialValue: initialCount,
            minValue: Constants.minRoundCount,
            maxValue: Constants.maxRoundCount,
            valueFormatter: { value in String(format: "rounds_format".localized, value) }
        )
    }
    
    static func createHintToggleGroup(target: UIViewController, initialShowHints: Bool = true) -> SettingsGroup {
        return SettingsGroup(
            title: "show_hints".localized,
            target: target,
            initialValue: initialShowHints ? 1 : 0,
            minValue: 0,
            maxValue: 1,
            style: .switchButton,
            valueFormatter: { _ in "" }
        )
    }
}
