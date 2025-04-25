//
//  MemoEntity.swift
//  SakuMemo
//
//  Created by saki on 2025/04/24.
//

import Foundation
import AppIntents
import SwiftUI

struct OpenAppIntent: AppIntent{
    static let title: LocalizedStringResource = "アプリを開く"
    static var openAppWhenRun: Bool = true
    
    @MainActor
    
    func perform() async throws -> some IntentResult {
        
        return .result()
        
    }
}

struct Shortcut: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: OpenAppIntent(),
            phrases: [
                "\(.applicationName)の画面を開いて",
                "\(.applicationName)の画面を見せて",
                "\(.applicationName)をお願い"
            ],
            shortTitle: "アプリを開く",
            systemImageName: "face.smiling.inverse")
    }
}
