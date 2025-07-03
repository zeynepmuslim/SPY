import Foundation
import UIKit
import CoreData

// MARK: - Category Search Utility
class CategorySearchUtility {
    
    static let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // MARK: - Search Strategies
    enum SearchStrategy {
        case exact
        case caseInsensitive
        case localized
        case all
    }
    
    // MARK: - Main Search Function
    static func findCategory(by name: String, strategy: SearchStrategy = .all) -> Category? {
        switch strategy {
        case .exact:
            return findCategoryExact(name: name)
        case .caseInsensitive:
            return findCategoryCaseInsensitive(name: name)
        case .localized:
            return findCategoryLocalized(name: name)
        case .all:
            return findCategoryWithAllStrategies(name: name)
        }
    }
    
    // MARK: - Search Implementations
    private static func findCategoryExact(name: String) -> Category? {
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            print("Error in exact search for category '\(name)': \(error)")
            return nil
        }
    }
    
    private static func findCategoryCaseInsensitive(name: String) -> Category? {
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name LIKE[c] %@", name)
        
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            print("Error in case-insensitive search for category '\(name)': \(error)")
            return nil
        }
    }
    
    private static func findCategoryLocalized(name: String) -> Category? {
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        
        do {
            let allCategories = try context.fetch(fetchRequest)
            let inputDisplayName = name.localized
            
            return allCategories.first { category in
                guard let categoryName = category.name else { return false }
                return categoryName.localized.caseInsensitiveCompare(inputDisplayName) == .orderedSame
            }
        } catch {
            print("Error in localized search for category '\(name)': \(error)")
            return nil
        }
    }
    
    private static func findCategoryWithAllStrategies(name: String) -> Category? {
        if let category = findCategoryExact(name: name) {
            print("Found category with exact match: '\(category.name ?? "nil")'")
            return category
        }
        
        if let category = findCategoryLocalized(name: name) {
            print("Found category with localized match: '\(category.name ?? "nil")'")
            return category
        }
        
        if let category = findCategoryCaseInsensitive(name: name) {
            print("Found category with case-insensitive search: '\(category.name ?? "nil")'")
            return category
        }
        
        print("No category found for '\(name)' with any strategy")
        return nil
    }
    
    // MARK: - Duplicate Check
    static func isDuplicateCategory(title: String, excludingCategory: Category? = nil) -> Bool {
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        
        do {
            let allCategories = try context.fetch(fetchRequest)
            
            for category in allCategories {
                if let excludingCategory = excludingCategory, category.objectID == excludingCategory.objectID {
                    continue
                }
                
                guard let categoryName = category.name else { continue }
                
                if categoryName == title {
                    print("Found exact name match: \(categoryName)")
                    return true
                }
                
                let storedDisplayName = categoryName.localized
                let inputDisplayName = title.localized
                
                if storedDisplayName.caseInsensitiveCompare(inputDisplayName) == .orderedSame {
                    print("Found localized display name conflict: \(storedDisplayName) vs \(inputDisplayName)")
                    return true
                }
                
                if categoryName.localized.caseInsensitiveCompare(title) == .orderedSame {
                    print("Found display name conflict with category: \(categoryName.localized) vs \(title)")
                    return true
                }
            }
            
            print("No duplicate found for: \(title)")
            return false
        } catch {
            print("Error checking for duplicate category: \(error)")
            return false
        }
    }
    
    // MARK: - Word Retrieval
    static func getRandomWordFromCategory(categoryName: String) -> String {
        guard let category = findCategory(by: categoryName) else {
            print("Category '\(categoryName)' not found")
            return "unknown".localized
        }
        
        guard let wordsSet = category.words as? Set<Word>, !wordsSet.isEmpty else {
            print("No words found in category '\(categoryName)'")
            return "unknown".localized
        }
        
        let wordsArray = Array(wordsSet)
        guard let randomWord = wordsArray.randomElement() else {
            print("Failed to get random word from category '\(categoryName)'")
            return "unknown".localized
        }
        
        print("Found word '\(randomWord.text ?? "nil")' from category '\(categoryName)'")
        return randomWord.text ?? "unknown".localized
    }
    
    // MARK: - Debug Helper
    static func printAllCategories() {
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        
        do {
            let categories = try context.fetch(fetchRequest)
            print("=== All Categories in Database ===")
            for category in categories {
                let wordCount = (category.words as? Set<Word>)?.count ?? 0
                print("  - '\(category.name ?? "nil")' (\(wordCount) words, isDefault: \(category.isDefault))")
            }
            print("==================================")
        } catch {
            print("Error fetching categories for debug: \(error)")
        }
    }
} 
