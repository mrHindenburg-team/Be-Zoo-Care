@preconcurrency import SwiftUI
import Combine

enum ACKScene: Equatable {
    case loading
    case main
    case web(url: String)
}

@MainActor
final class ACKSessionModel: ObservableObject {

    @Published var presented: ACKScene = .loading

    private var coordinator: ACKFlowCoordinator?
    private var fcmObserver: NSObjectProtocol?

    init() {}

    deinit {
        if let obs = fcmObserver {
            NotificationCenter.default.removeObserver(obs)
        }
    }

    func begin(config: ACKConfiguration) {
        ACKLogger.log(.debug, "ViewModel: begin()")
        ACKLogger.mode = config.debugMode

        let coord = ACKFlowCoordinator(config: config)
        coord.viewModel = self
        self.coordinator = coord
        coord.start()
    }

    func setLoading() {
        ACKLogger.log(.debug, "ViewModel: → loading")
        presented = .loading
    }

    func setMain() {
        ACKLogger.log(.info, "ViewModel: → main")
        presented = .main
    }

    func setWeb(url: String) {
        ACKLogger.log(.info, "ViewModel: → web(\(url))")
        presented = .web(url: url)
    }
}

public extension Notification.Name {
    static let wbcFCMTokenDidUpdate  = Notification.Name("wbc.fcm.token.didUpdate")
    static let wbcAPNSTokenDidUpdate = Notification.Name("wbc.apns.token.didUpdate")
}
