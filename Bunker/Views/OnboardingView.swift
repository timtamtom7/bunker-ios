import SwiftUI

@MainActor struct OnboardingView: View {
    @State private var currentStep = 0
    @State private var isComplete = false
    private let steps = OnboardingService.steps

    var body: some View {
        ZStack {
            Color.bunkerBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress dots
                HStack(spacing: Spacing.xs) {
                    ForEach(0..<steps.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentStep ? Color.bunkerPrimary : Color.bunkerDivider)
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.top, Spacing.xl)

                Spacer()

                // Content
                VStack(spacing: Spacing.lg) {
                    Image(systemName: steps[currentStep].systemImage)
                        .font(.system(size: 72))
                        .foregroundStyle(Color.bunkerPrimary)

                    VStack(spacing: Spacing.sm) {
                        Text(steps[currentStep].title)
                            .font(.bunkerHeading1)
                            .foregroundStyle(Color.bunkerTextPrimary)
                            .multilineTextAlignment(.center)

                        Text(steps[currentStep].subtitle)
                            .font(.bunkerHeading3)
                            .foregroundStyle(Color.bunkerPrimary)
                            .multilineTextAlignment(.center)

                        Text(steps[currentStep].description)
                            .font(.bunkerBody)
                            .foregroundStyle(Color.bunkerTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal, Spacing.xl)

                Spacer()

                // CTA
                VStack(spacing: Spacing.md) {
                    Button {
                        advanceStep()
                    } label: {
                        Text(steps[currentStep].cta)
                            .font(.bunkerHeading2)
                            .foregroundStyle(Color.bunkerBackground)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Spacing.md)
                            .background(Color.bunkerPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    if currentStep < steps.count - 1 {
                        Button {
                            skipToEnd()
                        } label: {
                            Text("Skip")
                                .font(.bunkerBodySmall)
                                .foregroundStyle(Color.bunkerTextTertiary)
                        }
                    }
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.bottom, Spacing.xxl)
            }
        }
    }

    private func advanceStep() {
        if currentStep < steps.count - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep += 1
            }
        } else {
            completeOnboarding()
        }
    }

    private func skipToEnd() {
        completeOnboarding()
    }

    private func completeOnboarding() {
        OnboardingService.shared.complete()
        isComplete = true
    }
}

#Preview {
    OnboardingView()
        .preferredColorScheme(.dark)
}
