import SwiftUI

struct AddDrinkSheet: View {
    @EnvironmentObject var hydrationStore: HydrationStore
    @Environment(\.dismiss) var dismiss
    @State private var selectedAmount: Double = 250
    @State private var selectedDrink: DrinkType = .water
    @State private var customAmount: String = ""

    private let presets: [Double] = [100, 150, 200, 250, 350, 500, 750, 1000]

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Drink type picker
                VStack(alignment: .leading, spacing: 10) {
                    Text("What are you drinking?")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(HydroTheme.darkText)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(DrinkType.allCases, id: \.self) { drink in
                                Button(action: { selectedDrink = drink }) {
                                    VStack(spacing: 6) {
                                        Image(systemName: drink.icon)
                                            .font(.system(size: 22))
                                        Text(drink.rawValue)
                                            .font(.system(size: 11, weight: .medium))
                                    }
                                    .foregroundColor(selectedDrink == drink ? .white : HydroTheme.darkText)
                                    .frame(width: 70, height: 64)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(selectedDrink == drink ? AnyShapeStyle(HydroTheme.primaryGradient) : AnyShapeStyle(Color.gray.opacity(0.08)))
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }

                // Amount presets
                VStack(alignment: .leading, spacing: 10) {
                    Text("How much?")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(HydroTheme.darkText)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 10) {
                        ForEach(presets, id: \.self) { amount in
                            Button(action: {
                                selectedAmount = amount
                                customAmount = ""
                            }) {
                                Text(hydrationStore.displayAmount(amount))
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(selectedAmount == amount && customAmount.isEmpty ? .white : HydroTheme.darkText)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(selectedAmount == amount && customAmount.isEmpty ? AnyShapeStyle(HydroTheme.primaryGradient) : AnyShapeStyle(Color.gray.opacity(0.08)))
                                    )
                            }
                        }
                    }

                    // Custom amount
                    HStack {
                        TextField("Custom amount", text: $customAmount)
                            .keyboardType(.numberPad)
                            .font(.system(size: 16, weight: .medium))
                            .padding(12)
                            .background(Color.gray.opacity(0.08))
                            .cornerRadius(12)
                        Text(hydrationStore.unit.rawValue)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(HydroTheme.secondaryText)
                    }
                }

                Spacer()

                // Add button
                Button(action: addDrink) {
                    Text("Add \(displayAmount)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(HydroTheme.primaryGradient)
                        .cornerRadius(16)
                }
            }
            .padding(20)
            .navigationTitle("Log Drink")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(HydroTheme.deepBlue)
                }
            }
        }
    }

    private var displayAmount: String {
        if let custom = Double(customAmount), custom > 0 {
            return hydrationStore.displayAmount(custom)
        }
        return hydrationStore.displayAmount(selectedAmount)
    }

    private func addDrink() {
        let amount: Double
        if let custom = Double(customAmount), custom > 0 {
            amount = custom
        } else {
            amount = selectedAmount
        }
        hydrationStore.addEntry(amount: amount, drinkType: selectedDrink)
        dismiss()
    }
}
