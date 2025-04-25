//
//  MemoEntity.swift
//  SakuMemo
//
//  Created by saki on 2025/04/24.
//

import Foundation
import AppIntents
import SwiftUI



struct Shortcut: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddMemoIntent(),
            phrases: [
                "\(.applicationName)の画面を開いて",
                "\(.applicationName)の画面を見せて",
                "\(.applicationName)をお願い"
            ],
            shortTitle: "メモを追加する",
            systemImageName: "pencil")
    }
}


struct AddMemoIntent: AppIntent {
    static let title: LocalizedStringResource = "メモを追加"
    
    static var openAppWhenRun: Bool = true
    @Parameter(title: "メモの内容")
    var content: String
    
    @MainActor
    func perform() async throws -> some IntentResult {
        print("入力されたメモ：\(content)")
        
              // ここで保存処理などを書く
              return .result()
    }
}
