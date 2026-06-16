import Foundation

// MARK: - Foundation Models Session (iOS 26+)

#if canImport(FoundationModels)
import FoundationModels

@available(iOS 26.0, *)
final class BZCFoundationModelsSession {

    private let session: LanguageModelSession

    static let systemPrompt = """
    You are Be Zoo Care's AI Animal Care Mentor — a warm, knowledgeable expert in all aspects of animal care. \
    You specialize in dog, cat, rabbit, bird, hamster, reptile, and fish care, covering nutrition, health, behavior, \
    grooming, training, enrichment, and veterinary wellness. \
    Provide accurate, practical, and educational responses. \
    Format responses with clear structure using bold headers and bullet points where helpful. \
    Always recommend veterinary consultation for medical concerns. \
    Keep responses concise but complete — aim for 150–300 words. \
    Your tone is warm, encouraging, and professional.
    """

    init() throws {
        let model = SystemLanguageModel.default
        guard case .available = model.availability else {
            throw BZCMentorError.modelUnavailable
        }
        session = LanguageModelSession(
            model: model,
            instructions: BZCFoundationModelsSession.systemPrompt
        )
    }

    func respond(to prompt: String) async throws -> String {
        do {
            let response = try await session.respond(to: prompt)
            return response.content
        } catch {
            throw BZCMentorError.responseGenerationFailed
        }
    }
}

#else

// Stub for platforms where FoundationModels is unavailable at compile time
@available(iOS 26.0, *)
final class BZCFoundationModelsSession {
    init() throws { throw BZCMentorError.modelUnavailable }
    func respond(to prompt: String) async throws -> String { throw BZCMentorError.modelUnavailable }
}

#endif
