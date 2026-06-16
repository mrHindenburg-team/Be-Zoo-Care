import SwiftUI

struct BZCAIDisclaimerView: View {
    var onContinue: () -> Void

    @State private var appeared = false

    var body: some View {
        ZStack {
            BZCColors.gradientBackground.ignoresSafeArea()
                .opacity(0.95)

            ScrollView {
            VStack(spacing: BZCLayout.spacingLarge) {
                Spacer(minLength: BZCLayout.spacingDefault)

                VStack(spacing: BZCLayout.spacingDefault) {
                    BZCMascotView(mascot: .fox, size: 90, showName: true, isAnimated: true)

                    Text("Meet Your AI Animal Mentor")
                        .font(.title2.bold())
                        .foregroundStyle(BZCColors.textPrimary)
                        .multilineTextAlignment(.center)

                    Text("Before we start, here's what you need to know:")
                        .font(.subheadline)
                        .foregroundStyle(BZCColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)

                VStack(spacing: BZCLayout.spacingSmall) {
                    disclaimerRow(
                        icon: "lock.shield.fill",
                        color: BZCColors.emeraldGreen,
                        title: "100% Private",
                        detail: "Your conversations never leave your device. No data is sent to any server."
                    )
                    disclaimerRow(
                        icon: "wifi.slash",
                        color: Color(red: 0.35, green: 0.55, blue: 0.95),
                        title: "Works Offline",
                        detail: "The AI runs entirely on-device using Apple's on-device intelligence."
                    )
                    disclaimerRow(
                        icon: "exclamationmark.triangle.fill",
                        color: BZCColors.richGold,
                        title: "Not a Vet",
                        detail: "AI advice supplements but does not replace professional veterinary care."
                    )
                    disclaimerRow(
                        icon: "iphone.gen3",
                        color: BZCColors.royalPurple,
                        title: "Device Requirements",
                        detail: "Full AI requires iOS 26 and Apple Intelligence. Offline guidance is always available."
                    )
                }
                .padding(BZCLayout.cardPadding)
                .background(
                    RoundedRectangle(cornerRadius: BZCLayout.cornerRadiusLarge)
                        .fill(BZCColors.glassBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: BZCLayout.cornerRadiusLarge)
                                .strokeBorder(BZCColors.glassBorder, lineWidth: 1)
                        )
                )
                .padding(.horizontal, BZCLayout.paddingDefault)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 30)

                Spacer(minLength: BZCLayout.spacingDefault)

                Button(action: onContinue) {
                    Text("I Understand — Let's Go!")
                        .font(.headline.bold())
                        .foregroundStyle(BZCColors.darkBackground)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(BZCColors.gradientGold, in: RoundedRectangle(cornerRadius: BZCLayout.cornerRadiusLarge))
                }
                .padding(.horizontal, BZCLayout.paddingLarge)
                .padding(.bottom, 48)
                .opacity(appeared ? 1 : 0)
            }
            } // ScrollView
        }
        .onAppear {
            withAnimation(BZCMotion.springDefault.delay(0.2)) { appeared = true }
        }
    }

    private func disclaimerRow(icon: String, color: Color, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: BZCLayout.spacingDefault) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(color)
                .frame(width: 28, height: 28)
                .background(color.opacity(0.15), in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundStyle(BZCColors.textPrimary)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(BZCColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview {
    BZCAIDisclaimerView(onContinue: {})
}
