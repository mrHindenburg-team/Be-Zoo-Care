import SwiftUI
import Observation

@Observable
final class BZCDashboardViewModel {

    struct WeeklyDataPoint: Identifiable {
        let id = UUID()
        let day: String
        let activities: Int
        let wellnessScore: Double
    }

    func weeklyData(for pet: BZCPet?) -> [WeeklyDataPoint] {
        let calendar = Calendar.current
        let dayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

        return (0..<7).map { offset in
            let date = calendar.date(byAdding: .day, value: -(6 - offset), to: .now) ?? .now
            let dayStart = calendar.startOfDay(for: date)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) ?? dayStart

            var count = 0
            if let p = pet {
                count = p.careActivities.count(where: { $0.date >= dayStart && $0.date < dayEnd })
            }

            let dayIndex = (calendar.component(.weekday, from: date) + 5) % 7
            let label = dayNames[min(dayIndex, 6)]
            let wellness = min(1.0, Double(count) / 5.0)

            return WeeklyDataPoint(day: label, activities: count, wellnessScore: wellness)
        }
    }

    func overallWellness(for pets: [BZCPet]) -> Double {
        guard !pets.isEmpty else { return 0 }
        let scores = pets.map(\.wellnessScore)
        return scores.reduce(0, +) / Double(scores.count)
    }

    func totalActivitiesToday(for pets: [BZCPet]) -> Int {
        pets.reduce(0) { $0 + $1.todaysCareCount }
    }

    func upcomingReminders(for pets: [BZCPet]) -> [(BZCPet, BZCReminder)] {
        var pairs: [(BZCPet, BZCReminder)] = []
        for pet in pets {
            let active = pet.reminders.filter { !$0.isDone && $0.dueDate > .now }
            let sorted = active.sorted { $0.dueDate < $1.dueDate }
            for reminder in sorted.prefix(3) {
                pairs.append((pet, reminder))
            }
        }
        return pairs.sorted { $0.1.dueDate < $1.1.dueDate }.prefix(5).map { $0 }
    }

    func expiringVaccinations(for pets: [BZCPet]) -> [(BZCPet, BZCVaccination)] {
        var pairs: [(BZCPet, BZCVaccination)] = []
        for pet in pets {
            for vax in pet.vaccinations where vax.isExpiringSoon || vax.isExpired {
                pairs.append((pet, vax))
            }
        }
        return pairs
    }
}
