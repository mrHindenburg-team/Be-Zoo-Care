import SwiftUI

struct ContentView: View {
    @AppStorage("bzcHasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        Group {
            if !hasCompletedOnboarding {
                BZCOnboardingView {
                    hasCompletedOnboarding = true
                }
            } else {
                BZCMainTabView()
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
        .environment(SubscriptionManager())
        .environment(BZCGuardianProgress())
}
