import SwiftUI

enum BZCGuardianTier: Int, Codable, CaseIterable {
    case beginnerCaregiver = 0
    case trustedCompanion  = 1
    case animalExpert      = 2
    case sanctuaryKeeper   = 3
    case zooGuardian       = 4

    var displayName: String {
        switch self {
        case .beginnerCaregiver: "Beginner Caregiver"
        case .trustedCompanion:  "Trusted Companion"
        case .animalExpert:      "Animal Expert"
        case .sanctuaryKeeper:   "Sanctuary Keeper"
        case .zooGuardian:       "Zoo Guardian"
        }
    }

    var badge: String {
        switch self {
        case .beginnerCaregiver: "🌱"
        case .trustedCompanion:  "🌿"
        case .animalExpert:      "⭐"
        case .sanctuaryKeeper:   "🏡"
        case .zooGuardian:       "👑"
        }
    }

    var symbolName: String {
        switch self {
        case .beginnerCaregiver: "leaf.fill"
        case .trustedCompanion:  "heart.fill"
        case .animalExpert:      "star.fill"
        case .sanctuaryKeeper:   "house.fill"
        case .zooGuardian:       "crown.fill"
        }
    }

    var pointsRequired: Int {
        switch self {
        case .beginnerCaregiver: 0
        case .trustedCompanion:  100
        case .animalExpert:      300
        case .sanctuaryKeeper:   700
        case .zooGuardian:       1500
        }
    }

    var accentColor: Color {
        switch self {
        case .beginnerCaregiver: BZCColors.emeraldGreen
        case .trustedCompanion:  Color(red: 0.35, green: 0.55, blue: 0.95)
        case .animalExpert:      BZCColors.royalPurple
        case .sanctuaryKeeper:   BZCColors.richGold
        case .zooGuardian:       BZCColors.warmGold
        }
    }

    var description: String {
        switch self {
        case .beginnerCaregiver:
            "You're just starting your journey. Learn the basics of animal care."
        case .trustedCompanion:
            "Your pets trust you. You've built strong daily routines."
        case .animalExpert:
            "You have deep knowledge across multiple species and care areas."
        case .sanctuaryKeeper:
            "You run a true sanctuary of wellness and love for animals."
        case .zooGuardian:
            "The highest honor. You are a master of all things animal care."
        }
    }

    var next: BZCGuardianTier? {
        BZCGuardianTier(rawValue: rawValue + 1)
    }
}
