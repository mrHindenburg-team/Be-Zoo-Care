import SwiftData
import Foundation

@Model
final class BZCJournalEntry {
    var date: Date
    var title: String
    var content: String
    var mood: BZCPetMood
    var tags: [String]

    init(
        date: Date = .now,
        title: String = "",
        content: String,
        mood: BZCPetMood = .happy,
        tags: [String] = []
    ) {
        self.date = date
        self.title = title
        self.content = content
        self.mood = mood
        self.tags = tags
    }
}

enum BZCPetMood: String, Codable, CaseIterable {
    case happy     = "Happy"
    case playful   = "Playful"
    case calm      = "Calm"
    case tired     = "Tired"
    case anxious   = "Anxious"
    case unwell    = "Unwell"

    var emoji: String {
        switch self {
        case .happy:   "😊"
        case .playful: "🎉"
        case .calm:    "😌"
        case .tired:   "😴"
        case .anxious: "😟"
        case .unwell:  "🤒"
        }
    }

    var symbolName: String {
        switch self {
        case .happy:   "sun.max.fill"
        case .playful: "gamecontroller.fill"
        case .calm:    "leaf.fill"
        case .tired:   "moon.fill"
        case .anxious: "exclamationmark.triangle.fill"
        case .unwell:  "cross.case.fill"
        }
    }
}
