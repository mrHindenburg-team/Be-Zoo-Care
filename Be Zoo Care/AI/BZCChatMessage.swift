import Foundation

struct BZCChatMessage: Identifiable {
    enum Role {
        case user, assistant
    }

    let id: UUID
    let role: Role
    var content: String
    let timestamp: Date
    var isStreaming: Bool

    init(role: Role, content: String, isStreaming: Bool = false) {
        self.id = UUID()
        self.role = role
        self.content = content
        self.timestamp = .now
        self.isStreaming = isStreaming
    }
}
