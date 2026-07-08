import SwiftUI
import Combine

nonisolated public struct ACKTransitionConfig: Sendable {

    public let animation: Animation
    public let type: ACKTransitionType

    public init(
        type:      ACKTransitionType = .fade,
        animation: Animation         = .easeInOut(duration: 0.6)
    ) {
        self.type      = type
        self.animation = animation
    }

    public static let fade      = ACKTransitionConfig(type: .fade,           animation: .easeInOut(duration: 0.6))
    public static let slideUp   = ACKTransitionConfig(type: .slide(.up),     animation: .easeInOut(duration: 0.5))
    public static let slideDown = ACKTransitionConfig(type: .slide(.down),   animation: .easeInOut(duration: 0.5))
    public static let scale     = ACKTransitionConfig(type: .scale,          animation: .easeInOut(duration: 0.5))

    public static func custom(type: ACKTransitionType, animation: Animation) -> ACKTransitionConfig {
        ACKTransitionConfig(type: type, animation: animation)
    }
}

public enum ACKTransitionType: Sendable {
    case fade
    case slide(Edge)
    case scale

    public enum Edge: Sendable {
        case up, down, left, right
    }
}

@MainActor
public final class AppContentKit {

    public static let shared = AppContentKit()
    private init() {}

    private(set) var config: ACKConfiguration?
    private(set) var transitionConfig: ACKTransitionConfig = .fade
    private(set) var mainViewProvider: ACKMainViewProvider?
    private var viewModel: ACKSessionModel?
    private var started = false
    private var configuredForTracking = false

    weak var _appDelegate: ACKAppDelegate?

    private(set) var splashSignal = ACKSplashSignal()

    // MARK: - Scenario 1: Simple — splash + native view, no server

    public func whiteClean<S: View, M: View>(
        transition:          ACKTransitionConfig          = .fade,
        @ViewBuilder splash: @escaping (_ onComplete: @escaping () -> Void) -> S,
        @ViewBuilder mainView: @escaping () -> M,
        debugMode:           ACKDebugMode                 = .disabled,
        defaultOrientations: UIInterfaceOrientationMask   = .portrait,
        webOrientations:     UIInterfaceOrientationMask   = .all
    ) -> some View {
        mainViewProvider = { AnyView(mainView()) }
        transitionConfig = transition

        let config = ACKConfiguration(
            splash:              { onComplete in AnyView(splash(onComplete)) },
            debugMode:           debugMode,
            defaultOrientations: defaultOrientations,
            webOrientations:     webOrientations
        )
        configure(config)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.startSimple()
        }
        return makeRootView()
    }

    // MARK: - Scenario 1b: Splash + native view + ATT + push (no server)

    public func whiteWithPermissions<S: View, M: View>(
        transition:          ACKTransitionConfig          = .fade,
        @ViewBuilder splash: @escaping (_ onComplete: @escaping () -> Void) -> S,
        @ViewBuilder mainView: @escaping () -> M,
        debugMode:           ACKDebugMode                 = .disabled,
        attHandling:         ACKATTHandling               = .managedByLibrary,
        attDelay:            TimeInterval,
        pushEnabled:         Bool                         = true,
        defaultOrientations: UIInterfaceOrientationMask   = .portrait,
        webOrientations:     UIInterfaceOrientationMask   = .all
    ) -> some View {
        mainViewProvider = { AnyView(mainView()) }
        transitionConfig = transition

        let config = ACKConfiguration(
            splash:              { onComplete in AnyView(splash(onComplete)) },
            debugMode:           debugMode,
            attHandling:         attHandling,
            attDelay:            attDelay,
            pushEnabled:         pushEnabled,
            defaultOrientations: defaultOrientations,
            webOrientations:     webOrientations
        )
        configure(config)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.startSimple()
        }
        return makeRootView()
    }

    // MARK: - Scenario 2: Server registration only — no push, no ATT, no Firebase

    public func blackClean<S: View, M: View>(
        host:                 String,
        appId:                String,
        @ViewBuilder splash:  @escaping (_ onComplete: @escaping () -> Void) -> S,
        @ViewBuilder mainView: @escaping () -> M,
        debugMode:            ACKDebugMode,
        transition:           ACKTransitionConfig          = .fade,
        fallbackURL:          String?                      = nil,
        nativeOnly:           Bool                         = false,
        requestReviewEnabled: Bool                         = false,
        defaultOrientations:  UIInterfaceOrientationMask   = .portrait,
        webOrientations:      UIInterfaceOrientationMask   = .all
    ) -> some View {
        mainViewProvider = { AnyView(mainView()) }
        transitionConfig = transition

        let base = "https://\(host.trimmingCharacters(in: .init(charactersIn: "/")))"
        let config = ACKConfiguration(
            registerURL:          "\(base)/v1/public/install",
            syncURL:              "\(base)/v1/public/refresh",
            appId:                appId,
            attHandling:          .skip,
            attDelay:             0,
            splash:               { onComplete in AnyView(splash(onComplete)) },
            debugMode:            debugMode,
            pushEnabled:          false,
            fallbackURL:          fallbackURL,
            defaultOrientations:  defaultOrientations,
            webOrientations:      webOrientations,
            nativeOnly:           nativeOnly,
            requestReviewEnabled: requestReviewEnabled
        )
        configure(config)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { self.start() }
        return makeRootView()
    }

    // MARK: - Scenario 3: Server + Firebase push + ATT (no AppsFlyer)

    public func blackWithPermissions<S: View, M: View>(
        host:                 String,
        appId:                String,
        @ViewBuilder splash:  @escaping (_ onComplete: @escaping () -> Void) -> S,
        @ViewBuilder mainView: @escaping () -> M,
        debugMode:            ACKDebugMode,
        transition:           ACKTransitionConfig          = .fade,
        attDelay:             TimeInterval                 = 2.0,
        fallbackURL:          String?                      = nil,
        nativeOnly:           Bool                         = false,
        requestReviewEnabled: Bool                         = false,
        defaultOrientations:  UIInterfaceOrientationMask   = .portrait,
        webOrientations:      UIInterfaceOrientationMask   = .all
    ) -> some View {
        mainViewProvider = { AnyView(mainView()) }
        transitionConfig = transition

        let base = "https://\(host.trimmingCharacters(in: .init(charactersIn: "/")))"
        let config = ACKConfiguration(
            registerURL:          "\(base)/v1/public/install",
            syncURL:              "\(base)/v1/public/refresh",
            appId:                appId,
            attHandling:          .managedByLibrary,
            attDelay:             attDelay,
            splash:               { onComplete in AnyView(splash(onComplete)) },
            debugMode:            debugMode,
            pushEnabled:          true,
            fallbackURL:          fallbackURL,
            defaultOrientations:  defaultOrientations,
            webOrientations:      webOrientations,
            nativeOnly:           nativeOnly,
            requestReviewEnabled: requestReviewEnabled
        )
        configure(config)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { self.start() }
        return makeRootView()
    }

    // MARK: - Scenario 4: Server + Firebase push + ATT + AppsFlyer

    public func blackFullIntegration<S: View, M: View>(
        host:                 String,
        appId:                String,
        @ViewBuilder splash:  @escaping (_ onComplete: @escaping () -> Void) -> S,
        @ViewBuilder mainView: @escaping () -> M,
        debugMode:            ACKDebugMode,
        transition:           ACKTransitionConfig          = .fade,
        attDelay:             TimeInterval                 = 2.0,
        fallbackURL:          String?                      = nil,
        nativeOnly:           Bool                         = false,
        requestReviewEnabled: Bool                         = false,
        defaultOrientations:  UIInterfaceOrientationMask   = .portrait,
        webOrientations:      UIInterfaceOrientationMask   = .all
    ) -> some View {
        guard !configuredForTracking else { return makeRootView() }
        configuredForTracking = true

        mainViewProvider = { AnyView(mainView()) }
        transitionConfig = transition

        let signal         = ACKATTSignal()
        let appsFlyerSignal = ACKAppsFlyerSignal()

        if let delegate = _appDelegate {
            delegate.attSignal        = signal
            delegate.appsFlyerSignal  = appsFlyerSignal
            delegate.appsFlyerEnabled = true
        } else {
            ACKLogger.log(.warning, "startWithTracking: _appDelegate not set yet")
        }

        let base = "https://\(host.trimmingCharacters(in: .init(charactersIn: "/")))"
        let config = ACKConfiguration(
            registerURL:                "\(base)/v1/public/install",
            syncURL:                    "\(base)/v1/public/refresh",
            appId:                      appId,
            attSignal:                  signal,
            attDelay:                   attDelay,
            appsFlyerSignal:            appsFlyerSignal,
            appsFlyerIDProvider:        { UserDefaults.standard.string(forKey: "wbc.appsflyer.id") },
            splash:                     { onComplete in AnyView(splash(onComplete)) },
            debugMode:                  debugMode,
            pushEnabled:                true,
            fallbackURL:                fallbackURL,
            defaultOrientations:        defaultOrientations,
            webOrientations:            webOrientations,
            nativeOnly:                 nativeOnly,
            requestReviewEnabled:       requestReviewEnabled,
            extraInstallFieldsProvider: ACKAppsFlyerFields.shared.extraFields
        )
        configure(config)
        ACKAppsFlyerFields.setDebugMode(debugMode == .verbose)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { self.start() }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1 + attDelay) {
            if let delegate = self._appDelegate {
                delegate.performATTForAppsFlyer()
            } else {
                ACKLogger.log(.warning, "startWithTracking asyncAfter: _appDelegate not found — completing ATT signal as false")
                signal.complete(authorized: false)
            }
        }

        return makeRootView()
    }

    // MARK: - Internal

    func handleAPNSToken(_ data: Data) {
        let hex = data.map { String(format: "%02.2hhx", $0) }.joined()
        ACKLogger.log(.info, "AppContentKit: APNs (\(hex)")
        UserDefaults.standard.set(true, forKey: "wbcApnsReady")
        UserDefaults.standard.set(hex,  forKey: "wbcApnsTokenHex")
        ACKPushGate.shared.apnsToken = hex
        NotificationCenter.default.post(name: .wbcAPNSTokenDidUpdate, object: nil,
                                        userInfo: ["wbc_apns": hex])
    }

    func handleFCMToken(_ token: String) {
        guard !token.isEmpty else { return }
        ACKLogger.log(.debug, "FCM token \(started ? "refresh" : "early"): \(token)")
        UserDefaults.standard.set(token, forKey: "wbc.fcm.token")
        ACKPushGate.shared.fcmToken = token
        NotificationCenter.default.post(name: .wbcFCMTokenDidUpdate, object: nil,
                                        userInfo: ["token": token])
    }

    var currentOrientations: UIInterfaceOrientationMask {
        config?.defaultOrientations ?? .portrait
    }
    
    //MARK: - Private
    
    private func configure(_ config: ACKConfiguration) {
        self.config = config
        ACKLogger.mode = config.debugMode
        ACKLogger.appsFlyerEnabled = config.appsFlyerIDProvider != nil
        ACKLogger.log(.info, "AppContentKit: configure() appId=\(config.appId)")
    }
    
    private func makeRootView() -> some View {
        let vm = getOrCreateViewModel()
        return ACKHostView().environmentObject(vm)
    }
    
    private func start() {
        guard let config else {
            ACKLogger.log(.error, "AppContentKit: start() called before configure()")
            return
        }
        guard !started else {
            ACKLogger.log(.debug, "AppContentKit: start() already called")
            return
        }
        started = true
        ACKLogger.log(.info, "AppContentKit: start()")
        
        guard let vm = viewModel else {
            ACKLogger.log(.error, "AppContentKit: ViewModel not found")
            return
        }
        vm.begin(config: config)
    }
    
    private func startSimple() {
        guard let config, !started else { return }
        started = true
        ACKLogger.mode = config.debugMode
        ACKLogger.log(.info, "AppContentKit: startSimple()")
        
        Task { @MainActor in
            let attGate = ACKATTGate(handling: config.attHandling, delay: config.attDelay)
            let attAuthorized = await attGate.requestIfNeeded()
            UserDefaults.standard.set(attAuthorized, forKey: "wbc.att.authorized")
            ACKLogger.log(.info, "AppContentKit: startSimple — ATT authorized=\(attAuthorized)")
            
            if config.pushEnabled {
                try? await Task.sleep(nanoseconds: 600_000_000)
                await ACKPushGate.shared.requestPermissionOnly()
            }
            
            viewModel?.setMain()
        }
    }
    
    private var presented: ACKScene {
        viewModel?.presented ?? .loading
    }
    
    private var presentedPublisher: Published<ACKScene>.Publisher? {
        viewModel?.$presented
    }
    
    private func reset() {
        ACKLogger.log(.info, "AppContentKit: reset()")
        [
            "wbc.flow.lock", "wbc.flow.url",
            "wbc.session.done", "wbc.session.fcm", "wbc.session.device",
            "wbc.att.authorized", "wbc.stable.uuid",
            "wbc.device.idfa", "wbc.appsflyer.id"
        ].forEach { UserDefaults.standard.removeObject(forKey: $0) }
        started               = false
        configuredForTracking = false
        viewModel             = nil
        mainViewProvider      = nil
        splashSignal          = ACKSplashSignal()
    }
    
    private func getOrCreateViewModel() -> ACKSessionModel {
        if let existing = viewModel { return existing }
        let vm = ACKSessionModel()
        viewModel = vm
        return vm
    }
}
