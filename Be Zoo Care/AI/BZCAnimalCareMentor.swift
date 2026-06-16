import Foundation
import Observation

@Observable
final class BZCAnimalCareMentor {

    // MARK: - State

    var messages: [BZCChatMessage] = []
    var inputText: String = ""
    var isGenerating: Bool = false
    var errorMessage: String?
    var aiResponseCount: Int = 0
    var hasShownDisclaimer: Bool = false
    var isVoiceRecording: Bool = false

    // MARK: - Private

    @ObservationIgnored private let fallback = BZCFallbackCareEngine()
    @ObservationIgnored private var foundationSession: Any? // BZCFoundationModelsSession on iOS 26+
    @ObservationIgnored private let subscriptionManager: SubscriptionManager

    static let freeResponseLimit = 5

    // MARK: - Init

    init(subscriptionManager: SubscriptionManager) {
        self.subscriptionManager = subscriptionManager
        insertWelcomeMessage()
    }

    // MARK: - Computed

    var hasExpertPack: Bool {
        subscriptionManager.isPurchased(.expertPack)
    }

    var canUseAI: Bool {
        hasExpertPack || aiResponseCount < Self.freeResponseLimit
    }

    var remainingFreeResponses: Int {
        max(0, Self.freeResponseLimit - aiResponseCount)
    }

    var isAIAvailable: Bool {
        if #available(iOS 26.0, *) { true } else { false }
    }

    // MARK: - Actions

    func send() async {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isGenerating else { return }

        inputText = ""
        messages.append(BZCChatMessage(role: .user, content: text))

        isGenerating = true
        defer { isGenerating = false }

        let response: String

        if canUseAI && isAIAvailable {
            response = await generateAIResponse(for: text)
            if !hasExpertPack { aiResponseCount += 1 }
        } else {
            response = fallback.respond(to: text)
        }

        messages.append(BZCChatMessage(role: .assistant, content: response))
    }

    func clearMessages() {
        messages.removeAll()
        insertWelcomeMessage()
    }

    // MARK: - Private

    private func insertWelcomeMessage() {
        let welcome = BZCChatMessage(
            role: .assistant,
            content: """
            Hello! I'm your **Be Zoo Care AI Animal Care Mentor** 🦊

            I can help you with:
            • Feeding schedules and nutrition
            • Grooming routines and techniques
            • Health monitoring and wellness
            • Training and positive reinforcement
            • Behavior understanding and enrichment
            • Species-specific care advice

            Ask me anything about caring for your animals! For example: *"How often should I groom my dog?"* or *"Why does my rabbit thump?"*
            """
        )
        messages.append(welcome)
    }

    private func generateAIResponse(for prompt: String) async -> String {
        if #available(iOS 26.0, *) {
            do {
                if foundationSession == nil {
                    foundationSession = try BZCFoundationModelsSession()
                }
                if let session = foundationSession as? BZCFoundationModelsSession {
                    return try await session.respond(to: prompt)
                }
            } catch BZCMentorError.modelUnavailable {
                errorMessage = "On-device AI unavailable. Using offline guidance."
            } catch {
                errorMessage = "AI response error. Using offline guidance."
            }
        }
        return fallback.respond(to: prompt)
    }
}
