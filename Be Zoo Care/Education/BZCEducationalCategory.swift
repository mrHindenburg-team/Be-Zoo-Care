enum BZCEducationalCategory: String, CaseIterable, Identifiable {
    case health        = "Health"
    case preventiveCare = "Preventive Care"
    case grooming      = "Grooming"
    case routines      = "Routines"
    case training      = "Training"
    case exercise      = "Exercise"
    case wellbeing     = "Wellbeing"
    case enrichment    = "Enrichment"
    case behavior      = "Behavior"
    case nutrition     = "Nutrition"
    case petSafety     = "Pet Safety"
    case seniorCare    = "Senior Care"
    case smartTips     = "Smart Tips"
    case youngAnimals  = "Young Animals"
    case multiPet      = "Multi-Pet"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .health:        "💚"
        case .preventiveCare: "🛡️"
        case .grooming:      "✂️"
        case .routines:      "📅"
        case .training:      "⭐"
        case .exercise:      "🏃"
        case .wellbeing:     "🌸"
        case .enrichment:    "🧩"
        case .behavior:      "🧠"
        case .nutrition:     "🥗"
        case .petSafety:     "🔒"
        case .seniorCare:    "🫶"
        case .smartTips:     "💡"
        case .youngAnimals:  "🌱"
        case .multiPet:      "🐾"
        }
    }

    var symbolName: String {
        switch self {
        case .health:        "heart.fill"
        case .preventiveCare: "shield.fill"
        case .grooming:      "scissors"
        case .routines:      "calendar"
        case .training:      "star.fill"
        case .exercise:      "figure.run"
        case .wellbeing:     "sparkles"
        case .enrichment:    "puzzlepiece.fill"
        case .behavior:      "brain.head.profile"
        case .nutrition:     "fork.knife"
        case .petSafety:     "lock.shield.fill"
        case .seniorCare:    "figure.walk"
        case .smartTips:     "lightbulb.fill"
        case .youngAnimals:  "leaf.fill"
        case .multiPet:      "pawprint.fill"
        }
    }

    var guideMascot: BZCMascot {
        switch self {
        case .health, .preventiveCare, .grooming:  .rhino
        case .routines, .training, .exercise:       .wolf
        case .wellbeing, .enrichment, .behavior:    .panda
        case .nutrition, .petSafety, .seniorCare:  .owl
        case .smartTips, .youngAnimals, .multiPet: .fox
        }
    }
}
