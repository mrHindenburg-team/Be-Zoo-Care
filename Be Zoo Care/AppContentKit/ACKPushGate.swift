import UIKit
import UserNotifications

final class ACKPushGate: Sendable {

    static let shared = ACKPushGate(enabled: true)

    private let enabled: Bool

    private let _fcmToken   = ACKTokenBox()
    private let _apnsToken  = ACKTokenBox()

    var fcmToken: String? {
        get { _fcmToken.value }
        set { _fcmToken.value = newValue }
    }

    var apnsToken: String? {
        get { _apnsToken.value }
        set { _apnsToken.value = newValue }
    }

    init(enabled: Bool) {
        self.enabled = enabled
    }

    func requestPermissionOnly() async {
        guard enabled else {
            ACKLogger.log(.debug, "Push: skipped (pushEnabled=false)")
            return
        }
        await requestPermission()
        await MainActor.run {
            UIApplication.shared.registerForRemoteNotifications()
        }
        ACKLogger.log(.debug, "Push: permission requested — token will arrive async")
    }

    private func requestPermission() async {
        let center = UNUserNotificationCenter.current()
        let current = await center.notificationSettings()

        guard current.authorizationStatus == .notDetermined else {
            ACKLogger.log(.debug, "Push: already authorized — status=\(current.authorizationStatus.rawValue)")
            return
        }

        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            ACKLogger.log(.info, "Push: user responded — granted=\(granted)")
        } catch {
            ACKLogger.log(.error, "Push: permission request error — \(error.localizedDescription)")
        }
    }

    private func waitForStableFCMToken(
        minWindowSeconds: Double = 4.0,
        debounceSeconds:  Double = 1.2,
        maxWindowSeconds: Double = 8.0
    ) async -> String? {

        ACKLogger.log(.debug, "Push: waiting for stable FCM token (min=\(minWindowSeconds)s, debounce=\(debounceSeconds)s, max=\(maxWindowSeconds)s)")

        let start    = Date()
        let deadline = start.addingTimeInterval(maxWindowSeconds)

        var latestToken: String? = nil
        var lastChange:  Date   = .distantPast

        if let existing = ACKPushGate.shared.fcmToken, !existing.isEmpty {
            latestToken = existing
            lastChange  = Date()
            ACKLogger.log(.debug, "Push: seeded token from shared: \(existing)")
        } else if let stored = UserDefaults.standard.string(forKey: "wbc.fcm.token"), !stored.isEmpty {
            latestToken = stored
            lastChange  = Date()
            ACKLogger.log(.debug, "Push: seeded token from UserDefaults")
        }

        while latestToken == nil || latestToken!.isEmpty {
            if Date() > deadline { break }

            if let t = ACKPushGate.shared.fcmToken, !t.isEmpty {
                latestToken = t
                lastChange  = Date()
                ACKLogger.log(.debug, "Push: first token captured from shared")
                break
            }

            if let t = UserDefaults.standard.string(forKey: "wbc.fcm.token"), !t.isEmpty {
                latestToken = t
                lastChange  = Date()
                ACKLogger.log(.debug, "Push: first token captured from UserDefaults")
                break
            }

            try? await Task.sleep(nanoseconds: 120_000_000)
        }

        guard let _ = latestToken else {
            ACKLogger.log(.warning, "Push: no FCM token received — sending empty")
            return nil
        }

        let firstTokenTime = Date()
        ACKLogger.log(.debug, "Push: first token captured — starting stability window")

        while Date() < deadline {
            try? await Task.sleep(nanoseconds: 150_000_000)

            let current = ACKPushGate.shared.fcmToken
                ?? UserDefaults.standard.string(forKey: "wbc.fcm.token")

            if let current, !current.isEmpty, current != latestToken {
                ACKLogger.log(.debug, "Push: FCM changed: \(latestToken ?? "nil") → \(current)")
                latestToken = current
                lastChange  = Date()
            }

            let sinceFirst  = Date().timeIntervalSince(firstTokenTime)
            let sinceChange = Date().timeIntervalSince(lastChange)

            if sinceFirst >= minWindowSeconds,
               let tok = latestToken, !tok.isEmpty,
               sinceChange >= debounceSeconds {
                ACKLogger.log(.info, "Push: stable FCM token accepted (sinceFirst=\(String(format: "%.1f", sinceFirst))s, sinceChange=\(String(format: "%.1f", sinceChange))s)")
                return tok
            }
        }

        let fallback = latestToken
            ?? ACKPushGate.shared.fcmToken
            ?? UserDefaults.standard.string(forKey: "wbc.fcm.token")

        if let fallback, !fallback.isEmpty {
            ACKLogger.log(.warning, "Push: stability timeout — using best available token")
            return fallback
        }

        ACKLogger.log(.warning, "Push: FCM token not received within \(maxWindowSeconds)s — sending empty")
        return nil
    }
}

final class ACKTokenBox: @unchecked Sendable {
    nonisolated(unsafe) private var _value: String?
    private let lock = NSLock()

    var value: String? {
        get { lock.withLock { _value } }
        set { lock.withLock { _value = newValue } }
    }
}
