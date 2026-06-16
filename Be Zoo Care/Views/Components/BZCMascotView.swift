import SwiftUI

struct BZCMascotView: View {
    let mascot: BZCMascot
    let size: CGFloat
    var showName: Bool = false
    var isAnimated: Bool = true
    var isCompact: Bool = false

    @State private var isFloating = false
    @State private var isGlowing = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: BZCLayout.spacingSmall) {
            mascotEmoji
            if showName {
                VStack(spacing: 2) {
                    Text(mascot.displayName)
                        .font(.caption.bold())
                        .foregroundStyle(BZCColors.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    if !isCompact {
                        Text(mascot.title)
                            .font(.caption2)
                            .foregroundStyle(BZCColors.textTertiary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }
                }
            }
        }
        .onAppear {
            guard isAnimated && !reduceMotion else { return }
            withAnimation(
                .easeInOut(duration: BZCMotion.floatDuration)
                .repeatForever(autoreverses: true)
            ) {
                isFloating = true
            }
            withAnimation(
                .easeInOut(duration: BZCMotion.pulseDuration)
                .repeatForever(autoreverses: true)
            ) {
                isGlowing = true
            }
        }
        .accessibilityLabel("\(mascot.displayName), \(mascot.title)")
    }

    private var mascotEmoji: some View {
        ZStack {
            Circle()
                .fill(mascot.backgroundGradient)
                .frame(width: size, height: size)
                .shadow(
                    color: mascot.accentColor.opacity(isGlowing ? 0.6 : 0.3),
                    radius: isGlowing ? 16 : 8
                )
                .animation(.easeInOut(duration: BZCMotion.pulseDuration).repeatForever(autoreverses: true), value: isGlowing)

            Image(systemName: mascot.symbolName)
                .font(.system(size: size * 0.42, weight: .semibold))
                .foregroundStyle(.white)
                .offset(y: isFloating && !reduceMotion ? -4 : 0)
                .animation(.easeInOut(duration: BZCMotion.floatDuration).repeatForever(autoreverses: true), value: isFloating)
        }
    }
}

#Preview {
    ZStack {
        BZCColors.gradientBackground.ignoresSafeArea()
        HStack(spacing: 20) {
            ForEach(BZCMascot.allCases) { mascot in
                BZCMascotView(mascot: mascot, size: 60, showName: true)
            }
        }
        .padding()
    }
}
