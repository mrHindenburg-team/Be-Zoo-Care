import Foundation

struct BZCEducationalArticle: Identifiable {
    let id: String
    let title: String
    let summary: String
    let content: String
    let category: BZCEducationalCategory
    let species: [BZCSpecies]
    let readTimeMinutes: Int
    let mascot: BZCMascot
    let isPremium: Bool
    let tags: [String]

    static func forCategory(_ category: BZCEducationalCategory) -> [BZCEducationalArticle] {
        BZCKnowledgeBase.all.filter { $0.category == category }
    }

    static func forSpecies(_ species: BZCSpecies) -> [BZCEducationalArticle] {
        BZCKnowledgeBase.all.filter { $0.species.contains(species) || $0.species.isEmpty }
    }
}
