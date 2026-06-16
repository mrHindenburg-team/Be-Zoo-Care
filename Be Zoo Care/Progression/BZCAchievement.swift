import Foundation

struct BZCAchievement: Identifiable {
    let id: String
    let title: String
    let details: String
    let badge: String
    let points: Int
    let category: BZCAchievementCategory
    let requirement: BZCAchievementRequirement

    enum BZCAchievementCategory: String {
        case care       = "Care"
        case health     = "Health"
        case education  = "Education"
        case streak     = "Streak"
        case milestone  = "Milestone"
        case ai         = "AI Mentor"

        var symbolName: String {
            switch self {
            case .care:      "heart.fill"
            case .health:    "cross.fill"
            case .education: "book.fill"
            case .streak:    "flame.fill"
            case .milestone: "flag.fill"
            case .ai:        "cpu.fill"
            }
        }
    }

    enum BZCAchievementRequirement {
        case careActivitiesCount(Int)
        case careStreakDays(Int)
        case petsAdded(Int)
        case articlesRead(Int)
        case aiConversations(Int)
        case vaccinationsLogged(Int)
        case journalEntries(Int)
    }
}

extension BZCAchievement {
    static let allAchievements: [BZCAchievement] = [
        BZCAchievement(
            id: "ach-first-pet",
            title: "First Family Member",
            details: "Add your first pet to Be Zoo Care",
            badge: "🐾",
            points: 10,
            category: .milestone,
            requirement: .petsAdded(1)
        ),
        BZCAchievement(
            id: "ach-pet-family",
            title: "Growing Family",
            details: "Add 3 or more pets to your care family",
            badge: "🏡",
            points: 25,
            category: .milestone,
            requirement: .petsAdded(3)
        ),
        BZCAchievement(
            id: "ach-first-care",
            title: "First Care",
            details: "Log your first care activity",
            badge: "✅",
            points: 5,
            category: .care,
            requirement: .careActivitiesCount(1)
        ),
        BZCAchievement(
            id: "ach-care-100",
            title: "Dedicated Caregiver",
            details: "Log 100 care activities",
            badge: "💯",
            points: 50,
            category: .care,
            requirement: .careActivitiesCount(100)
        ),
        BZCAchievement(
            id: "ach-streak-7",
            title: "Week Warrior",
            details: "Maintain a 7-day care streak",
            badge: "🔥",
            points: 30,
            category: .streak,
            requirement: .careStreakDays(7)
        ),
        BZCAchievement(
            id: "ach-streak-30",
            title: "Monthly Master",
            details: "Maintain a 30-day care streak",
            badge: "⚡",
            points: 100,
            category: .streak,
            requirement: .careStreakDays(30)
        ),
        BZCAchievement(
            id: "ach-educator-5",
            title: "Curious Mind",
            details: "Read 5 educational articles",
            badge: "📚",
            points: 20,
            category: .education,
            requirement: .articlesRead(5)
        ),
        BZCAchievement(
            id: "ach-educator-20",
            title: "Knowledge Seeker",
            details: "Read 20 educational articles",
            badge: "🎓",
            points: 60,
            category: .education,
            requirement: .articlesRead(20)
        ),
        BZCAchievement(
            id: "ach-ai-mentor",
            title: "AI Conversation",
            details: "Have your first AI mentoring session",
            badge: "🤖",
            points: 15,
            category: .ai,
            requirement: .aiConversations(1)
        ),
        BZCAchievement(
            id: "ach-vaccine-1",
            title: "Health Tracker",
            details: "Log your first vaccination record",
            badge: "💉",
            points: 10,
            category: .health,
            requirement: .vaccinationsLogged(1)
        ),
        BZCAchievement(
            id: "ach-journal-10",
            title: "Storyteller",
            details: "Write 10 journal entries",
            badge: "📝",
            points: 35,
            category: .milestone,
            requirement: .journalEntries(10)
        )
    ]
}
