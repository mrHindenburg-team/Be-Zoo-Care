import SwiftUI

enum BZCColors {
    // MARK: - Brand Core
    static let royalPurple   = Color(red: 0.451, green: 0.188, blue: 0.753)
    static let deepViolet    = Color(red: 0.235, green: 0.082, blue: 0.490)
    static let midViolet     = Color(red: 0.345, green: 0.133, blue: 0.616)
    static let emeraldGreen  = Color(red: 0.071, green: 0.651, blue: 0.416)
    static let richGold      = Color(red: 0.949, green: 0.749, blue: 0.200)
    static let warmGold      = Color(red: 1.000, green: 0.847, blue: 0.345)

    // MARK: - Backgrounds
    static let darkBackground   = Color(red: 0.063, green: 0.027, blue: 0.157)
    static let cardBackground   = Color(red: 0.141, green: 0.082, blue: 0.298).opacity(0.85)
    static let glassBackground  = Color.white.opacity(0.08)
    static let glassBorder      = Color.white.opacity(0.14)

    // MARK: - Text
    static let textPrimary   = Color.white
    static let textSecondary = Color.white.opacity(0.80)
    static let textTertiary  = Color.white.opacity(0.55)

    // MARK: - Status
    static let successGreen = Color(red: 0.18, green: 0.80, blue: 0.44)
    static let warningOrange = Color(red: 0.98, green: 0.58, blue: 0.12)
    static let errorRed = Color(red: 0.95, green: 0.27, blue: 0.27)

    // MARK: - Gradients
    static let gradientBackground = LinearGradient(
        colors: [darkBackground, Color(red: 0.102, green: 0.047, blue: 0.235)],
        startPoint: .top, endPoint: .bottom
    )

    static let gradientPurple = LinearGradient(
        colors: [royalPurple, deepViolet],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    static let gradientGold = LinearGradient(
        colors: [richGold, warmGold],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    static let gradientEmerald = LinearGradient(
        colors: [emeraldGreen, Color(red: 0.039, green: 0.447, blue: 0.282)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    static let gradientHero = LinearGradient(
        colors: [midViolet, darkBackground],
        startPoint: .top, endPoint: .bottom
    )

    static let gradientCard = LinearGradient(
        colors: [
            Color.white.opacity(0.10),
            Color.white.opacity(0.04)
        ],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
}
