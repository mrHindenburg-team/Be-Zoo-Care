import SwiftData
import Foundation

@Model
final class BZCMilestone {
    var date: Date
    var title: String
    var details: String
    var category: BZCMilestoneCategory
    var isSpecial: Bool

    init(
        date: Date = .now,
        title: String,
        details: String = "",
        category: BZCMilestoneCategory = .general,
        isSpecial: Bool = false
    ) {
        self.date = date
        self.title = title
        self.details = details
        self.category = category
        self.isSpecial = isSpecial
    }
}

enum BZCMilestoneCategory: String, Codable, CaseIterable {
    case adoption    = "Adoption"
    case birthday    = "Birthday"
    case health      = "Health"
    case training    = "Training"
    case achievement = "Achievement"
    case general     = "General"

    var emoji: String {
        switch self {
        case .adoption:    "🏠"
        case .birthday:    "🎂"
        case .health:      "💚"
        case .training:    "⭐"
        case .achievement: "🏆"
        case .general:     "📍"
        }
    }

    var symbolName: String {
        switch self {
        case .adoption:    "house.fill"
        case .birthday:    "gift.fill"
        case .health:      "cross.fill"
        case .training:    "star.fill"
        case .achievement: "trophy.fill"
        case .general:     "pin.fill"
        }
    }
}
