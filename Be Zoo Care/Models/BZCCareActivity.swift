import SwiftData
import Foundation

@Model
final class BZCCareActivity {
    var type: BZCCareType
    var date: Date
    var durationMinutes: Int
    var notes: String
    var completedBy: String

    init(
        type: BZCCareType,
        date: Date = .now,
        durationMinutes: Int = 0,
        notes: String = "",
        completedBy: String = ""
    ) {
        self.type = type
        self.date = date
        self.durationMinutes = durationMinutes
        self.notes = notes
        self.completedBy = completedBy
    }
}
