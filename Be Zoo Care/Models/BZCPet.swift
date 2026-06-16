import SwiftData
import Foundation
import SwiftUI

@Model
final class BZCPet {
    var name: String
    var species: BZCSpecies
    var breed: String
    var dateOfBirth: Date?
    var adoptionDate: Date?
    var gender: BZCGender
    var weightKg: Double
    var photoData: Data?
    var notes: String
    var isArchived: Bool
    var cardColorHex: String

    @Relationship(deleteRule: .cascade) var careActivities: [BZCCareActivity]
    @Relationship(deleteRule: .cascade) var healthRecords: [BZCHealthRecord]
    @Relationship(deleteRule: .cascade) var vaccinations: [BZCVaccination]
    @Relationship(deleteRule: .cascade) var medications: [BZCMedication]
    @Relationship(deleteRule: .cascade) var weightEntries: [BZCWeightEntry]
    @Relationship(deleteRule: .cascade) var vetVisits: [BZCVetVisit]
    @Relationship(deleteRule: .cascade) var milestones: [BZCMilestone]
    @Relationship(deleteRule: .cascade) var journalEntries: [BZCJournalEntry]
    @Relationship(deleteRule: .cascade) var reminders: [BZCReminder]

    init(
        name: String,
        species: BZCSpecies,
        breed: String = "",
        gender: BZCGender = .unknown,
        weightKg: Double = 0
    ) {
        self.name = name
        self.species = species
        self.breed = breed
        self.gender = gender
        self.weightKg = weightKg
        self.notes = ""
        self.isArchived = false
        self.cardColorHex = BZCPet.colorOptions.randomElement() ?? "#7330C0"
        self.careActivities = []
        self.healthRecords = []
        self.vaccinations = []
        self.medications = []
        self.weightEntries = []
        self.vetVisits = []
        self.milestones = []
        self.journalEntries = []
        self.reminders = []
    }

    static let colorOptions = [
        "#7330C0", "#2E5D8E", "#1E8A5A",
        "#C0392B", "#8E44AD", "#D35400",
        "#16A085", "#2980B9"
    ]

    var ageDescription: String {
        guard let dob = dateOfBirth else { return "Age unknown" }
        let components = Calendar.current.dateComponents([.year, .month], from: dob, to: .now)
        let years = components.year ?? 0
        let months = components.month ?? 0
        if years > 0 { return "\(years) yr\(years == 1 ? "" : "s")" }
        return "\(months) mo\(months == 1 ? "" : "s")"
    }

    var cardColor: Color {
        Color(hex: cardColorHex) ?? BZCColors.royalPurple
    }

    var todaysCareCount: Int {
        let today = Calendar.current.startOfDay(for: .now)
        return careActivities.count(where: { $0.date >= today })
    }

    var wellnessScore: Double {
        let today = Calendar.current.startOfDay(for: .now)
        let recentCount = careActivities.count(where: { $0.date >= today })
        let base = min(0.75, Double(recentCount) / 5.0)
        let hasActiveReminders = !reminders.filter { !$0.isDone && $0.dueDate > .now }.isEmpty
        let hasValidVaccines = vaccinations.contains { v in
            if let exp = v.expiresAt { return exp > .now }
            return false
        }
        let bonus = (hasActiveReminders ? 0.10 : 0.0) + (hasValidVaccines ? 0.15 : 0.0)
        return min(1.0, base + bonus)
    }
}
