import Foundation

fileprivate struct HintsData: Codable {
    let hints: [String: CategoryHints]
}

fileprivate struct CategoryHints: Codable {
    let count: Int
}

class HintManager {
    static let shared = HintManager()
    
    private var hintsByCategory: [String: [String]] = [:]
    private var allHints: [String] = []
    
    private init() {
        loadHints()
    }
    
    private func loadHints() {
        guard let url = Bundle.main.url(forResource: "hints", withExtension: "json") else {
            print("hints.json file not found.")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let hintsData = try decoder.decode(HintsData.self, from: data)
            
            for (category, categoryHints) in hintsData.hints {
                var hints: [String] = []
                for i in 1...categoryHints.count {
                    let hintKey = String(format: "%@%02d", category, i)
                    hints.append(hintKey)
                }
                self.hintsByCategory[category] = hints
            }
            
            self.allHints = Array(hintsByCategory.values.flatMap { $0 })
        } catch {
            print("Error loading or parsing hints.json: \(error)")
        }
    }
    
    func getHints(forCategory categoryName: String) -> [String] {
        
        if let hints = hintsByCategory[categoryName] {
            print("HintManager: Found \(hints.count) hints for category '\(categoryName)'")
            return hints.shuffled()
        } else {
            print("HintManager: Category '\(categoryName)' not found, using all \(allHints.count) hints")
            return allHints.shuffled()
        }
    }
    
    func getAllHints() -> [String] {
        print("HintManager: Returning all \(allHints.count) hints")
        return allHints.shuffled()
    }
}
