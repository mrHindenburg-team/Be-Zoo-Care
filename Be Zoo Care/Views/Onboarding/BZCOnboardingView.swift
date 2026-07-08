import SwiftUI


struct BZCOnboardingView: View {
    var onComplete: () -> Void

    @State private var currentPage: Int = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let slides: [BZCOnboardingSlide] = BZCOnboardingSlide.allSlides

    var body: some View {
        ZStack {
            BZCColors.gradientHero.ignoresSafeArea()

            VStack(spacing: 0) {
                skipButton
                    .padding(.horizontal, BZCLayout.paddingLarge)
                    .padding(.top, BZCLayout.paddingDefault)

                TabView(selection: $currentPage) {
                    ForEach(Array(slides.enumerated()), id: \.offset) { index, slide in
                        BZCOnboardingSlideView(slide: slide)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(BZCMotion.easeDefault, value: currentPage)

                bottomControls
                    .padding(.horizontal, BZCLayout.paddingLarge)
                    .padding(.bottom, 48)
            }
        }
    }

    // MARK: - Controls

    private var skipButton: some View {
        HStack {
            Spacer()
            Button("Skip", action: onComplete)
                .font(.subheadline)
                .foregroundStyle(BZCColors.textSecondary)
                .frame(minWidth: BZCLayout.minTapTarget, minHeight: BZCLayout.minTapTarget)
        }
    }

    private var bottomControls: some View {
        VStack(spacing: BZCLayout.spacingLarge) {
            pageIndicator
            actionButton
        }
    }

    @ViewBuilder
    private var actionButton: some View {
        if currentPage == slides.count - 1 {
            Button(action: onComplete) {
                Text("Start My Journey")
                    .font(.headline.bold())
                    .foregroundStyle(BZCColors.darkBackground)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(BZCColors.gradientGold, in: RoundedRectangle(cornerRadius: BZCLayout.cornerRadiusLarge))
            }
            .sensoryFeedback(.success, trigger: currentPage == slides.count - 1)
        } else {
            Button(action: advancePage) {
                Text("Continue")
                    .font(.headline)
                    .foregroundStyle(BZCColors.darkBackground)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(BZCColors.gradientGold, in: RoundedRectangle(cornerRadius: BZCLayout.cornerRadiusLarge))
            }
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(slides.indices, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? BZCColors.richGold : BZCColors.glassBorder)
                    .frame(width: index == currentPage ? 24 : 8, height: 8)
                    .animation(BZCMotion.springDefault, value: currentPage)
            }
        }
    }

    // MARK: - Actions

    private func advancePage() {
        withAnimation(BZCMotion.easeDefault) {
            currentPage = min(currentPage + 1, slides.count - 1)
        }
    }
}

// MARK: - Slide Data

struct BZCOnboardingSlide {
    let mascot: BZCMascot
    let title: String
    let subtitle: String
    let features: [String]
    let accentColor: Color

    static let allSlides: [BZCOnboardingSlide] = [
        BZCOnboardingSlide(
            mascot: .panda,
            title: "Your Pet's Universe",
            subtitle: "Five expert guides, one complete care system",
            features: [
                "Meet Rex, Storm, Pax, Sage & Finn",
                "Each mascot specializes in animal care",
                "Personalized guidance for every species",
                "Your companions on the care journey"
            ],
            accentColor: BZCColors.royalPurple
        ),
        BZCOnboardingSlide(
            mascot: .fox,
            title: "AI Animal Mentor",
            subtitle: "Powered entirely on your device",
            features: [
                "Ask any animal care question",
                "Works completely offline — no internet needed",
                "Your conversations never leave your device",
                "Expert answers powered by Apple Intelligence"
            ],
            accentColor: Color(red: 0.95, green: 0.45, blue: 0.18)
        ),
        BZCOnboardingSlide(
            mascot: .rhino,
            title: "Zoo Guardian Journey",
            subtitle: "Grow from Beginner to Zoo Guardian",
            features: [
                "Earn points for every care activity",
                "11 achievements to unlock as you grow",
                "5 guardian tiers from Beginner to Master",
                "Become the ultimate animal guardian"
            ],
            accentColor: BZCColors.richGold
        )
    ]
}

// MARK: - Standard Slide View

struct BZCOnboardingSlideView: View {
    let slide: BZCOnboardingSlide

    @State private var contentOffset: Double = 30
    @State private var contentOpacity: Double = 0

    var body: some View {
        ScrollView {
            VStack(spacing: BZCLayout.spacingLarge) {
                BZCMascotView(mascot: slide.mascot, size: 120, showName: true, isAnimated: true)
                    .padding(.top, BZCLayout.paddingLarge)

                VStack(spacing: BZCLayout.spacingSmall) {
                    Text(slide.title)
                        .font(.title.bold())
                        .foregroundStyle(BZCColors.textPrimary)
                        .multilineTextAlignment(.center)

                    Text(slide.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(BZCColors.textSecondary)
                        .multilineTextAlignment(.center)
                }

                if !slide.features.isEmpty {
                    VStack(alignment: .leading, spacing: BZCLayout.spacingSmall) {
                        ForEach(Array(slide.features.enumerated()), id: \.offset) { index, feature in
                            BZCFeatureRow(text: feature, color: slide.accentColor, delay: Double(index) * 0.1)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(BZCLayout.cardPadding)
                    .background(
                        RoundedRectangle(cornerRadius: BZCLayout.cornerRadiusLarge)
                            .fill(BZCColors.glassBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: BZCLayout.cornerRadiusLarge)
                                    .strokeBorder(slide.accentColor.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, BZCLayout.paddingDefault)
                }
            }
            .padding(.bottom, 20)
        }
        .scrollIndicators(.hidden)
        .offset(y: contentOffset)
        .opacity(contentOpacity)
        .onAppear {
            withAnimation(BZCMotion.springDefault.delay(0.1)) {
                contentOffset = 0
                contentOpacity = 1
            }
        }
    }
}

struct BZCFeatureRow: View {
    let text: String
    let color: Color
    let delay: Double

    @State private var appeared = false

    var body: some View {
        HStack(spacing: BZCLayout.spacingDefault) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(color)
                .font(.body)
                .frame(width: 24, height: 24)

            Text(text)
                .font(.subheadline)
                .foregroundStyle(BZCColors.textSecondary)
        }
        .opacity(appeared ? 1 : 0)
        .offset(x: appeared ? 0 : -20)
        .onAppear {
            withAnimation(BZCMotion.springDefault.delay(delay + 0.3)) {
                appeared = true
            }
        }
    }
}

#Preview {
    BZCOnboardingView(onComplete: {})
}
