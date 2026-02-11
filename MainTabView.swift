import SwiftUI

private struct SelectedTabKey: EnvironmentKey {
    static let defaultValue: Int = 0
}

extension EnvironmentValues {
    var selectedTab: Int {
        get { self[SelectedTabKey.self] }
        set { self[SelectedTabKey.self] = newValue }
    }
}

struct MainTabView: View {
    @EnvironmentObject var hydrationStore: HydrationStore
    @EnvironmentObject var storeManager: StoreManager
    @Environment(\.selectedTab) private var initialTab
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Today", systemImage: "drop.fill")
                }
                .tag(0)
                .environmentObject(hydrationStore)
                .environmentObject(storeManager)

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "chart.bar.fill")
                }
                .tag(1)
                .environmentObject(hydrationStore)
                .environmentObject(storeManager)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(2)
                .environmentObject(hydrationStore)
                .environmentObject(storeManager)
        }
        .tint(HydroTheme.deepBlue)
        .onAppear {
            selectedTab = initialTab
        }
    }
}
