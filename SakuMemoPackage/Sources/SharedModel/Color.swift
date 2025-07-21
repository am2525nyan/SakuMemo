//
//  Color.swift
//  SakuMemoPackage
//
//  Created by saki on 2025/05/22.
//

import SwiftUI

public extension Color {
    static let mainColor: Color = {
        #if DEBUG
            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                return Color.cyan // プレビュー時の色
            }
        #endif
        return Color("MainColor") // 実機や本番の色
    }()

    static let customPinkColor: Color = {
        #if DEBUG
            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                return Color.pink
            }
        #endif
        return Color("CustomPink")
    }()

    static let customTextColor: Color = {
        #if DEBUG
            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                return Color.gray
            }
        #endif
        return Color("TextColor")
    }()
}
