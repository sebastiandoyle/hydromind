import SwiftUI
import Combine

struct WaterEntry: Identifiable, Codable {
    let id: UUID
    let amount: Double // in mL
    let date: Date
    let drinkType: DrinkType

    init(id: UUID = UUID(), amount: Double, date: Date = Date(), drinkType: DrinkType = .water) {
        self.id = id
        self.amount = amount
        self.date = date
        self.drinkType = drinkType
    }
}

enum DrinkType: String, Codable, CaseIterable {
    case water = "Water"
    case tea = "Tea"
    case coffee = "Coffee"
    case juice = "Juice"
    case sparkling = "Sparkling"
    case milk = "Milk"

    var icon: String {
        switch self {
        case .water: return "drop.fill"
        case .tea: return "leaf.fill"
        case .coffee: return "cup.and.saucer.fill"
        case .juice: return "carrot.fill"
        case .sparkling: return "bubbles.and.sparkles.fill"
        case .milk: return "cup.and.saucer.fill"
        }
    }

    var color: Color {
        switch self {
        case .water: return HydroTheme.deepBlue
        case .tea: return .green
        case .coffee: return .brown
        case .juice: return .orange
        case .sparkling: return HydroTheme.aqua
        case .milk: return .white
        }
    }

    /// Hydration factor relative to pure water
    var hydrationFactor: Double {
        switch self {
        case .water: return 1.0
        case .tea: return 0.9
        case .coffee: return 0.8
        case .juice: return 0.85
        case .sparkling: return 1.0
        case .milk: return 0.9
        }
    }
}

class HydrationStore: ObservableObject {
    @Published var entries: [WaterEntry] = []
    @Published var dailyGoal: Double {
        didSet { UserDefaults.standard.set(dailyGoal, forKey: "dailyGoal") }
    }
    @Published var reminderInterval: Int {
        didSet { UserDefaults.standard.set(reminderInterval, forKey: "reminderInterval") }
    }
    @Published var unit: HydrationUnit {
        didSet { UserDefaults.standard.set(unit.rawValue, forKey: "hydrationUnit") }
    }

    private let entriesKey = "hydrationEntries"

    init() {
        let savedGoal = UserDefaults.standard.double(forKey: "dailyGoal")
        _dailyGoal = Published(initialValue: savedGoal > 0 ? savedGoal : 2500)

        let savedInterval = UserDefaults.standard.integer(forKey: "reminderInterval")
        _reminderInterval = Published(initialValue: savedInterval > 0 ? savedInterval : 60)

        let unitRaw = UserDefaults.standard.string(forKey: "hydrationUnit") ?? "mL"
        _unit = Published(initialValue: HydrationUnit(rawValue: unitRaw) ?? .mL)

        loadEntries()
    }

    var todayEntries: [WaterEntry] {
        let calendar = Calendar.current
        return entries.filter { calendar.isDateInToday($0.date) }
    }

    var todayTotal: Double {
        todayEntries.reduce(0) { $0 + ($1.amount * $1.drinkType.hydrationFactor) }
    }

    var todayProgress: Double {
        min(todayTotal / dailyGoal, 1.0)
    }

    var currentStreak: Int {
        let calendar = Calendar.current
        var streak = 0
        var date = Date()

        // Check if today goal is met
        if todayTotal >= dailyGoal {
            streak = 1
            date = calendar.date(byAdding: .day, value: -1, to: date)!
        } else {
            date = calendar.date(byAdding: .day, value: -1, to: date)!
        }

        while true {
            let dayEntries = entries.filter { calendar.isDate($0.date, inSameDayAs: date) }
            let dayTotal = dayEntries.reduce(0) { $0 + ($1.amount * $1.drinkType.hydrationFactor) }
            if dayTotal >= dailyGoal {
                streak += 1
                date = calendar.date(byAdding: .day, value: -1, to: date)!
            } else {
                break
            }
        }
        return streak
    }

    var weeklyData: [(String, Double)] {
        let calendar = Calendar.current
        var data: [(String, Double)] = []
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"

        for i in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -i, to: Date()) else { continue }
            let dayEntries = entries.filter { calendar.isDate($0.date, inSameDayAs: date) }
            let total = dayEntries.reduce(0) { $0 + ($1.amount * $1.drinkType.hydrationFactor) }
            data.append((formatter.string(from: date), total))
        }
        return data
    }

    func addEntry(amount: Double, drinkType: DrinkType = .water) {
        let entry = WaterEntry(amount: amount, drinkType: drinkType)
        entries.append(entry)
        saveEntries()
    }

    func removeEntry(_ entry: WaterEntry) {
        entries.removeAll { $0.id == entry.id }
        saveEntries()
    }

    func displayAmount(_ mL: Double) -> String {
        switch unit {
        case .mL: return "\(Int(mL)) mL"
        case .oz: return String(format: "%.1f oz", mL / 29.5735)
        case .cups: return String(format: "%.1f cups", mL / 236.588)
        }
    }

    private func saveEntries() {
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: entriesKey)
        }
    }

    private func loadEntries() {
        if let data = UserDefaults.standard.data(forKey: entriesKey),
           let decoded = try? JSONDecoder().decode([WaterEntry].self, from: data) {
            entries = decoded
        }
    }

    func addSampleDataForScreenshot() {
        guard entries.isEmpty else { return }
        let calendar = Calendar.current
        let now = Date()
        
        // Add today's entries - showing good progress
        let todayEntries: [(Double, DrinkType, Int, Int)] = [
            (350, .water, 7, 30),
            (250, .coffee, 9, 0),
            (400, .water, 11, 15),
            (200, .tea, 13, 30),
            (300, .water, 15, 0),
            (250, .sparkling, 16, 45),
        ]
        
        for (amount, drinkType, hour, minute) in todayEntries {
            var comps = calendar.dateComponents([.year, .month, .day], from: now)
            comps.hour = hour
            comps.minute = minute
            if let date = calendar.date(from: comps) {
                let entry = WaterEntry(amount: amount, date: date, drinkType: drinkType)
                entries.append(entry)
            }
        }
        
        // Add past week entries for history chart
        for dayOffset in 1...6 {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: now) else { continue }
            let amounts: [Double] = [2200, 2600, 1800, 2500, 2100, 2400]
            let total = amounts[dayOffset - 1]
            var comps = calendar.dateComponents([.year, .month, .day], from: date)
            
            // Morning water
            comps.hour = 8; comps.minute = 0
            if let d = calendar.date(from: comps) {
                entries.append(WaterEntry(amount: total * 0.3, date: d, drinkType: .water))
            }
            // Midday
            comps.hour = 12; comps.minute = 30
            if let d = calendar.date(from: comps) {
                entries.append(WaterEntry(amount: total * 0.25, date: d, drinkType: .coffee))
            }
            // Afternoon
            comps.hour = 15; comps.minute = 0
            if let d = calendar.date(from: comps) {
                entries.append(WaterEntry(amount: total * 0.25, date: d, drinkType: .water))
            }
            // Evening
            comps.hour = 18; comps.minute = 0
            if let d = calendar.date(from: comps) {
                entries.append(WaterEntry(amount: total * 0.2, date: d, drinkType: .tea))
            }
        }
    }

}

enum HydrationUnit: String, CaseIterable {
    case mL = "mL"
    case oz = "oz"
    case cups = "cups"
}
