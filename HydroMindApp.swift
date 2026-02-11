import SwiftUI

@main
struct HydroMindApp: App {
    @StateObject private var hydrationStore = HydrationStore()
    @StateObject private var storeManager = StoreManager()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    private var screenshotMode: String? {
        ProcessInfo.processInfo.environment["SCREENSHOT_MODE"]
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if let mode = screenshotMode {
                    switch mode {
                    case "onboarding":
                        OnboardingView(hasCompletedOnboarding: .constant(false))
                            .environmentObject(storeManager)
                    case "paywall":
                        PaywallView(isPresented: .constant(true), onComplete: {})
                            .environmentObject(storeManager)
                    case "dashboard":
                        MainTabView()
                            .environmentObject(hydrationStore)
                            .environmentObject(storeManager)
                            .onAppear { hydrationStore.addSampleDataForScreenshot() }
                    case "history":
                        MainTabView()
                            .environmentObject(hydrationStore)
                            .environmentObject(storeManager)
                            .onAppear { hydrationStore.addSampleDataForScreenshot() }
                            .environment(\.selectedTab, 1)
                    case "settings":
                        MainTabView()
                            .environmentObject(hydrationStore)
                            .environmentObject(storeManager)
                            .environment(\.selectedTab, 2)
                    default:
                        if hasCompletedOnboarding {
                            MainTabView()
                                .environmentObject(hydrationStore)
                                .environmentObject(storeManager)
                        } else {
                            OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                                .environmentObject(storeManager)
                        }
                    }
                } else {
                    if hasCompletedOnboarding {
                        MainTabView()
                            .environmentObject(hydrationStore)
                            .environmentObject(storeManager)
                    } else {
                        OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                            .environmentObject(storeManager)
                    }
                }
            }
        }
    }
}
