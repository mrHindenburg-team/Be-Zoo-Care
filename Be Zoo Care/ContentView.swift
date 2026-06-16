import SwiftUI

struct ContentView: View {
    @AppStorage("bzcHasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showSplash = true

    var body: some View {
        Group {
            if showSplash {
                BZCSplashView {
                    showSplash = false
                }
            } else if !hasCompletedOnboarding {
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
