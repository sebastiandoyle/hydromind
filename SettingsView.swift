import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var hydrationStore: HydrationStore
    @EnvironmentObject var storeManager: StoreManager
    @State private var showPaywall = false
    @State private var goalText: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                HydroTheme.backgroundGradient.ignoresSafeArea()

                List {
                    // Premium status
                    premiumSection

                    // Goal settings
                    goalSection

                    // Units
                    unitSection

                    // Reminders
                    reminderSection

                    // About
                    aboutSection
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .onAppear {
                goalText = "\(Int(hydrationStore.dailyGoal))"
            }
            .fullScreenCover(isPresented: $showPaywall) {
                PaywallView(isPresented: $showPaywall)
                    .environmentObject(storeManager)
            }
        }
    }

    private var premiumSection: some View {
        Section {
            if storeManager.isPremium {
                HStack(spacing: 12) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(HydroTheme.premiumGradient)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("HydroMind Pro")
                            .font(.system(size: 16, weight: .semibold))
                        Text("All features unlocked")
                            .font(.system(size: 13))
                            .foregroundColor(HydroTheme.secondaryText)
                    }
                }
            } else {
                Button(action: { showPaywall = true }) {
                    HStack(spacing: 12) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(HydroTheme.premiumGradient)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Upgrade to Pro")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(HydroTheme.darkText)
                            Text("Unlock all features and insights")
                                .font(.system(size: 13))
                                .foregroundColor(HydroTheme.secondaryText)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(HydroTheme.secondaryText)
                    }
                }
            }
        }
    }

    private var goalSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Text("Daily Goal")
                    .font(.system(size: 15, weight: .semibold))

                HStack {
                    TextField("Goal", text: $goalText)
                        .keyboardType(.numberPad)
                        .font(.system(size: 18, weight: .medium))
                        .onChange(of: goalText) { newValue in
                            if let val = Double(newValue), val > 0 {
                                hydrationStore.dailyGoal = val
                            }
                        }
                    Text(hydrationStore.unit.rawValue)
                        .foregroundColor(HydroTheme.secondaryText)
                }

                // Quick presets
                HStack(spacing: 8) {
                    ForEach([2000.0, 2500.0, 3000.0, 3500.0], id: \.self) { goal in
                        Button(action: {
                            hydrationStore.dailyGoal = goal
                            goalText = "\(Int(goal))"
                        }) {
                            Text(hydrationStore.displayAmount(goal))
                                .font(.system(size: 12, weight: .medium))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(hydrationStore.dailyGoal == goal ? HydroTheme.deepBlue : Color.gray.opacity(0.1))
                                .foregroundColor(hydrationStore.dailyGoal == goal ? .white : HydroTheme.darkText)
                                .cornerRadius(8)
                        }
                    }
                }
            }
        } header: {
            Text("Hydration Goal")
        }
    }

    private var unitSection: some View {
        Section {
            Picker("Unit", selection: $hydrationStore.unit) {
                ForEach(HydrationUnit.allCases, id: \.self) { unit in
                    Text(unit.rawValue).tag(unit)
                }
            }
            .pickerStyle(.segmented)
        } header: {
            Text("Display Unit")
        }
    }

    private var reminderSection: some View {
        Section {
            HStack {
                Text("Remind every")
                Spacer()
                Picker("Interval", selection: $hydrationStore.reminderInterval) {
                    Text("30 min").tag(30)
                    Text("1 hour").tag(60)
                    Text("90 min").tag(90)
                    Text("2 hours").tag(120)
                }
                .pickerStyle(.menu)
            }

            if !storeManager.isPremium {
                Button(action: { showPaywall = true }) {
                    HStack {
                        Image(systemName: "bell.badge.fill")
                            .foregroundStyle(HydroTheme.primaryGradient)
                        Text("Unlock smart schedule reminders")
                            .font(.system(size: 14))
                            .foregroundColor(HydroTheme.darkText)
                        Spacer()
                        Label("PRO", systemImage: "lock.fill")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(HydroTheme.premiumGradient)
                            .cornerRadius(4)
                    }
                }
            }
        } header: {
            Text("Reminders")
        }
    }

    private var aboutSection: some View {
        Section {
            Button("Restore Purchases") {
                Task { await storeManager.restorePurchases() }
            }
            .foregroundColor(HydroTheme.deepBlue)

            Link("Privacy Policy", destination: URL(string: "https://sebastiandoyle.github.io/hydromind-privacy/privacy-policy.html")!)

            HStack {
                Text("Version")
                Spacer()
                Text("1.0.0")
                    .foregroundColor(HydroTheme.secondaryText)
            }
        } header: {
            Text("About")
        }
    }
}
