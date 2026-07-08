import Foundation

nonisolated public enum ACKDebugMode: Sendable {
    case disabled
    case minimal
    case verbose
}

enum ACKLogLevel: Sendable {
    case error, warning, info, debug, network

    nonisolated var icon: String {
        switch self {
        case .error:   "❌"
        case .warning: "⚠️"
        case .info:    "✅"
        case .debug:   "🔍"
        case .network: "🌐"
        }
    }

    nonisolated static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.error, .error), (.warning, .warning), (.info, .info),
             (.debug, .debug), (.network, .network): true
        default: false
        }
    }
}

extension ACKLogLevel: Equatable {}

enum ACKLogger {

    nonisolated(unsafe) static var mode: ACKDebugMode = .disabled

    // Whether the current init configured AppsFlyer. When false, `af(...)` logs are
    // suppressed entirely so AppsFlyer-related noise never appears in non-tracking scenarios.
    nonisolated(unsafe) static var appsFlyerEnabled: Bool = false

    // Last printed table signature per id — used to skip unchanged tables.
    nonisolated(unsafe) private static var lastTableSignature: [String: String] = [:]

    nonisolated static func log(
        _ level: ACKLogLevel,
        _ message: String,
        file: String = #fileID
    ) {
        switch mode {
        case .disabled:
            return
        case .minimal:
            guard level == .error else { return }
            print("[ACK] \(level.icon) \(message)")
        case .verbose:
            let filename = file.split(separator: "/").last.map(String.init) ?? file
            print("[ACK][\(level.icon)][\(filename)] \(message)")
        }
    }

    /// Key milestone log (device ID, route decision, …) — unlike `log`, visible in
    /// `.minimal` as well, so essential identifiers can be checked without verbose noise.
    nonisolated static func key(
        _ message: String,
        file: String = #fileID
    ) {
        switch mode {
        case .disabled:
            return
        case .minimal:
            print("[ACK] 🔑 \(message)")
        case .verbose:
            let filename = file.split(separator: "/").last.map(String.init) ?? file
            print("[ACK][🔑][\(filename)] \(message)")
        }
    }

    /// AppsFlyer-scoped log — suppressed entirely when AppsFlyer isn't configured for
    /// the current init, so af-related lines never appear in non-tracking scenarios.
    nonisolated static func af(
        _ level: ACKLogLevel,
        _ message: String,
        file: String = #fileID
    ) {
        guard appsFlyerEnabled else { return }
        log(level, message, file: file)
    }

    /// Prints a compact, aligned key/value table. Visible in `.minimal` and `.verbose`.
    nonisolated static func table(_ title: String, _ rows: [(String, String)]) {
        guard mode != .disabled else { return }
        print(render(title, rows), terminator: "")
    }

    /// Prints a table only when its content changed since the previous call with the
    /// same `id`. Otherwise prints a single "— no changes" line. Used for /refresh so
    /// an unchanged FCM (or any unchanged field set) doesn't spam the console.
    nonisolated static func tableIfChanged(_ title: String, _ rows: [(String, String)], id: String) {
        guard mode != .disabled else { return }
        let signature = rows.map { "\($0.0)=\($0.1)" }.joined(separator: "|")
        if lastTableSignature[id] == signature {
            print("\n╶╶╶ \(title) — no changes\n", terminator: "")
            return
        }
        lastTableSignature[id] = signature
        print(render(title, rows), terminator: "")
    }

    private nonisolated static func render(_ title: String, _ rows: [(String, String)]) -> String {
        let width = 44
        let keyWidth = rows.map { $0.0.count }.max() ?? 0
        let header = "─── \(title) "
        let topRule = header + String(repeating: "─", count: max(3, width - header.count))
        let bottomRule = String(repeating: "─", count: width)

        var out = "\n\(topRule)\n"
        for (key, value) in rows {
            let paddedKey = key.padding(toLength: keyWidth, withPad: " ", startingAt: 0)
            out += "  \(paddedKey)  \(value)\n"
        }
        out += "\(bottomRule)\n"
        return out
    }
}
