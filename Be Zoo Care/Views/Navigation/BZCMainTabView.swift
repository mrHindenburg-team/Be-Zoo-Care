import SwiftUI
import SwiftData

enum BZCTab {
    case home, pets, aiMentor, education, dashboard
}

struct BZCMainTabView: View {
    @State private var appNav = BZCAppNavigation()

    var body: some View {
        TabView(selection: $appNav.selectedTab) {
            Tab("Home", systemImage: "house.fill", value: BZCTab.home) {
                BZCHomeView()
            }
            Tab("My Pets", systemImage: "pawprint.fill", value: BZCTab.pets) {
                BZCPetsView()
            }
            Tab("AI Mentor", systemImage: "brain.head.profile", value: BZCTab.aiMentor) {
                BZCAIMentorView()
            }
            Tab("Learn", systemImage: "books.vertical.fill", value: BZCTab.education) {
                BZCEducationView()
            }
            Tab("Dashboard", systemImage: "chart.bar.fill", value: BZCTab.dashboard) {
                BZCDashboardView()
            }
        }
        .tint(BZCColors.richGold)
        .environment(appNav)
    }
}

#Preview {
    BZCMainTabView()
        .environment(SubscriptionManager())
        .environment(BZCGuardianProgress())
        .modelContainer(for: [BZCPet.self], inMemory: true)
}
