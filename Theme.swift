import SwiftUI

enum HydroTheme {
    // Primary palette
    static let deepBlue = Color(red: 0.0, green: 0.40, blue: 0.85)
    static let aqua = Color(red: 0.0, green: 0.75, blue: 0.95)
    static let lightBlue = Color(red: 0.85, green: 0.94, blue: 1.0)
    static let paleBlue = Color(red: 0.93, green: 0.97, blue: 1.0)

    // Accent
    static let coral = Color(red: 1.0, green: 0.42, blue: 0.42)
    static let mint = Color(red: 0.30, green: 0.87, blue: 0.75)
    static let gold = Color(red: 1.0, green: 0.80, blue: 0.20)

    // Neutrals
    static let darkText = Color(red: 0.12, green: 0.14, blue: 0.20)
    static let secondaryText = Color(red: 0.45, green: 0.48, blue: 0.55)
    static let cardBackground = Color(red: 0.98, green: 0.98, blue: 1.0)

    // Gradients
    static let primaryGradient = LinearGradient(
        colors: [deepBlue, aqua],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let backgroundGradient = LinearGradient(
        colors: [paleBlue, .white],
        startPoint: .top,
        endPoint: .bottom
    )

    static let premiumGradient = LinearGradient(
        colors: [Color(red: 0.95, green: 0.78, blue: 0.20), Color(red: 1.0, green: 0.60, blue: 0.15)],
        startPoint: .leading,
        endPoint: .trailing
    )
}
