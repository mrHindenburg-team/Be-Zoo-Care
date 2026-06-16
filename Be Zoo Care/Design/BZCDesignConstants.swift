import SwiftUI

enum BZCLayout {
    static let cornerRadius: CGFloat     = 16
    static let cornerRadiusSmall: CGFloat = 10
    static let cornerRadiusLarge: CGFloat = 24
    static let cornerRadiusXL: CGFloat   = 32
    static let paddingDefault: CGFloat   = 16
    static let paddingSmall: CGFloat     = 10
    static let paddingLarge: CGFloat     = 24
    static let spacingDefault: CGFloat   = 12
    static let spacingSmall: CGFloat     = 8
    static let spacingLarge: CGFloat     = 20
    static let minTapTarget: CGFloat     = 44
    static let cardPadding: CGFloat      = 18
}

enum BZCMotion {
    static let springDefault = Animation.spring(response: 0.50, dampingFraction: 0.72)
    static let springBouncy  = Animation.spring(response: 0.40, dampingFraction: 0.60)
    static let springStiff   = Animation.spring(response: 0.35, dampingFraction: 0.82)
    static let easeDefault   = Animation.easeInOut(duration: 0.30)
    static let easeSlow      = Animation.easeInOut(duration: 0.60)
    static let breatheDuration: Double = 4.0
    static let floatDuration: Double   = 2.8
    static let pulseDuration: Double   = 1.6
}
