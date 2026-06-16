import SwiftData
import Foundation

@Model
final class BZCMedication {
    var name: String
    var dosage: String
    var frequency: String
    var startDate: Date
    var endDate: Date?
    var isActive: Bool
    var notes: String
    var prescribedBy: String

    init(
        name: String,
        dosage: String = "",
        frequency: String = "Daily",
        startDate: Date = .now,
        endDate: Date? = nil,
        prescribedBy: String = "",
        notes: String = ""
    ) {
        self.name = name
        self.dosage = dosage
        self.frequency = frequency
        self.startDate = startDate
        self.endDate = endDate
        self.isActive = true
        self.prescribedBy = prescribedBy
        self.notes = notes
    }
}
