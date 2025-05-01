//
//  ButtonStyleExtension.swift
//  SakuMemo
//
//  Created by saki on 2025/05/01.
//

import Foundation
import SwiftUI

struct CustomButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled: Bool
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(isEnabled ? .white : Color(.placeholderText))
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(isEnabled ? .cyan : Color(.secondarySystemFill))
                       .opacity(configuration.isPressed ? 0.2 : 1.0)
                       .clipShape(RoundedRectangle(cornerRadius: 8))
                       .hoverEffect()
        
    }
}
extension ButtonStyle where Self == CustomButtonStyle {
    static var customButton: CustomButtonStyle {
        .init()
    }
}
