import SwiftUI

enum BZCMascot: String, CaseIterable, Identifiable {
    case rhino, wolf, panda, owl, fox

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .rhino: "Rex"
        case .wolf: "Storm"
        case .panda: "Pax"
        case .owl: "Sage"
        case .fox: "Finn"
        }
    }

    var title: String {
        switch self {
        case .rhino: "Health Guardian"
        case .wolf: "Routine Master"
        case .panda: "Comfort Keeper"
        case .owl: "Knowledge Sage"
        case .fox: "Smart Advisor"
        }
    }

    var specialty: String {
        switch self {
        case .rhino: "Health & Protection"
        case .wolf: "Routines & Discipline"
        case .panda: "Comfort & Wellbeing"
        case .owl: "Education & Knowledge"
        case .fox: "Smart Tips & Optimization"
        }
    }

    var emoji: String {
        switch self {
        case .rhino: "🦏"
        case .wolf: "🐺"
        case .panda: "🐼"
        case .owl: "🦉"
        case .fox: "🦊"
        }
    }

    var symbolName: String {
        switch self {
        case .rhino: "shield.fill"
        case .wolf:  "bolt.fill"
        case .panda: "heart.fill"
        case .owl:   "graduationcap.fill"
        case .fox:   "brain.head.profile"
        }
    }

    var accentColor: Color {
        switch self {
        case .rhino: BZCColors.emeraldGreen
        case .wolf:  Color(red: 0.35, green: 0.55, blue: 0.95)
        case .panda: Color(red: 0.85, green: 0.35, blue: 0.75)
        case .owl:   BZCColors.richGold
        case .fox:   Color(red: 0.95, green: 0.45, blue: 0.18)
        }
    }

    var backgroundGradient: LinearGradient {
        switch self {
        case .rhino:
            LinearGradient(colors: [BZCColors.emeraldGreen, Color(red: 0.039, green: 0.447, blue: 0.282)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        case .wolf:
            LinearGradient(colors: [Color(red: 0.35, green: 0.55, blue: 0.95), Color(red: 0.18, green: 0.30, blue: 0.75)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        case .panda:
            LinearGradient(colors: [Color(red: 0.85, green: 0.35, blue: 0.75), Color(red: 0.55, green: 0.18, blue: 0.55)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        case .owl:
            LinearGradient(colors: [BZCColors.richGold, BZCColors.warmGold],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        case .fox:
            LinearGradient(colors: [Color(red: 0.95, green: 0.45, blue: 0.18), Color(red: 0.75, green: 0.25, blue: 0.05)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    var welcomeMessage: String {
        switch self {
        case .rhino: "I'll keep your pets healthy and protected. Track vaccinations, medications, and health records with me."
        case .wolf:  "Discipline creates healthy habits. Together we'll build perfect daily routines for your animals."
        case .panda: "Every animal deserves comfort and joy. Let me help you create the perfect emotional environment."
        case .owl:   "Knowledge is the foundation of great care. Explore our vast library of animal education."
        case .fox:   "Smart care makes all the difference. I'll show you expert tips to optimize your pet's wellness."
        }
    }

    var educationCategories: [BZCEducationalCategory] {
        switch self {
        case .rhino: [.health, .preventiveCare, .grooming]
        case .wolf:  [.routines, .training, .exercise]
        case .panda: [.wellbeing, .enrichment, .behavior]
        case .owl:   [.nutrition, .petSafety, .seniorCare]
        case .fox:   [.smartTips, .youngAnimals, .multiPet]
        }
    }
}
