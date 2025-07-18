//
//  ButtonStyleExtension.swift
//  SakuMemo
//
//  Created by saki on 2025/05/01.
//

import SwiftUI
import SharedModel

public struct CustomButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled: Bool
    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(isEnabled ? .white : Color.secondary)
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(isEnabled ? Color.mainColor : Color(.secondarySystemFill))
                       .opacity(configuration.isPressed ? 0.2 : 1.0)
                       .clipShape(RoundedRectangle(cornerRadius: 8))
        
    }
}
public extension ButtonStyle where Self == CustomButtonStyle {
    static var customButton: CustomButtonStyle {
        .init()
    }
}
