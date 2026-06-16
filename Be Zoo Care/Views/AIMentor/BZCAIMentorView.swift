import SwiftUI

struct BZCAIMentorView: View {
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @Environment(BZCGuardianProgress.self) private var progress

    @State private var mentor: BZCAnimalCareMentor?
    @State private var showDisclaimer = false
    @State private var inputText = ""

    var body: some View {
        NavigationStack {
            ZStack {
                BZCColors.gradientBackground.ignoresSafeArea()

                Group {
                    if let mentor {
                        chatInterface(mentor: mentor)
                    } else {
                        loadingView
                    }
                }
            }
            .navigationTitle("AI Animal Mentor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    BZCMascotView(mascot: .fox, size: 32, showName: false, isAnimated: true)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if let mentor, !mentor.hasExpertPack {
                        freeTierBadge(remaining: mentor.remainingFreeResponses)
                    }
                }
            }
            .sheet(isPresented: $showDisclaimer) {
                BZCAIDisclaimerView {
                    showDisclaimer = false
                    mentor?.hasShownDisclaimer = true
                }
                .presentationDetents([.large])
            }
        }
        .task { setupMentor() }
    }

    // MARK: - Chat Interface

    private func chatInterface(mentor: BZCAnimalCareMentor) -> some View {
        VStack(spacing: 0) {
            if !mentor.hasExpertPack && mentor.aiResponseCount >= BZCAnimalCareMentor.freeResponseLimit {
                freeToOfflineNotice
            }

            messageList(mentor: mentor)

            inputBar(mentor: mentor)
        }
    }

    private func messageList(mentor: BZCAnimalCareMentor) -> some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: BZCLayout.spacingDefault) {
                    ForEach(mentor.messages) { message in
                        BZCChatBubble(message: message)
                            .id(message.id)
                    }

                    if mentor.isGenerating {
                        BZCTypingIndicator()
                            .id("typing")
                    }
                }
                .padding(BZCLayout.paddingDefault)
                .padding(.bottom, 20)
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: mentor.messages.count) {
                withAnimation(BZCMotion.easeDefault) {
                    if mentor.isGenerating {
                        proxy.scrollTo("typing")
                    } else if let lastID = mentor.messages.last?.id {
                        proxy.scrollTo(lastID)
                    }
                }
            }
        }
    }

    private func inputBar(mentor: BZCAnimalCareMentor) -> some View {
        BZCChatInputBar(mentor: mentor)
    }

    // MARK: - Supporting Views

    private var loadingView: some View {
        VStack(spacing: BZCLayout.spacingLarge) {
            BZCMascotView(mascot: .fox, size: 90, showName: true, isAnimated: true)
            Text("Preparing your AI Mentor…")
                .font(.subheadline)
                .foregroundStyle(BZCColors.textSecondary)
        }
    }

    private var freeToOfflineNotice: some View {
        HStack(spacing: BZCLayout.spacingSmall) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(BZCColors.richGold)
            Text("Using offline guidance. Upgrade to Expert Pack for unlimited AI responses.")
                .font(.caption)
                .foregroundStyle(BZCColors.textSecondary)
            Spacer()
        }
        .padding(BZCLayout.paddingDefault)
        .background(BZCColors.richGold.opacity(0.10))
    }

    private func freeTierBadge(remaining: Int) -> some View {
        Text("\(remaining) AI left")
            .font(.caption2.bold())
            .foregroundStyle(BZCColors.richGold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(BZCColors.richGold.opacity(0.15), in: Capsule())
    }

    // MARK: - Setup

    private func setupMentor() {
        guard mentor == nil else { return }
        let m = BZCAnimalCareMentor(subscriptionManager: subscriptionManager)
        mentor = m
        if !m.hasShownDisclaimer {
            showDisclaimer = true
        }
    }
}

// MARK: - Chat Bubble

struct BZCChatBubble: View {
    let message: BZCChatMessage

    var isUser: Bool { message.role == .user }

    var body: some View {
        HStack(alignment: .bottom, spacing: BZCLayout.spacingSmall) {
            if isUser { Spacer(minLength: 60) }

            if !isUser {
                BZCMascotView(mascot: .fox, size: 32, showName: false, isAnimated: false)
                    .accessibilityHidden(true)
            }

            BZCMessageContent(message: message, isUser: isUser)

            if isUser {
                Image(systemName: "person.circle.fill")
                    .font(.title3)
                    .foregroundStyle(BZCColors.royalPurple)
                    .accessibilityHidden(true)
            } else {
                Spacer(minLength: 60)
            }
        }
    }
}

struct BZCMessageContent: View {
    let message: BZCChatMessage
    let isUser: Bool

    var body: some View {
        Text(message.content)
            .font(.subheadline)
            .foregroundStyle(isUser ? BZCColors.darkBackground : BZCColors.textPrimary)
            .padding(.horizontal, BZCLayout.paddingDefault)
            .padding(.vertical, BZCLayout.paddingSmall)
            .background(
                isUser
                    ? AnyShapeStyle(BZCColors.gradientGold)
                    : AnyShapeStyle(BZCColors.glassBackground)
            )
            .clipShape(.rect(cornerRadius: BZCLayout.cornerRadiusLarge))
            .overlay {
                if !isUser {
                    RoundedRectangle(cornerRadius: BZCLayout.cornerRadiusLarge)
                        .strokeBorder(BZCColors.glassBorder, lineWidth: 1)
                }
            }
    }
}

// MARK: - Typing Indicator

struct BZCTypingIndicator: View {
    @State private var isAnimating = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(alignment: .bottom, spacing: BZCLayout.spacingSmall) {
            BZCMascotView(mascot: .fox, size: 32, showName: false, isAnimated: false)
                .accessibilityHidden(true)

            HStack(spacing: 6) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(BZCColors.textTertiary)
                        .frame(width: 8, height: 8)
                        .scaleEffect(isAnimating ? 1.4 : 1.0)
                        .animation(
                            reduceMotion ? nil : .easeInOut(duration: 0.4).repeatForever(autoreverses: true).delay(Double(i) * 0.15),
                            value: isAnimating
                        )
                }
            }
            .padding(.horizontal, BZCLayout.paddingDefault)
            .padding(.vertical, BZCLayout.paddingSmall)
            .background(BZCColors.glassBackground, in: RoundedRectangle(cornerRadius: BZCLayout.cornerRadiusLarge))
            .overlay {
                RoundedRectangle(cornerRadius: BZCLayout.cornerRadiusLarge)
                    .strokeBorder(BZCColors.glassBorder, lineWidth: 1)
            }

            Spacer(minLength: 60)
        }
        .onAppear {
            guard !reduceMotion else { return }
            isAnimating = true
        }
        .accessibilityLabel("AI is generating a response")
    }
}

#Preview {
    BZCAIMentorView()
        .environment(SubscriptionManager())
        .environment(BZCGuardianProgress())
}
