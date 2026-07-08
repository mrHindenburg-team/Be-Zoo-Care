import SwiftUI
import SwiftData
import UIKit
import Firebase
import FirebaseMessaging

private enum AppConfig {
    static let host  = "zpkuzjxw.click"
    static let appId = "6780897045"
}

@main
struct Be_Zoo_CareApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var subscriptionManager = SubscriptionManager()
    @State private var guardianProgress = BZCGuardianProgress()

    private var modelContainer: ModelContainer = {
        let schema = Schema([
            BZCPet.self,
            BZCCareActivity.self,
            BZCHealthRecord.self,
            BZCVaccination.self,
            BZCMedication.self,
            BZCWeightEntry.self,
            BZCVetVisit.self,
            BZCMilestone.self,
            BZCJournalEntry.self,
            BZCReminder.self
        ])
        do {
            return try ModelContainer(for: schema)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            AppContentKit.shared.blackWithPermissions(
                host: AppConfig.host,
                appId: AppConfig.appId,
                splash: { onComplete in
                    BZCSplashView(onComplete: onComplete)
                },
                mainView: {
                    ContentView()
                        .environment(subscriptionManager)
                        .environment(guardianProgress)
                        .modelContainer(modelContainer)
                },
                debugMode: .verbose
            )
        }
    }
}

final class AppDelegate: ACKAppDelegate, MessagingDelegate {

    override func firebaseConfigure() {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
    }

    override func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
        super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        didReceiveFCMToken(token)
    }
}
