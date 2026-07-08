// ACKAppDelegate.swift
// AppContentKit

import UserNotifications
import AppTrackingTransparency
import AdSupport
import UIKit


open class ACKAppDelegate: NSObject, UIApplicationDelegate {
    var attSignal: ACKATTSignal?
    var appsFlyerSignal: ACKAppsFlyerSignal?
    var appsFlyerEnabled: Bool = false

    open func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        AppContentKit.shared._appDelegate = self
        UNUserNotificationCenter.current().delegate = self
        firebaseConfigure()
        if appsFlyerEnabled {
            appsFlyerConfigure()
        }
        ACKLogger.log(.debug, "AppDelegate: didFinishLaunching")
        return true
    }

    open func firebaseConfigure() {
        ACKLogger.log(.warning, "AppDelegate: firebaseConfigure() not overridden — Firebase not configured")
    }

    open func appsFlyerConfigure() {}

    nonisolated open func attDidComplete(authorized: Bool) {}

    public func didReceiveFCMToken(_ token: String) {
        AppContentKit.shared.handleFCMToken(token)
    }

    public func onAppsFlyerConversionData(_ data: [AnyHashable: Any]) {
        ACKAppsFlyerFields.shared.updateConversionData(data)
        appsFlyerSignal?.complete()
    }

    public func onAppsFlyerConversionFail() {
        appsFlyerSignal?.complete()
    }

    func performATTForAppsFlyer() {
        let attSignal = self.attSignal
        ATTrackingManager.requestTrackingAuthorization { [weak self] status in
            let authorized = (status == .authorized)

            if authorized {
                let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                UserDefaults.standard.set(idfa, forKey: "wbc.device.idfa")
                ACKLogger.log(.info, "AppDelegate: IDFA saved")
            }

            if let afClass = NSClassFromString("AppsFlyerLib") as? NSObject.Type {
                let afInstance = afClass.value(forKeyPath: "shared") as AnyObject
                let uidSel = NSSelectorFromString("getAppsFlyerUID")

                if afInstance.responds(to: uidSel),
                   let uid = afInstance.perform(uidSel)?.takeUnretainedValue() as? String {
                    UserDefaults.standard.set(uid, forKey: "wbc.appsflyer.id")
                    ACKLogger.af(.info, "AppDelegate: AppsFlyer UID saved")
                }
            }

            ACKLogger.log(.info, "AppDelegate: ATT completed — authorized=\(authorized)")
            self?.attDidComplete(authorized: authorized)
            attSignal?.complete(authorized: authorized)
        }
    }

    open func application(
        _ application: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        ACKLogger.log(.info, "AppDelegate: open URL — \(url)")
        if appsFlyerEnabled {
            ACKAppsFlyerFields.handleOpen(url, options: options)
        }
        return true
    }

    open func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        ACKLogger.log(.info, "AppDelegate: continue userActivity — \(userActivity.webpageURL?.absoluteString ?? "no webpageURL")")
        if appsFlyerEnabled {
            ACKAppsFlyerFields.continueUserActivity(userActivity)
        }
        return true
    }

    open func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        AppContentKit.shared.handleAPNSToken(deviceToken)
    }

    open func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        ACKLogger.log(.error, "AppDelegate: APNs error — \(error.localizedDescription)")
    }

    open func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        AppContentKit.shared.currentOrientations
    }
}

extension ACKAppDelegate: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
    
    public func userNotificationCenter(
            _ center: UNUserNotificationCenter,
            didReceive response: UNNotificationResponse,
            withCompletionHandler completionHandler: @escaping () -> Void
        ) {
            completionHandler()
        }
}
