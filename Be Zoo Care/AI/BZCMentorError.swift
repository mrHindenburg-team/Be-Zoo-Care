import Foundation

enum BZCMentorError: Error, LocalizedError {
    case modelUnavailable
    case notInitialized
    case responseGenerationFailed
    case voiceInputUnavailable

    var errorDescription: String? {
        switch self {
        case .modelUnavailable:
            "On-device AI is not available on this device. Using offline guidance instead."
        case .notInitialized:
            "AI session has not been initialized."
        case .responseGenerationFailed:
            "Could not generate a response. Using offline guidance instead."
        case .voiceInputUnavailable:
            "Voice input is not available. Please type your question."
        }
    }
}
