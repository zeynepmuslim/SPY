//
//  CustomCategoriesModel.swift
//  Spy
//
//  Created by Zeynep Müslim on 8.04.2025.
//

import UIKit
import CoreData

class CustomCategoriesModel {
    
    // MARK: - Properties
    private var categoryEntities: [Category] = []
    private var gameSessionEntities: [GameSession] = []
    var selectedCategory: String = "travel"
    
    // MARK: - Callbacks
    var onCategoriesLoaded: (([Category]) -> Void)?
    var onCategorySelected: ((String) -> Void)?
    
    // MARK: - Core Data Operations
    
    func loadCategories() {
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        do {
            categoryEntities = try (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext.fetch(fetchRequest)
            onCategoriesLoaded?(categoryEntities)
        } catch {
            print("Error fetching category entities: \(error)")
        }
    }
    
    func loadSessions() {
        let fetchRequest: NSFetchRequest<GameSession> = GameSession.fetchRequest()
        do {
            gameSessionEntities = try (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext.fetch(fetchRequest)
            
            for session in gameSessionEntities {
                if let category = session.category {
                    if categoryEntities.contains(where: { $0.name == category }) {
                        selectedCategory = category
                        onCategorySelected?(selectedCategory)
                        break
                    }
                }
            }
        } catch {
            print("Error fetching game session entities: \(error)")
        }
    }
    
    // MARK: - Category Operations
    
    func selectCategory(_ categoryName: String, shouldNotify: Bool = true) {
        selectedCategory = categoryName
        if shouldNotify {
            onCategorySelected?(selectedCategory)
        }
        print("Selected category: \(selectedCategory)")
    }
    
    func saveSelectedCategory() {
        if let defaultSession = GameStateManager.shared.getDefaultSessions().first {
            defaultSession.category = selectedCategory
            GameStateManager.shared.saveContext()
            print("Default session category updated to: \(selectedCategory)")
        }
    }
    
    func getCategoryEntity(at index: Int) -> Category? {
        guard index < categoryEntities.count else { return nil }
        return categoryEntities[index]
    }
    
    func getCategoryInfo(for category: Category) -> (name: String, words: [String]) {
        let categoryName = category.name ?? "Unknown"
        let categoryWords: [String]
        
        if let wordsSet = category.words as? Set<Word> {
            categoryWords = wordsSet.compactMap { $0.text }.filter { !$0.isEmpty }
        } else {
            categoryWords = []
        }
        
        let finalWords = categoryWords.isEmpty ? ["Bu kategoride henüz kelime yok"] : categoryWords
        return (name: categoryName, words: finalWords)
    }
    
    func isCategorySelected(_ categoryName: String) -> Bool {
        return categoryName == selectedCategory
    }
    
    func getPreviousSelectedIndex() -> Int? {
        return categoryEntities.firstIndex(where: { $0.name == selectedCategory })
    }
    
    // MARK: - Collection View Data
    
    func getCategoryCount() -> Int {
        return categoryEntities.count
    }
    
    func getTotalItemCount() -> Int {
        return categoryEntities.count + 1 // +1 for "Add New" cell
    }
    
    func getCategoryDisplayData(at index: Int) -> (name: String, icon: String, isCustom: Bool, isSelected: Bool)? {
        guard index < categoryEntities.count else { return nil }
        
        let categoryEntity = categoryEntities[index]
        let categoryName = categoryEntity.name ?? "Unknown"
        let categoryIcon = categoryEntity.icon ?? "questionmark.circle.fill"
        let isCustom = !(categoryEntity.isDefault)
        let isSelected = categoryName == selectedCategory
        
        return (name: categoryName, icon: categoryIcon, isCustom: isCustom, isSelected: isSelected)
    }
    
    // MARK: - Category Management
    
    func handleCategoryUpdate(categoryName: String?) {
        loadCategories()
        if let categoryName = categoryName {
            selectedCategory = categoryName
            onCategorySelected?(selectedCategory)
        }
    }
    
    func handleCategoryDeletion(originalCategoryName: String?, categoryName: String?) {
        loadCategories()
        if let categoryName = categoryName {
            // Category was updated
            selectedCategory = categoryName
            onCategorySelected?(selectedCategory)
        } else if let originalName = originalCategoryName,
                  originalName == selectedCategory {
            // The deleted category was the selected one, switch to "basic"
            selectedCategory = "basic"
            onCategorySelected?(selectedCategory)
        }
    }
}
