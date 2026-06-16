import SwiftData
import Foundation

@Model
final class BZCHealthRecord {
    var date: Date
    var title: String
    var details: String
    var severity: BZCHealthSeverity
    var isResolved: Bool
    var resolvedDate: Date?
    var veterinarianName: String

    init(
        date: Date = .now,
        title: String,
        details: String = "",
        severity: BZCHealthSeverity = .mild,
        veterinarianName: String = ""
    ) {
        self.date = date
        self.title = title
        self.details = details
        self.severity = severity
        self.isResolved = false
        self.veterinarianName = veterinarianName
    }
}
