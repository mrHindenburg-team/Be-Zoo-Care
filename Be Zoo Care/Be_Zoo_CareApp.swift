import SwiftUI
import SwiftData

@main
struct Be_Zoo_CareApp: App {

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
            ContentView()
                .environment(subscriptionManager)
                .environment(guardianProgress)
                .modelContainer(modelContainer)
        }
    }
}
