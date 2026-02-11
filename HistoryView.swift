import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var hydrationStore: HydrationStore
    @EnvironmentObject var storeManager: StoreManager
    @State private var showPaywall = false
    @State private var selectedTimeframe = 0

    private let timeframes = ["Week", "Month", "All Time"]

    var body: some View {
        NavigationStack {
            ZStack {
                HydroTheme.backgroundGradient.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Timeframe picker
                        Picker("Timeframe", selection: $selectedTimeframe) {
                            ForEach(0..<timeframes.count, id: \.self) { i in
                                Text(timeframes[i]).tag(i)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, 20)

                        // Stats cards
                        statsCards

                        // Chart
                        weeklyChart

                        // Drink breakdown (premium)
                        drinkBreakdown

                        // Entry list
                        entryList
                    }
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("History")
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
            .fullScreenCover(isPresented: $showPaywall) {
                PaywallView(isPresented: $showPaywall)
                    .environmentObject(storeManager)
            }
        }
    }

    private var statsCards: some View {
        HStack(spacing: 12) {
            StatCard(title: "Average", value: averageDaily, icon: "chart.line.uptrend.xyaxis", color: HydroTheme.deepBlue)
            StatCard(title: "Best Day", value: bestDay, icon: "trophy.fill", color: HydroTheme.gold)
            StatCard(title: "Streak", value: "\(hydrationStore.currentStreak)d", icon: "flame.fill", color: HydroTheme.coral)
        }
        .padding(.horizontal, 20)
    }

    private var averageDaily: String {
        let entries = filteredEntries
        guard !entries.isEmpty else { return "0 mL" }
        let days = Set(entries.map { Calendar.current.startOfDay(for: $0.date) }).count
        let total = entries.reduce(0) { $0 + ($1.amount * $1.drinkType.hydrationFactor) }
        return hydrationStore.displayAmount(total / Double(max(1, days)))
    }

    private var bestDay: String {
        let grouped = Dictionary(grouping: hydrationStore.entries) { Calendar.current.startOfDay(for: $0.date) }
        let best = grouped.values.map { entries in
            entries.reduce(0) { $0 + ($1.amount * $1.drinkType.hydrationFactor) }
        }.max() ?? 0
        return hydrationStore.displayAmount(best)
    }

    private var filteredEntries: [WaterEntry] {
        let calendar = Calendar.current
        switch selectedTimeframe {
        case 0: // Week
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
            return hydrationStore.entries.filter { $0.date >= weekAgo }
        case 1: // Month
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: Date())!
            return hydrationStore.entries.filter { $0.date >= monthAgo }
        default:
            return hydrationStore.entries
        }
    }

    private var weeklyChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily Intake")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(HydroTheme.darkText)
                .padding(.horizontal, 20)

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(hydrationStore.weeklyData, id: \.0) { day, amount in
                    VStack(spacing: 6) {
                        Text(hydrationStore.displayAmount(amount))
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(HydroTheme.secondaryText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)

                        RoundedRectangle(cornerRadius: 8)
                            .fill(amount >= hydrationStore.dailyGoal ? HydroTheme.primaryGradient : LinearGradient(colors: [HydroTheme.lightBlue], startPoint: .bottom, endPoint: .top))
                            .frame(height: max(8, CGFloat(amount / hydrationStore.dailyGoal) * 100))

                        Text(day)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(HydroTheme.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 160)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.04), radius: 10, y: 4)
            )
            .padding(.horizontal, 20)

            // Goal line label
            HStack {
                Rectangle()
                    .fill(HydroTheme.coral.opacity(0.5))
                    .frame(width: 20, height: 2)
                Text("Daily goal: \(hydrationStore.displayAmount(hydrationStore.dailyGoal))")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(HydroTheme.secondaryText)
            }
            .padding(.horizontal, 20)
        }
    }

    private var drinkBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Drink Breakdown")
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

            let breakdown = Dictionary(grouping: filteredEntries) { $0.drinkType }
                .mapValues { entries in entries.reduce(0) { $0 + $1.amount } }
                .sorted { $0.value > $1.value }

            ForEach(breakdown, id: \.key) { drink, total in
                HStack(spacing: 12) {
                    Image(systemName: drink.icon)
                        .foregroundColor(drink.color)
                        .frame(width: 30)
                    Text(drink.rawValue)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(HydroTheme.darkText)
                    Spacer()
                    Text(hydrationStore.displayAmount(total))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(HydroTheme.deepBlue)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .shadow(color: .black.opacity(0.04), radius: 10, y: 4)
        )
        .padding(.horizontal, 20)
        .overlay(
            Group {
                if !storeManager.isPremium {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.white.opacity(0.8))
                        .padding(.horizontal, 20)
                        .overlay(
                            Button(action: { showPaywall = true }) {
                                VStack(spacing: 6) {
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 22))
                                    Text("Unlock Detailed Analytics")
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                .foregroundStyle(HydroTheme.primaryGradient)
                            }
                        )
                }
            }
        )
    }

    private var entryList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Entries")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(HydroTheme.darkText)
                .padding(.horizontal, 20)

            ForEach(filteredEntries.suffix(10).reversed()) { entry in
                EntryRow(entry: entry, unit: hydrationStore.unit)
                    .padding(.horizontal, 20)
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(HydroTheme.darkText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(HydroTheme.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
        )
    }
}
