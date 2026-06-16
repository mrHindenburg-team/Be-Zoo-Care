import SwiftData
import Foundation

@Model
final class BZCReminder {
    var title: String
    var careType: BZCCareType
    var dueDate: Date
    var repeatInterval: BZCReminderInterval
    var isDone: Bool
    var notes: String

    init(
        title: String,
        careType: BZCCareType,
        dueDate: Date,
        repeatInterval: BZCReminderInterval = .none,
        notes: String = ""
    ) {
        self.title = title
        self.careType = careType
        self.dueDate = dueDate
        self.repeatInterval = repeatInterval
        self.isDone = false
        self.notes = notes
    }

    var isOverdue: Bool { dueDate < .now && !isDone }
    var isDueToday: Bool {
        Calendar.current.isDateInToday(dueDate) && !isDone
    }
}

enum BZCReminderInterval: String, Codable, CaseIterable {
    case none    = "None"
    case daily   = "Daily"
    case weekly  = "Weekly"
    case monthly = "Monthly"
    case yearly  = "Yearly"
}
