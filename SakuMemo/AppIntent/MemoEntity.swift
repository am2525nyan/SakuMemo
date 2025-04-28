//
//  MemoEntity.swift
//  SakuMemo
//
//  Created by saki on 2025/04/24.
//

import AppIntents
import SwiftUI
import Dependencies
import ComposableArchitecture




struct Shortcut: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddMemoIntent(),
            phrases: [
                "\(.applicationName)の画面を開いて",
                "\(.applicationName)の画面を見せて",
                "\(.applicationName)をお願い",
                "メモを追加したい",
                "タスクを追加"
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
    @Dependencies.Dependency(\.swiftDataRepository) var swiftDataRepository
    @Dependencies.Dependency(\.geminiRepository) var geminiRepository
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog{
        let memo = Memo(text: content)
        print("入力されたメモ：\(content)")
        
        if let result = await geminiRepository.gemini(for: content) {
            memo.category = result.category
            memo.priorityValue = result.importance
            try await swiftDataRepository.addMemo(newMemo: memo)
            
        }
        
        return .result( dialog: IntentDialog("メモを追加しました！"))
    }
}
