import SwiftUI

struct BZCSplashView: View {
    var onComplete: () -> Void

    @State private var logoScale: Double = 0.5
    @State private var logoOpacity: Double = 0
    @State private var titleOpacity: Double = 0
    @State private var mascotOffsets: [Double] = Array(repeating: 60, count: 5)
    @State private var mascotOpacities: [Double] = Array(repeating: 0, count: 5)
    @State private var particleOpacity: Double = 0
    @State private var ringScale: Double = 0.3
    @State private var ringOpacity: Double = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let mascots: [BZCMascot] = BZCMascot.allCases

    var body: some View {
        ZStack {
            BZCColors.gradientHero
                .ignoresSafeArea()

            if !reduceMotion {
                particles
            }

            VStack(spacing: 0) {
                Spacer()
                logoSection
                Spacer()
                mascotRow
                Spacer()
                tagline
                Spacer()
            }
        }
        .onAppear { animate() }
        .task { await waitAndComplete() }
    }

    // MARK: - Subviews

    private var logoSection: some View {
        VStack(spacing: BZCLayout.spacingLarge) {
            ZStack {
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [BZCColors.richGold.opacity(0.4), BZCColors.royalPurple.opacity(0.4)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 140, height: 140)
                    .scaleEffect(ringScale)
                    .opacity(ringOpacity)

                Image(systemName: "pawprint.fill")
                    .font(.system(size: 64, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [BZCColors.warmGold, BZCColors.richGold],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
            }

            VStack(spacing: 6) {
                Text("Be Zoo Care")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [BZCColors.warmGold, BZCColors.richGold],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                    .opacity(titleOpacity)

                Text("Your Complete Animal Care Universe")
                    .font(.subheadline)
                    .foregroundStyle(BZCColors.textSecondary)
                    .opacity(titleOpacity)
            }
        }
    }

    private var mascotRow: some View {
        HStack(spacing: BZCLayout.spacingLarge) {
            ForEach(Array(mascots.enumerated()), id: \.element.id) { index, mascot in
                BZCMascotView(
                    mascot: mascot,
                    size: 56,
                    showName: false,
                    isAnimated: false
                )
                .offset(y: mascotOffsets[index])
                .opacity(mascotOpacities[index])
            }
        }
        .padding(.horizontal, BZCLayout.paddingLarge)
    }

    private var tagline: some View {
        Text("Health · Routines · Learning · Care")
            .font(.caption)
            .tracking(2)
            .foregroundStyle(BZCColors.textTertiary)
            .opacity(titleOpacity)
            .padding(.bottom, 40)
    }

    private var particles: some View {
        GeometryReader { geometry in
            ForEach(0..<20, id: \.self) { i in
                Circle()
                    .fill(
                        (i % 3 == 0 ? BZCColors.richGold : i % 3 == 1 ? BZCColors.royalPurple : BZCColors.emeraldGreen)
                            .opacity(0.25)
                    )
                    .frame(width: Double.random(in: 4...10))
                    .position(
                        x: Double(i) / 20.0 * geometry.size.width + 20,
                        y: Double.random(in: 0...1) * geometry.size.height
                    )
                    .opacity(particleOpacity)
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Animation

    private func animate() {
        guard !reduceMotion else {
            logoScale = 1
            logoOpacity = 1
            titleOpacity = 1
            ringScale = 1
            ringOpacity = 1
            for i in mascots.indices {
                mascotOffsets[i] = 0
                mascotOpacities[i] = 1
            }
            scheduleComplete()
            return
        }

        withAnimation(.easeOut(duration: 0.7)) {
            logoScale = 1.0
            logoOpacity = 1.0
            ringScale = 1.2
            ringOpacity = 0.6
            particleOpacity = 1
        }

        withAnimation(.easeInOut(duration: 0.5).delay(0.5)) {
            titleOpacity = 1.0
        }

        for i in mascots.indices {
            withAnimation(BZCMotion.springBouncy.delay(0.8 + Double(i) * 0.12)) {
                mascotOffsets[i] = 0
                mascotOpacities[i] = 1
            }
        }

        scheduleComplete()
    }

    private func waitAndComplete() async {
        do { try await Task.sleep(for: .seconds(3.2)) }
        catch { return }
        withAnimation(BZCMotion.easeDefault) { onComplete() }
    }

    private func scheduleComplete() {
        // Completion is handled by the .task modifier
    }
}

#Preview {
    BZCSplashView(onComplete: {})
}
