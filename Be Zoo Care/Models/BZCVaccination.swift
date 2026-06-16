import SwiftData
import Foundation

@Model
final class BZCVaccination {
    var name: String
    var dateGiven: Date
    var expiresAt: Date?
    var batchNumber: String
    var veterinarianName: String
    var notes: String

    init(
        name: String,
        dateGiven: Date = .now,
        expiresAt: Date? = nil,
        veterinarianName: String = "",
        notes: String = ""
    ) {
        self.name = name
        self.dateGiven = dateGiven
        self.expiresAt = expiresAt
        self.batchNumber = ""
        self.veterinarianName = veterinarianName
        self.notes = notes
    }

    var isExpired: Bool {
        guard let exp = expiresAt else { return false }
        return exp < .now
    }

    var isExpiringSoon: Bool {
        guard let exp = expiresAt else { return false }
        let thirtyDays = Date.now.addingTimeInterval(30 * 24 * 3600)
        return exp > .now && exp < thirtyDays
    }
}
