import Foundation
import UIKit
import CoreData

class CategoryManager {
    static let shared = CategoryManager()
    private let context: NSManagedObjectContext
    
    // Private initializer - singleton pattern için gerekli
    private init() {
        self.context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    // MARK: - Private Helper Methods
    
    private func loadDefaultCategoriesFromJSON() -> [DefaultCategory]? {
        guard let url = Bundle.main.url(forResource: "default_categories", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let categories = try? JSONDecoder().decode([DefaultCategory].self, from: data) else {
            print("JSON cant read")
            return nil
        }
        return categories
    }
    
    func loadDefaultCategories() {
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isDefault == YES")
        
        do {
            let existingCategories = try context.fetch(fetchRequest)
            if !existingCategories.isEmpty {
                return
            }
            
            guard let categories = loadDefaultCategoriesFromJSON() else { return }
            
            for category in categories {
                let newCategory = Category(context: context)
                newCategory.id = UUID()
                newCategory.name = category.title
                newCategory.icon = category.icon
                newCategory.isDefault = true
                newCategory.createdAt = Date()
                
                for wordText in category.values {
                    let newWord = Word(context: context)
                    newWord.id = UUID()
                    newWord.text = wordText
                    newWord.category = newCategory
                }
            }
            
            try context.save()
        } catch {
            print("Error loading default categories: \(error)")
        }
    }
    
    func fetchCategories() -> [(name: String, icon: String, values: [String])] {
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        
        do {
            let categories = try context.fetch(fetchRequest)
            return categories.map { category in
                let words = category.words?.allObjects.compactMap { ($0 as? Word)?.text } ?? []
                let icon = (category.icon?.isEmpty == false) ? category.icon! : "seal"
                let name = (category.icon?.isEmpty == false) ? (category.name ?? "") : "other".localized
                return (
                    name: name,
                    icon: icon,
                    values: words
                )
            }
        } catch {
            print("Error fetching categories: \(error)")
            return []
        }
    }
    
    
    // MARK: - Operations
    
    func addCategory(name: String, icon: String, words: [String]) {
        let newCategory = Category(context: context)
        newCategory.id = UUID()
        newCategory.name = name
        newCategory.icon = icon
        newCategory.isDefault = false
        newCategory.createdAt = Date()
        
        for wordText in words {
            let newWord = Word(context: context)
            newWord.id = UUID()
            newWord.text = wordText
            newWord.category = newCategory
        }
        saveContext()
    }
    
    func updateCategory(_ category: Category, newName: String, newIcon: String, newWords: [String]) {
        category.name = newName
        category.icon = newIcon
        
        if let existingWords = category.words as? Set<Word> {
            for word in existingWords {
                context.delete(word)
            }
        }
        
        for wordText in newWords {
            let newWord = Word(context: context)
            newWord.id = UUID()
            newWord.text = wordText
            newWord.category = category
        }
        
        saveContext()
    }
    
    func deleteCategory(_ category: Category) { //cascade
        context.delete(category)
        saveContext()
    }
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    // MARK: - Sync Default Categories with JSON
    
    func syncDefaultCategoriesWithJSON() {
        guard let jsonCategories = loadDefaultCategoriesFromJSON() else { return }
        
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isDefault == YES")
        let existingCategories = (try? context.fetch(fetchRequest)) ?? []
        
        for jsonCat in jsonCategories {
            if let existing = existingCategories.first(where: { $0.name == jsonCat.title }) {
                existing.icon = jsonCat.icon
                if let wordsSet = existing.words as? Set<Word> {
                    for word in wordsSet {
                        context.delete(word)
                    }
                }
                for wordText in jsonCat.values {
                    let word = Word(context: context)
                    word.id = UUID()
                    word.text = wordText
                    word.category = existing
                }
            } else {
                let newCategory = Category(context: context)
                newCategory.id = UUID()
                newCategory.name = jsonCat.title
                newCategory.icon = jsonCat.icon
                newCategory.isDefault = true
                newCategory.createdAt = Date()
                for wordText in jsonCat.values {
                    let word = Word(context: context)
                    word.id = UUID()
                    word.text = wordText
                    word.category = newCategory
                }
            }
        }
        
        for existing in existingCategories {
            if !jsonCategories.contains(where: { $0.title == existing.name }) {
                context.delete(existing)
            }
        }
        
        do {
            try context.save()
        } catch {
            print("Core Data güncellenemedi: \(error)")
        }
    }
}
