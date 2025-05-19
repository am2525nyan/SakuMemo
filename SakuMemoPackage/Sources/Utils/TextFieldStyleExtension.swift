//
//  TextFieldStyleExtension.swift
//  SakuMemo
//
//  Created by saki on 2025/04/30.
//

import SwiftUI

public struct CustomTextFieldStyle: TextFieldStyle {
    @FocusState private var isFocused: Bool
    
    public init(isFocused: FocusState<Bool>) {
        self._isFocused = isFocused
    }
    
    public func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .frame(maxWidth: .infinity)
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isFocused ? .cyan : .gray, lineWidth: 1)
            )
    }
}

extension TextFieldStyle where Self == CustomTextFieldStyle {
    public static func customTextField(isFocused: FocusState<Bool>) -> CustomTextFieldStyle {
        CustomTextFieldStyle(isFocused: isFocused)
    }
}
