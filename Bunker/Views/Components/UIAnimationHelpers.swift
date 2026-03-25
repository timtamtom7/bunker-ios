import SwiftUI

// MARK: - Animation Extensions

extension Animation {
    static let bunkerSpring = Animation.spring(response: 0.4, dampingFraction: 0.75)
    static let bunkerEaseOut = Animation.easeOut(duration: 0.3)
    static let bunkerEaseIn = Animation.easeIn(duration: 0.2)
}

// MARK: - Shake Animation

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0))
    }
}

struct ShakeModifier: ViewModifier {
    let shakes: Int
    @State private var shakeAmount: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .modifier(ShakeEffect(shakesPerUnit: 3, animatableData: shakeAmount))
            .onChange(of: shakes) { _, newValue in
                withAnimation(.linear(duration: 0.4)) {
                    shakeAmount = CGFloat(newValue)
                }
            }
    }
}

extension View {
    func shake(trigger: Int) -> some View {
        modifier(ShakeModifier(shakes: trigger))
    }
}

// MARK: - Pulse Animation

struct PulseModifier: ViewModifier {
    let isActive: Bool
    @State private var isPulsing = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing && isActive ? 1.05 : 1.0)
            .opacity(isPulsing && isActive ? 0.8 : 1.0)
            .onChange(of: isActive) { _, newValue in
                if newValue {
                    withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                        isPulsing = true
                    }
                } else {
                    withAnimation {
                        isPulsing = false
                    }
                }
            }
    }
}

extension View {
    func pulse(when isActive: Bool) -> some View {
        modifier(PulseModifier(isActive: isActive))
    }
}

// MARK: - Card Hover/Press Effect

struct CardPressModifier: ViewModifier {
    @State private var isPressed = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(.bunkerSpring, value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
            )
    }
}

extension View {
    func cardPress() -> some View {
        modifier(CardPressModifier())
    }
}

// MARK: - Slide In Modifier

struct SlideInModifier: ViewModifier {
    let edge: Edge
    let isShown: Bool
    @State private var offset: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .offset(x: edge == .leading ? offset : 0,
                    y: edge == .top ? offset : edge == .bottom ? -offset : 0)
            .onChange(of: isShown) { _, newValue in
                withAnimation(.bunkerSpring) {
                    offset = newValue ? 0 : (edge == .leading ? -50 : 50)
                }
            }
            .onAppear {
                offset = isShown ? 0 : (edge == .leading ? -50 : 50)
            }
    }
}

extension View {
    func slideIn(from edge: Edge, when isShown: Bool) -> some View {
        modifier(SlideInModifier(edge: edge, isShown: isShown))
    }
}
