//
//  SwiftDataRepository.swift
//  SakuMemo
//
//  Created by saki on 2025/04/22.
//

import Foundation
import ComposableArchitecture
import SwiftData


@MainActor
final class SwiftDataRepository: SwiftDataRepositoryProtocol {
    
    private let container: ModelContainer
    
    // コンストラクタで `ModelContainer` を渡す
    init(container: ModelContainer) {
        self.container = container
    }
    
    private var context: ModelContext {
        return container.mainContext
    }
    
    func fetchMemos() async throws -> [Memo] {
        try context.fetch(FetchDescriptor<Memo>())
    }
    
    func addMemo(newMemo: Memo) async throws {
        context.insert(newMemo)
        try context.save()
    }
    
    func deleteAllMemos() async throws{
        do {
            let fetchDescriptor = FetchDescriptor<Memo>()
            let allMemos = try context.fetch(fetchDescriptor)
            
            for memo in allMemos {
                context.delete(memo)
            }
            
            try context.save()
            print("全件削除完了！")
            
        } catch {
            print("削除に失敗しました: \(error)")
        }
    }
    func deleteMemo(memo: Memo) async throws{
        context.delete(memo)
        try context.save()
        
    }
    func archiveMemos() async throws {
        let now = Date()
        let memos = try context.fetch(FetchDescriptor<Memo>())
        
        for memo in memos {
            if memo.isArchived != true{
                let createdAt = memo.createdAt
                let date = memo.date
                let daysSinceCreation = Calendar.current.dateComponents([.day], from: createdAt, to: now).day ?? 0    
                
                if daysSinceCreation >= 3 {
                    memo.isArchived = true
                }
                if let date {
                    let daysSinceDate = Calendar.current.dateComponents([.day], from: date, to: now).day ?? 0
                    if daysSinceDate >= 0 {
                        memo.isArchived = true
                    }
                }
                
            }
            
        }
        try context.save()
    }
    
}



struct SwiftDataRepositoryKey: DependencyKey {
    @MainActor
    static var liveValue: SwiftDataRepositoryProtocol = {
        let container = try! ModelContainer(for: Memo.self)
        return SwiftDataRepository(container: container)
    }()
    static var previewValue: SwiftDataRepositoryProtocol = SwiftDataRepositoryMock()
}

extension DependencyValues {
    var swiftDataRepository: SwiftDataRepositoryProtocol {
        get { self[SwiftDataRepositoryKey.self] }
        set { self[SwiftDataRepositoryKey.self] = newValue }
    }
}

final class SwiftDataRepositoryMock: SwiftDataRepositoryProtocol {
    func archiveMemos() async throws {
        print("アーカイブ")
    }
    
    func deleteMemo(memo: Memo) async throws  {
        print("削除")
    }
    
    
    func deleteAllMemos() async throws {
        print("全件削除完了！")
    }
    
    func fetchMemos() async throws -> [Memo] {
        return [
            Memo(text: "バナナ", category: "", priorityValue: 0.8),
            Memo(text: "Reducer書く", category: ".todo", priorityValue: 0.6),
            Memo(text: "旅行準備したい", category: ".note", priorityValue: 0.2),
            Memo(text: "りんご", category: ".shopping", priorityValue: 0.9),
            Memo(text: "インターンのDM返す！", category: ".todo", priorityValue: 0.9),
            Memo(text: "visionPro欲しい", category: ".note", priorityValue: 0.1),
        ]
    }
    
    func addMemo(newMemo: Memo) async throws {
        print("📝 プレビュー: メモ追加 \(newMemo.text)")
    }
    
}
