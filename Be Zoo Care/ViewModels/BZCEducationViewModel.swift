import Foundation
import Observation

@Observable
final class BZCEducationViewModel {

    var searchText: String = ""
    var selectedCategory: BZCEducationalCategory?
    var selectedMascot: BZCMascot?
    var selectedArticle: BZCEducationalArticle?
    var showingArticle: Bool = false

    var filteredArticles: [BZCEducationalArticle] {
        var articles = BZCKnowledgeBase.all

        if let category = selectedCategory {
            articles = articles.filter { $0.category == category }
        }

        if let mascot = selectedMascot {
            articles = articles.filter { $0.mascot == mascot }
        }

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !query.isEmpty {
            articles = articles.filter {
                $0.title.localizedStandardContains(query) ||
                $0.summary.localizedStandardContains(query) ||
                $0.tags.contains { $0.localizedStandardContains(query) }
            }
        }

        return articles
    }

    var categoryGroups: [(BZCMascot, [BZCEducationalArticle])] {
        BZCMascot.allCases.compactMap { mascot in
            let articles = BZCKnowledgeBase.all.filter { $0.mascot == mascot }
            return articles.isEmpty ? nil : (mascot, articles)
        }
    }

    func selectArticle(_ article: BZCEducationalArticle) {
        selectedArticle = article
        showingArticle = true
    }

    func clearFilters() {
        selectedCategory = nil
        selectedMascot = nil
        searchText = ""
    }
}
