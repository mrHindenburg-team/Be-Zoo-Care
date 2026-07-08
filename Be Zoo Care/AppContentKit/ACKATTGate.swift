// ACKATTGate.swift
// AppContentKit

import AppTrackingTransparency

final class ACKATTGate: Sendable {

    private let handling: ACKATTHandling
    private let delay: TimeInterval

    init(handling: ACKATTHandling, delay: TimeInterval) {
        self.handling = handling
        self.delay    = delay
    }

    func requestIfNeeded() async -> Bool {
        switch handling {

        case .skip:
            ACKLogger.log(.debug, "ATT: skip")
            return false

        case .managedByHost(let signal):
            ACKLogger.log(.debug, "ATT: waiting for host signal...")
            let authorized = await signal.wait()
            ACKLogger.log(.info, "ATT: host signaled — authorized=\(authorized)")
            return authorized

        case .managedByLibrary:
            ACKLogger.log(.debug, "ATT: requesting via library")

            let status = await MainActor.run {
                ATTrackingManager.trackingAuthorizationStatus
            }

            if status != .notDetermined {
                let authorized = (status == .authorized)
                ACKLogger.log(.info, "ATT: already determined — authorized=\(authorized)")
                return authorized
            }

            if delay > 0 {
                ACKLogger.log(.debug, "ATT: delaying request by \(delay)s")
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }

            return await withCheckedContinuation { continuation in
                ATTrackingManager.requestTrackingAuthorization { status in
                    let authorized = (status == .authorized)
                    ACKLogger.log(.info, "ATT: response — authorized=\(authorized)")
                    continuation.resume(returning: authorized)
                }
            }
        }
    }
}
