import UIKit

extension AddCategoryViewController {
    
    internal func setupConstraints() {
        NSLayoutConstraint.activate([
            darkBottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.bigMargin),
            darkBottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.bigMargin),
            darkBottomView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -Constants.bigMargin),
            darkBottomView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.bigMargin),
            
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.bigMargin),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.bigMargin),
            saveButton.heightAnchor.constraint(equalToConstant: Constants.buttonsHeight),
            
            deleteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.bigMargin),
            deleteButton.bottomAnchor.constraint(equalTo: saveButton.bottomAnchor),
            deleteButton.heightAnchor.constraint(equalTo: saveButton.heightAnchor),
            deleteButton.widthAnchor.constraint(equalTo: deleteButton.heightAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: Constants.littleMargin),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: Constants.littleMargin),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -Constants.littleMargin),
            stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -2 * Constants.littleMargin),
            
            addValueFieldButton.trailingAnchor.constraint(equalTo: darkBottomView.trailingAnchor, constant: -Constants.bigMargin),
            addValueFieldButton.heightAnchor.constraint(equalToConstant: 50),
            addValueFieldButton.widthAnchor.constraint(equalToConstant: 50)
        ])
        
        setupSaveButtonConstraints()
    }
    
    private func setupSaveButtonConstraints() {
        saveButtonLeadingConstraintWithoutDelete = saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.bigMargin)
        saveButtonLeadingConstraintWithDelete = saveButton.leadingAnchor.constraint(equalTo: deleteButton.trailingAnchor, constant: Constants.bigMargin)
    }
    
    internal func showDeleteButtonConstraints() {
        saveButtonLeadingConstraintWithoutDelete.isActive = false
        saveButtonLeadingConstraintWithDelete.isActive = true
    }
    
    internal func hideDeleteButtonConstraints() {
        saveButtonLeadingConstraintWithDelete.isActive = false
        saveButtonLeadingConstraintWithoutDelete.isActive = true
    }
} 
