import Foundation
import Observation

@Observable
final class BZCGuardianProgress {

    // MARK: - State

    var totalPoints: Int = 0
    var unlockedAchievementIDs: Set<String> = []
    var careStreakDays: Int = 0
    var lastCareDate: Date?
    var totalCareActivities: Int = 0
    var articlesRead: Set<String> = []
    var aiConversationCount: Int = 0
    var vaccinationsLogged: Int = 0
    var journalEntryCount: Int = 0
    var totalPetsAdded: Int = 0
    var newlyUnlockedAchievements: [BZCAchievement] = []

    // MARK: - Computed

    var currentTier: BZCGuardianTier {
        BZCGuardianTier.allCases.last { $0.pointsRequired <= totalPoints } ?? .beginnerCaregiver
    }

    var nextTier: BZCGuardianTier? { currentTier.next }

    var progressToNextTier: Double {
        guard let next = nextTier else { return 1.0 }
        let current = currentTier.pointsRequired
        let range = Double(next.pointsRequired - current)
        guard range > 0 else { return 1.0 }
        let earned = Double(totalPoints - current)
        let ratio = earned / range
        return ratio < 1.0 ? ratio : 1.0
    }

    var pointsToNextTier: Int {
        guard let next = nextTier else { return 0 }
        return next.pointsRequired - totalPoints
    }

    var unlockedAchievements: [BZCAchievement] {
        BZCAchievement.allAchievements.filter { unlockedAchievementIDs.contains($0.id) }
    }

    var lockedAchievements: [BZCAchievement] {
        BZCAchievement.allAchievements.filter { !unlockedAchievementIDs.contains($0.id) }
    }

    // MARK: - Actions

    func recordCareActivity() {
        totalCareActivities += 1
        updateStreak()
        checkAndAward(for: .careActivitiesCount(totalCareActivities))
        addPoints(2)
    }

    func recordArticleRead(_ articleID: String) {
        guard !articlesRead.contains(articleID) else { return }
        articlesRead.insert(articleID)
        checkAndAward(for: .articlesRead(articlesRead.count))
        addPoints(5)
    }

    func recordAIConversation() {
        aiConversationCount += 1
        checkAndAward(for: .aiConversations(aiConversationCount))
        addPoints(3)
    }

    func recordVaccination() {
        vaccinationsLogged += 1
        checkAndAward(for: .vaccinationsLogged(vaccinationsLogged))
        addPoints(10)
    }

    func recordJournalEntry() {
        journalEntryCount += 1
        checkAndAward(for: .journalEntries(journalEntryCount))
        addPoints(3)
    }

    func recordPetAdded() {
        totalPetsAdded += 1
        checkAndAward(for: .petsAdded(totalPetsAdded))
        addPoints(15)
    }

    func clearNewAchievements() {
        newlyUnlockedAchievements.removeAll()
    }

    // MARK: - Private

    private func addPoints(_ amount: Int) {
        totalPoints += amount
    }

    private func updateStreak() {
        let today = Calendar.current.startOfDay(for: .now)
        if let last = lastCareDate {
            let lastDay = Calendar.current.startOfDay(for: last)
            let diff = Calendar.current.dateComponents([.day], from: lastDay, to: today).day ?? 0
            careStreakDays = diff == 1 ? careStreakDays + 1 : (diff == 0 ? careStreakDays : 1)
        } else {
            careStreakDays = 1
        }
        lastCareDate = .now
        checkAndAward(for: .careStreakDays(careStreakDays))
    }

    private func checkAndAward(for requirement: BZCAchievement.BZCAchievementRequirement) {
        let eligible = BZCAchievement.allAchievements.filter { achievement in
            guard !unlockedAchievementIDs.contains(achievement.id) else { return false }
            return isMet(requirement, for: achievement.requirement)
        }
        for achievement in eligible {
            unlockedAchievementIDs.insert(achievement.id)
            totalPoints += achievement.points
            newlyUnlockedAchievements.append(achievement)
        }
    }

    private func isMet(_ incoming: BZCAchievement.BZCAchievementRequirement,
                        for target: BZCAchievement.BZCAchievementRequirement) -> Bool {
        switch (incoming, target) {
        case (.careActivitiesCount(let a), .careActivitiesCount(let b)): a >= b
        case (.careStreakDays(let a), .careStreakDays(let b)):            a >= b
        case (.petsAdded(let a), .petsAdded(let b)):                     a >= b
        case (.articlesRead(let a), .articlesRead(let b)):               a >= b
        case (.aiConversations(let a), .aiConversations(let b)):         a >= b
        case (.vaccinationsLogged(let a), .vaccinationsLogged(let b)):   a >= b
        case (.journalEntries(let a), .journalEntries(let b)):           a >= b
        default: false
        }
    }
}
