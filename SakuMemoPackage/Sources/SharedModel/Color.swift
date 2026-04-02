//
//  Color.swift
//  SakuMemoPackage
//
//  Created by saki on 2025/05/22.
//

import SwiftUI

public extension Color {
    static let mainColor: Color = {
      
        return Color("MainColor", bundle: .module)
    }()

    static let customPinkColor: Color = {
      
        return Color("CustomPink", bundle: .module)
    }()

    static let customTextColor: Color = {
     
        return Color("TextColor", bundle: .module)
    }()
}
