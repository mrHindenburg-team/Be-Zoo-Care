import SwiftData
import Foundation

@Model
final class BZCWeightEntry {
    var date: Date
    var weightKg: Double
    var notes: String

    init(date: Date = .now, weightKg: Double, notes: String = "") {
        self.date = date
        self.weightKg = weightKg
        self.notes = notes
    }

    var weightLbs: Double { weightKg * 2.20462 }
}
