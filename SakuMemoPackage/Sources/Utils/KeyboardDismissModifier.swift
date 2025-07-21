import SwiftUI

public struct KeyboardDismissModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())
            .onTapGesture {
                hideKeyboard()
            }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

public extension View {
    func dismissKeyboardOnTap() -> some View {
        modifier(KeyboardDismissModifier())
    }
}
