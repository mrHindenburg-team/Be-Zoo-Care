enum SubscriptionID: String, CaseIterable {
    case expertPack = "BeZooCare.expert.pack"
    case guardianPack = "BeZooCare.guardian.pack"

    var displayName: String {
        switch self {
        case .expertPack:    "Animal Expert Pack"
        case .guardianPack:  "Zoo Guardian Pack"
        }
    }

    var tagline: String {
        switch self {
        case .expertPack:    "Unlimited AI · Charts · Weight Analytics"
        case .guardianPack:  "Full Journal · All Achievements · Tiers"
        }
    }

    var iconName: String {
        switch self {
        case .expertPack:    "brain.head.profile"
        case .guardianPack:  "crown.fill"
        }
    }

    // Features shown in the store card
    var features: [String] {
        switch self {
        case .expertPack:
            [
                "Unlimited AI Animal Mentor responses",
                "Advanced weekly wellness bar charts",
                "Full weight history & trend graphs",
                "Detailed health & analytics dashboards",
                "Entire premium educational library",
                "AI-powered species care recommendations"
            ]
        case .guardianPack:
            [
                "Unlimited pet journal entries & moods",
                "Full mood history timeline & export",
                "Complete Zoo Guardian tier progression",
                "All 11 achievement unlocks & rewards",
                "Advanced milestone tracking & categories",
                "Exclusive mascot guide interactions"
            ]
        }
    }

    // What is locked without this pack — shown on locked feature overlays
    var lockedMessage: String {
        switch self {
        case .expertPack:
            "Unlock with the Animal Expert Pack"
        case .guardianPack:
            "Unlock with the Zoo Guardian Pack"
        }
    }

    // Short badge shown in-app next to locked features
    var lockBadge: String {
        switch self {
        case .expertPack:   "Expert Pack"
        case .guardianPack: "Guardian Pack"
        }
    }
}
