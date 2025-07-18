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
import SharedModel
import Repository
import RepositoryProtocol
import SwiftData


struct Shortcut: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddMemoIntent(),
            phrases: [
                "\(.applicationName)の画面を開いて",
                "\(.applicationName)の画面を見せて",
                "\(.applicationName)をお願い",
                "\(.applicationName)でメモを追加",
              
//                "サクメモでメモを追加",
//                "サクッとメモする",
//                "メモを追加したい",
//                "タスクを追加",
              
            ],
            shortTitle: "メモを追加する",
            systemImageName: "pencil")
    }
}



struct AddMemoIntent: AppIntent {
    
    static let title: LocalizedStringResource = "メモを追加"
    
    static let openAppWhenRun: Bool = true
    
    @Parameter(title: "メモの内容")
    var content: String
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog{
        print("入力されたメモ：\(content)")
        
        // 簡単なバージョン - とりあえずメモを作成
        let memo = Memo(text: content)
        let memoSendable = MemoSendable(
            id: memo.id,
            text: memo.text,
            category: memo.category,
            priorityValue: memo.priorityValue,
            isArchived: memo.isArchived,
            createdAt: memo.createdAt,
            date: memo.date
        )
        
        
        if let result = await geminiRepository.gemini(for: content) {
            memoSendable.category = result.category
            memoSendable.priorityValue = result.importance
            try await swiftDataRepository.addMemo(newMemo: memoSendable)

        }
        
   
        
        return .result( dialog: IntentDialog("メモを追加しました！"))
    }
}
