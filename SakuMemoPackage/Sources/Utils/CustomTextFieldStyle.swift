//
//  CustomTextFieldStyle.swift
//  SakuMemo
//
//  Created by saki on 2025/04/30.
//

import SharedModel
import SwiftUI

public struct CustomTextFieldStyle: TextFieldStyle {
    @FocusState private var isFocused: Bool

    public init(isFocused: FocusState<Bool>) {
        self._isFocused = isFocused
    }

    public func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .frame(maxWidth: .infinity, minHeight: 20)
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isFocused ? Color.mainColor : .gray, lineWidth: 1)
            )
            .fixedSize(horizontal: false, vertical: true) // 縦方向の制約を改善
    }
}

public extension TextFieldStyle where Self == CustomTextFieldStyle {
    static func customTextField(isFocused: FocusState<Bool>) -> CustomTextFieldStyle {
        CustomTextFieldStyle(isFocused: isFocused)
    }
}
