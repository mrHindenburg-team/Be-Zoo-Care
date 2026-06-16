import SwiftData
import Foundation

@Model
final class BZCVetVisit {
    var date: Date
    var reason: String
    var clinicName: String
    var veterinarianName: String
    var diagnosis: String
    var followUpDate: Date?
    var cost: Double
    var notes: String

    init(
        date: Date = .now,
        reason: String,
        clinicName: String = "",
        veterinarianName: String = "",
        diagnosis: String = "",
        cost: Double = 0
    ) {
        self.date = date
        self.reason = reason
        self.clinicName = clinicName
        self.veterinarianName = veterinarianName
        self.diagnosis = diagnosis
        self.cost = cost
        self.notes = ""
    }
}
