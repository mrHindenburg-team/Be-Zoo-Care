enum BZCGender: String, Codable, CaseIterable {
    case male    = "Male"
    case female  = "Female"
    case unknown = "Unknown"

    var icon: String {
        switch self {
        case .male:    "♂"
        case .female:  "♀"
        case .unknown: "–"
        }
    }
}
