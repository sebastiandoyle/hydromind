import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var hydrationStore: HydrationStore
    @EnvironmentObject var storeManager: StoreManager
    @State private var showAddSheet = false
    @State private var showPaywall = false
    @State private var animateProgress = false

    var body: some View {
        NavigationStack {
            ZStack {
                HydroTheme.backgroundGradient.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Progress Ring
                        progressCard
                            .padding(.top, 8)

                        // Quick add buttons
                        quickAddSection

                        // Today's log
                        todayLogSection

                        // Weekly overview (Premium)
                        weeklyPreview
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("HydroMind")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !storeManager.isPremium {
                        Button(action: { showPaywall = true }) {
                            Image(systemName: "crown.fill")
                                .foregroundStyle(HydroTheme.premiumGradient)
                        }
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddDrinkSheet()
                    .environmentObject(hydrationStore)
                    .presentationDetents([.medium])
            }
            .fullScreenCover(isPresented: $showPaywall) {
                PaywallView(isPresented: $showPaywall)
                    .environmentObject(storeManager)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0).delay(0.3)) {
                animateProgress = true
            }
        }
    }

    private var progressCard: some View {
        VStack(spacing: 16) {
            ZStack {
                // Background track
                Circle()
                    .stroke(HydroTheme.lightBlue, lineWidth: 16)
                    .frame(width: 200, height: 200)

                // Progress arc
                Circle()
                    .trim(from: 0, to: animateProgress ? hydrationStore.todayProgress : 0)
                    .stroke(HydroTheme.primaryGradient, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))

                // Center content
                VStack(spacing: 4) {
                    Text(hydrationStore.displayAmount(hydrationStore.todayTotal))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(HydroTheme.darkText)
                    Text("of \(hydrationStore.displayAmount(hydrationStore.dailyGoal))")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(HydroTheme.secondaryText)
                    Text("\(Int(hydrationStore.todayProgress * 100))%")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(HydroTheme.deepBlue)
                }
            }

            // Streak
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .foregroundColor(HydroTheme.coral)
                Text("\(hydrationStore.currentStreak) day streak")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(HydroTheme.darkText)
            }
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.white)
                .shadow(color: HydroTheme.deepBlue.opacity(0.08), radius: 20, y: 8)
        )
    }

    private var quickAddSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Add")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(HydroTheme.darkText)

            HStack(spacing: 12) {
                QuickAddButton(amount: 250, unit: hydrationStore.unit) {
                    hydrationStore.addEntry(amount: 250)
                }
                QuickAddButton(amount: 350, unit: hydrationStore.unit) {
                    hydrationStore.addEntry(amount: 350)
                }
                QuickAddButton(amount: 500, unit: hydrationStore.unit) {
                    hydrationStore.addEntry(amount: 500)
                }

                Button(action: { showAddSheet = true }) {
                    VStack(spacing: 6) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(HydroTheme.primaryGradient)
                        Text("Custom")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(HydroTheme.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 72)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.white)
                            .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
                    )
                }
            }
        }
    }

    private var todayLogSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Today's Log")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(HydroTheme.darkText)
                Spacer()
                Text("\(hydrationStore.todayEntries.count) entries")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(HydroTheme.secondaryText)
            }

            if hydrationStore.todayEntries.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "drop")
                        .font(.system(size: 32))
                        .foregroundColor(HydroTheme.lightBlue)
                    Text("Start your day with a glass of water")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(HydroTheme.secondaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.white)
                        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
                )
            } else {
                ForEach(hydrationStore.todayEntries.suffix(5).reversed()) { entry in
                    EntryRow(entry: entry, unit: hydrationStore.unit)
                }
            }
        }
    }

    private var weeklyPreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("This Week")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(HydroTheme.darkText)
                Spacer()
                if !storeManager.isPremium {
                    Label("PRO", systemImage: "lock.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(HydroTheme.premiumGradient)
                        .cornerRadius(6)
                }
            }

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(hydrationStore.weeklyData, id: \.0) { day, amount in
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(amount >= hydrationStore.dailyGoal ? HydroTheme.primaryGradient : LinearGradient(colors: [HydroTheme.lightBlue], startPoint: .bottom, endPoint: .top))
                            .frame(height: max(6, CGFloat(amount / hydrationStore.dailyGoal) * 80))
                        Text(day)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(HydroTheme.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 110)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
            )
            .overlay(
                Group {
                    if !storeManager.isPremium {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.white.opacity(0.7))
                            .overlay(
                                Button(action: { showPaywall = true }) {
                                    VStack(spacing: 6) {
                                        Image(systemName: "lock.fill")
                                            .font(.system(size: 22))
                                        Text("Unlock Insights")
                                            .font(.system(size: 14, weight: .semibold))
                                    }
                                    .foregroundStyle(HydroTheme.primaryGradient)
                                }
                            )
                    }
                }
            )
        }
    }
}

struct QuickAddButton: View {
    let amount: Double
    let unit: HydrationUnit
    let action: () -> Void

    var displayText: String {
        switch unit {
        case .mL: return "\(Int(amount))"
        case .oz: return String(format: "%.0f", amount / 29.5735)
        case .cups: return String(format: "%.1f", amount / 236.588)
        }
    }

    var unitText: String {
        unit.rawValue
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: "drop.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(HydroTheme.primaryGradient)
                Text(displayText)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(HydroTheme.darkText)
                Text(unitText)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(HydroTheme.secondaryText)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 72)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
            )
        }
    }
}

struct EntryRow: View {
    let entry: WaterEntry
    let unit: HydrationUnit

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: entry.drinkType.icon)
                .font(.system(size: 18))
                .foregroundColor(entry.drinkType.color)
                .frame(width: 36, height: 36)
                .background(entry.drinkType.color.opacity(0.12))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.drinkType.rawValue)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(HydroTheme.darkText)
                Text(entry.date.formatted(date: .omitted, time: .shortened))
                    .font(.system(size: 12))
                    .foregroundColor(HydroTheme.secondaryText)
            }

            Spacer()

            Text(displayAmount(entry.amount))
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(HydroTheme.deepBlue)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.white)
                .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
        )
    }

    func displayAmount(_ mL: Double) -> String {
        switch unit {
        case .mL: return "\(Int(mL)) mL"
        case .oz: return String(format: "%.1f oz", mL / 29.5735)
        case .cups: return String(format: "%.1f cups", mL / 236.588)
        }
    }
}
