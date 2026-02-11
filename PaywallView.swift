import SwiftUI
import StoreKit

struct PaywallView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var storeManager: StoreManager
    @State private var selectedPlan: String = StoreManager.annualID
    @State private var isPurchasing = false
    @State private var showError = false
    @State private var animateCheckmarks = false
    var onComplete: (() -> Void)?

    private let benefits = [
        ("drop.circle.fill", "Unlimited drink tracking", "Log every sip with detailed categories"),
        ("bell.badge.fill", "Smart reminders", "Personalized hydration nudges throughout your day"),
        ("chart.bar.fill", "Advanced insights", "Weekly & monthly trends to optimize your intake"),
        ("flame.fill", "Streak rewards", "Stay motivated with achievement milestones"),
    ]

    var body: some View {
        ZStack {
            HydroTheme.backgroundGradient.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header
                    headerSection

                    // Benefits
                    benefitsSection
                        .padding(.top, 24)

                    // Plans
                    plansSection
                        .padding(.top, 28)

                    // CTA
                    ctaSection
                        .padding(.top, 24)

                    // Footer
                    footerSection
                        .padding(.top, 16)
                        .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6).delay(0.3)) {
                animateCheckmarks = true
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                Spacer()
                Button(action: {
                    isPresented = false
                    onComplete?()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(HydroTheme.secondaryText)
                        .frame(width: 32, height: 32)
                        .background(Color.gray.opacity(0.12))
                        .clipShape(Circle())
                }
                .padding(.trailing, 20)
                .padding(.top, 16)
            }

            Image(systemName: "crown.fill")
                .font(.system(size: 44))
                .foregroundStyle(HydroTheme.premiumGradient)

            Text("Unlock Your\nFull Potential")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(HydroTheme.darkText)
                .multilineTextAlignment(.center)

            Text("Join thousands who transformed their\nhydration habits with HydroMind Pro")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(HydroTheme.secondaryText)
                .multilineTextAlignment(.center)
        }
    }

    private var benefitsSection: some View {
        VStack(spacing: 16) {
            ForEach(Array(benefits.enumerated()), id: \.offset) { index, benefit in
                HStack(spacing: 14) {
                    Image(systemName: benefit.0)
                        .font(.system(size: 22))
                        .foregroundStyle(HydroTheme.primaryGradient)
                        .frame(width: 36)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(benefit.1)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(HydroTheme.darkText)
                        Text(benefit.2)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(HydroTheme.secondaryText)
                    }

                    Spacer()

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(HydroTheme.mint)
                        .opacity(animateCheckmarks ? 1 : 0)
                        .scaleEffect(animateCheckmarks ? 1 : 0.5)
                        .animation(.spring(response: 0.4).delay(Double(index) * 0.15), value: animateCheckmarks)
                }
                .padding(.horizontal, 24)
            }
        }
    }

    private var plansSection: some View {
        VStack(spacing: 12) {
            // Annual plan - Best Value
            PlanCard(
                title: "Annual",
                price: storeManager.annualProduct?.displayPrice ?? "$19.99",
                period: "per year",
                badge: "BEST VALUE",
                savings: "Save 80%",
                isSelected: selectedPlan == StoreManager.annualID
            ) {
                selectedPlan = StoreManager.annualID
            }

            // Weekly plan
            PlanCard(
                title: "Weekly",
                price: storeManager.weeklyProduct?.displayPrice ?? "$1.99",
                period: "per week",
                badge: "3-DAY FREE TRIAL",
                savings: nil,
                isSelected: selectedPlan == StoreManager.weeklyID
            ) {
                selectedPlan = StoreManager.weeklyID
            }

            // Lifetime
            PlanCard(
                title: "Lifetime",
                price: storeManager.lifetimeProduct?.displayPrice ?? "$39.99",
                period: "one-time purchase",
                badge: "FOREVER",
                savings: nil,
                isSelected: selectedPlan == StoreManager.lifetimeID
            ) {
                selectedPlan = StoreManager.lifetimeID
            }
        }
        .padding(.horizontal, 20)
    }

    private var ctaSection: some View {
        VStack(spacing: 12) {
            Button(action: {
                Task { await purchaseSelected() }
            }) {
                HStack {
                    if isPurchasing {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text(selectedPlan == StoreManager.weeklyID ? "Start Free Trial" : "Continue")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(HydroTheme.primaryGradient)
                .cornerRadius(16)
                .shadow(color: HydroTheme.deepBlue.opacity(0.3), radius: 12, y: 6)
            }
            .disabled(isPurchasing)
            .padding(.horizontal, 20)

            if selectedPlan == StoreManager.weeklyID {
                Text("3-day free trial, then \(storeManager.weeklyProduct?.displayPrice ?? "$1.99")/week. Cancel anytime.")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(HydroTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
    }

    private var footerSection: some View {
        VStack(spacing: 8) {
            Button("Restore Purchases") {
                Task { await storeManager.restorePurchases() }
            }
            .font(.system(size: 13, weight: .medium))
            .foregroundColor(HydroTheme.secondaryText)

            HStack(spacing: 16) {
                Link("Terms of Use", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                Text("|").foregroundColor(.gray.opacity(0.5))
                Link("Privacy Policy", destination: URL(string: "https://sebastiandoyle.github.io/hydromind-privacy/privacy-policy.html")!)
            }
            .font(.system(size: 12, weight: .regular))
            .foregroundColor(HydroTheme.secondaryText.opacity(0.7))
        }
    }

    private func purchaseSelected() async {
        isPurchasing = true
        defer { isPurchasing = false }

        let product: Product?
        switch selectedPlan {
        case StoreManager.weeklyID: product = storeManager.weeklyProduct
        case StoreManager.annualID: product = storeManager.annualProduct
        case StoreManager.lifetimeID: product = storeManager.lifetimeProduct
        default: product = nil
        }

        guard let product else { return }

        do {
            let transaction = try await storeManager.purchase(product)
            if transaction != nil {
                isPresented = false
                onComplete?()
            }
        } catch {
            showError = true
        }
    }
}

struct PlanCard: View {
    let title: String
    let price: String
    let period: String
    let badge: String?
    let savings: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                // Radio
                Circle()
                    .strokeBorder(isSelected ? HydroTheme.deepBlue : Color.gray.opacity(0.3), lineWidth: 2)
                    .background(Circle().fill(isSelected ? HydroTheme.deepBlue : .clear))
                    .frame(width: 24, height: 24)
                    .overlay(
                        isSelected ? Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white) : nil
                    )

                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(title)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(HydroTheme.darkText)

                        if let badge {
                            Text(badge)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(isSelected ? HydroTheme.primaryGradient : LinearGradient(colors: [.gray], startPoint: .leading, endPoint: .trailing))
                                .cornerRadius(6)
                        }
                    }
                    Text(period)
                        .font(.system(size: 13))
                        .foregroundColor(HydroTheme.secondaryText)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(price)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(HydroTheme.darkText)

                    if let savings {
                        Text(savings)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(HydroTheme.mint)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isSelected ? HydroTheme.deepBlue : Color.gray.opacity(0.15), lineWidth: isSelected ? 2 : 1)
                    )
            )
            .shadow(color: isSelected ? HydroTheme.deepBlue.opacity(0.1) : .clear, radius: 8, y: 4)
        }
    }
}
