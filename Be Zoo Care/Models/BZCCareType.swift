enum BZCCareType: String, Codable, CaseIterable {
    case feeding       = "Feeding"
    case water         = "Water"
    case grooming      = "Grooming"
    case exercise      = "Exercise"
    case playtime      = "Playtime"
    case training      = "Training"
    case medication    = "Medication"
    case cleaning      = "Cleaning"
    case socialization = "Socialization"
    case checkup       = "Checkup"
    case bath          = "Bath"
    case brushing      = "Brushing"
    case nailTrim      = "Nail Trim"
    case deworming     = "Deworming"
    case weighing      = "Weighing"
    case enrichment    = "Enrichment"

    var systemIcon: String {
        switch self {
        case .feeding:       "fork.knife"
        case .water:         "drop.fill"
        case .grooming:      "scissors"
        case .exercise:      "figure.run"
        case .playtime:      "gamecontroller.fill"
        case .training:      "star.fill"
        case .medication:    "pills.fill"
        case .cleaning:      "sparkles"
        case .socialization: "person.2.fill"
        case .checkup:       "stethoscope"
        case .bath:          "shower.fill"
        case .brushing:      "paintbrush.fill"
        case .nailTrim:      "scissors.circle.fill"
        case .deworming:     "cross.circle.fill"
        case .weighing:      "scalemass.fill"
        case .enrichment:    "leaf.fill"
        }
    }

    var guideMascot: BZCMascot {
        switch self {
        case .feeding, .water:              .fox
        case .grooming, .bath, .brushing,
             .nailTrim:                     .rhino
        case .exercise, .playtime,
             .socialization, .enrichment:   .wolf
        case .training:                     .wolf
        case .medication, .checkup,
             .deworming:                    .rhino
        case .cleaning:                     .panda
        case .weighing:                     .rhino
        }
    }
}
