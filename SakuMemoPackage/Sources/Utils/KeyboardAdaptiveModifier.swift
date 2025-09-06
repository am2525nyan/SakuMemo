import SwiftUI

public struct KeyboardAdaptiveModifier: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0

    public func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .padding(.bottom, keyboardHeight)
                .animation(.easeOut(duration: 0.25), value: keyboardHeight)
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
                    guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                        return
                    }

                    let keyboardTop = geometry.frame(in: .global).maxY - keyboardFrame.height
                    if keyboardTop < geometry.frame(in: .global).maxY {
                        keyboardHeight = max(0, keyboardFrame.height - geometry.safeAreaInsets.bottom)
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                    keyboardHeight = 0
                }
        }
    }
}

public extension View {
    func keyboardAdaptive() -> some View {
        modifier(KeyboardAdaptiveModifier())
    }
}
