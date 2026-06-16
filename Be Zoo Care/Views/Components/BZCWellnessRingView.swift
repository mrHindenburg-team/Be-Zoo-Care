import SwiftUI

struct BZCWellnessRingView: View {
    let score: Double
    let size: CGFloat
    var showLabel: Bool = true
    var lineWidth: CGFloat = 8

    @State private var animatedScore: Double = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var ringColor: Color {
        if score >= 0.8 { BZCColors.emeraldGreen }
        else if score >= 0.5 { BZCColors.richGold }
        else { BZCColors.warningOrange }
    }

    private var percentage: Int { Int(score * 100) }

    var body: some View {
        ZStack {
            Circle()
                .stroke(BZCColors.glassBackground, lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: reduceMotion ? score : animatedScore)
                .stroke(
                    ringColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(BZCMotion.springDefault, value: animatedScore)

            if showLabel {
                VStack(spacing: 0) {
                    Text("\(percentage)")
                        .font(.system(size: size * 0.24, weight: .bold, design: .rounded))
                        .foregroundStyle(ringColor)
                    Text("%")
                        .font(.system(size: size * 0.12))
                        .foregroundStyle(BZCColors.textTertiary)
                }
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            animatedScore = score
        }
        .onChange(of: score) {
            animatedScore = score
        }
        .accessibilityLabel("Wellness score: \(percentage) percent")
        .accessibilityValue(ringColor == BZCColors.emeraldGreen ? "Good" : ringColor == BZCColors.richGold ? "Fair" : "Needs attention")
    }
}

#Preview {
    ZStack {
        BZCColors.gradientBackground.ignoresSafeArea()
        HStack(spacing: 30) {
            BZCWellnessRingView(score: 0.9, size: 100)
            BZCWellnessRingView(score: 0.6, size: 100)
            BZCWellnessRingView(score: 0.3, size: 100)
        }
    }
}
