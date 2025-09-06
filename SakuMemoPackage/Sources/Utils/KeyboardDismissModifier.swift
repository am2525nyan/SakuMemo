import SwiftUI
import UIKit

public struct KeyboardDismissModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())
            .onTapGesture {
                hideKeyboard()
            }
    }

    private func hideKeyboard() {
        // Main Actorで安全に実行
        Task { @MainActor in
            // より安全なキーボード非表示方法
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.endEditing(true)
            } else {
                // フォールバック
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
    }
}

public extension View {
    func dismissKeyboardOnTap() -> some View {
        modifier(KeyboardDismissModifier())
    }
}
