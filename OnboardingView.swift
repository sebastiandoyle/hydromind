import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @EnvironmentObject var storeManager: StoreManager
    @State private var currentPage = 0
    @State private var showPaywall = false
    @State private var dailyGoal: Double = 2500
    @State private var wakeTime = Calendar.current.date(from: DateComponents(hour: 7, minute: 0)) ?? Date()
    @State private var sleepTime = Calendar.current.date(from: DateComponents(hour: 23, minute: 0)) ?? Date()

    private let pages: [(icon: String, title: String, subtitle: String, gradient: [Color])] = [
        ("drop.fill", "Stay Hydrated,\nStay Sharp", "Your body is 60% water. Even mild dehydration can fog your thinking and drain your energy.", [Color(red: 0.0, green: 0.40, blue: 0.85), Color(red: 0.0, green: 0.75, blue: 0.95)]),
        ("brain.head.profile", "Feel the\nDifference", "Better focus. More energy. Clearer skin. Proper hydration transforms how you feel every single day.", [Color(red: 0.20, green: 0.50, blue: 0.90), Color(red: 0.30, green: 0.87, blue: 0.75)]),
        ("chart.line.uptrend.xyaxis", "Build a Habit\nThat Sticks", "Smart reminders adapt to your schedule. Track your progress and watch your streak grow.", [Color(red: 0.0, green: 0.65, blue: 0.90), Color(red: 0.0, green: 0.85, blue: 0.75)]),
    ]

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: pages[currentPage].gradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.5), value: currentPage)

            VStack(spacing: 0) {
                Spacer()

                // Icon
                Image(systemName: pages[currentPage].icon)
                    .font(.system(size: 80, weight: .light))
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.bottom, 40)
                    .id(currentPage)
                    .transition(.scale.combined(with: .opacity))

                // Title
                Text(pages[currentPage].title)
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .id("title-\(currentPage)")
                    .transition(.slide)

                // Subtitle
                Text(pages[currentPage].subtitle)
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 16)
                    .id("sub-\(currentPage)")

                Spacer()

                // Page indicators
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Capsule()
                            .fill(index == currentPage ? .white : .white.opacity(0.4))
                            .frame(width: index == currentPage ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, 30)

                // CTA Button
                Button(action: {
                    withAnimation(.spring(response: 0.4)) {
                        if currentPage < pages.count - 1 {
                            currentPage += 1
                        } else {
                            showPaywall = true
                        }
                    }
                }) {
                    Text(currentPage < pages.count - 1 ? "Continue" : "Get Started")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(pages[currentPage].gradient.first ?? .blue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(.white)
                        .cornerRadius(16)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)

                if currentPage == pages.count - 1 {
                    Button("Maybe Later") {
                        hasCompletedOnboarding = true
                    }
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.bottom, 20)
                }
            }
            .padding(.bottom, 30)
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView(isPresented: $showPaywall, onComplete: {
                hasCompletedOnboarding = true
            })
            .environmentObject(storeManager)
        }
    }
}
