import SwiftUI

enum BZCHealthSeverity: String, Codable, CaseIterable {
    case mild     = "Mild"
    case moderate = "Moderate"
    case serious  = "Serious"
    case critical = "Critical"

    var color: Color {
        switch self {
        case .mild:     BZCColors.emeraldGreen
        case .moderate: BZCColors.richGold
        case .serious:  BZCColors.warningOrange
        case .critical: BZCColors.errorRed
        }
    }

    var systemIcon: String {
        switch self {
        case .mild:     "checkmark.circle.fill"
        case .moderate: "exclamationmark.circle.fill"
        case .serious:  "exclamationmark.triangle.fill"
        case .critical: "xmark.octagon.fill"
        }
    }
}
