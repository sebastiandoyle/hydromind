import XCTest
@testable import HydroMind

final class HydrationStoreTests: XCTestCase {

    var store: HydrationStore!

    override func setUp() {
        super.setUp()
        store = HydrationStore()
        // Clear existing entries for test isolation
        UserDefaults.standard.removeObject(forKey: "hydrationEntries")
        store = HydrationStore()
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "hydrationEntries")
        super.tearDown()
    }

    // MARK: - Entry Tests

    func testAddWaterEntry() {
        store.addEntry(amount: 250)
        XCTAssertEqual(store.entries.count, 1)
        XCTAssertEqual(store.entries.first?.amount, 250)
        XCTAssertEqual(store.entries.first?.drinkType, .water)
    }

    func testAddDifferentDrinkTypes() {
        store.addEntry(amount: 200, drinkType: .coffee)
        store.addEntry(amount: 300, drinkType: .tea)
        XCTAssertEqual(store.entries.count, 2)
        XCTAssertEqual(store.entries[0].drinkType, .coffee)
        XCTAssertEqual(store.entries[1].drinkType, .tea)
    }

    func testRemoveEntry() {
        store.addEntry(amount: 250)
        let entry = store.entries.first!
        store.removeEntry(entry)
        XCTAssertTrue(store.entries.isEmpty)
    }

    // MARK: - Today Tracking Tests

    func testTodayTotal() {
        store.addEntry(amount: 250) // water = 1.0 factor
        store.addEntry(amount: 200) // water = 1.0 factor
        XCTAssertEqual(store.todayTotal, 450.0)
    }

    func testTodayTotalWithHydrationFactors() {
        store.addEntry(amount: 200, drinkType: .coffee) // 0.8 factor
        // Expected: 200 * 0.8 = 160
        XCTAssertEqual(store.todayTotal, 160.0)
    }

    func testTodayProgress() {
        store.dailyGoal = 2000
        store.addEntry(amount: 1000)
        XCTAssertEqual(store.todayProgress, 0.5, accuracy: 0.01)
    }

    func testTodayProgressCappedAtOne() {
        store.dailyGoal = 1000
        store.addEntry(amount: 1500)
        XCTAssertEqual(store.todayProgress, 1.0)
    }

    // MARK: - Daily Goal Tests

    func testDailyGoalPersistence() {
        store.dailyGoal = 3000
        let newStore = HydrationStore()
        XCTAssertEqual(newStore.dailyGoal, 3000)
        // Reset
        store.dailyGoal = 2500
    }

    func testDefaultDailyGoal() {
        UserDefaults.standard.removeObject(forKey: "dailyGoal")
        let freshStore = HydrationStore()
        XCTAssertEqual(freshStore.dailyGoal, 2500)
    }

    // MARK: - Unit Tests

    func testDisplayAmountMilliliters() {
        store.unit = .mL
        XCTAssertEqual(store.displayAmount(250), "250 mL")
    }

    func testDisplayAmountOunces() {
        store.unit = .oz
        let result = store.displayAmount(250)
        XCTAssertTrue(result.contains("oz"))
    }

    func testDisplayAmountCups() {
        store.unit = .cups
        let result = store.displayAmount(250)
        XCTAssertTrue(result.contains("cups"))
    }

    // MARK: - Drink Type Tests

    func testDrinkTypeHydrationFactors() {
        XCTAssertEqual(DrinkType.water.hydrationFactor, 1.0)
        XCTAssertEqual(DrinkType.coffee.hydrationFactor, 0.8)
        XCTAssertEqual(DrinkType.tea.hydrationFactor, 0.9)
        XCTAssertEqual(DrinkType.juice.hydrationFactor, 0.85)
        XCTAssertEqual(DrinkType.sparkling.hydrationFactor, 1.0)
    }

    func testAllDrinkTypesHaveIcons() {
        for type in DrinkType.allCases {
            XCTAssertFalse(type.icon.isEmpty, "\(type.rawValue) should have an icon")
        }
    }

    // MARK: - Weekly Data Tests

    func testWeeklyDataReturnsSixDays() {
        // Should return 7 data points (one per day of the week)
        let data = store.weeklyData
        XCTAssertEqual(data.count, 7)
    }

    // MARK: - Streak Tests

    func testStreakStartsAtZero() {
        XCTAssertEqual(store.currentStreak, 0)
    }

    // MARK: - Data Persistence Tests

    func testEntriesPersistAcrossInstances() {
        store.addEntry(amount: 500)
        let newStore = HydrationStore()
        XCTAssertFalse(newStore.entries.isEmpty)
        XCTAssertEqual(newStore.entries.first?.amount, 500)
    }
}

final class StoreManagerTests: XCTestCase {

    @MainActor
    func testProductIDsAreDefined() {
        XCTAssertEqual(StoreManager.weeklyID, "com.sebastiandoyle.hydromind.weekly")
        XCTAssertEqual(StoreManager.annualID, "com.sebastiandoyle.hydromind.annual")
        XCTAssertEqual(StoreManager.lifetimeID, "com.sebastiandoyle.hydromind.lifetime")
    }

    @MainActor
    func testInitialStateIsNotPremium() {
        let manager = StoreManager()
        XCTAssertFalse(manager.isPremium)
        XCTAssertTrue(manager.purchasedProductIDs.isEmpty)
    }

    @MainActor
    func testPremiumDetection() {
        let manager = StoreManager()
        XCTAssertFalse(manager.isPremium)
        // When purchasedProductIDs is populated, isPremium should be true
        manager.purchasedProductIDs.insert(StoreManager.weeklyID)
        XCTAssertTrue(manager.isPremium)
    }
}
