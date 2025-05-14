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
    
    func fetchMemos() async throws -> [MemoSendable] {
        try context.fetch(FetchDescriptor<Memo>())
            .map { memo in
                MemoSendable(
                    text: memo.text,
                    category: memo.category,
                    priorityValue: memo.priorityValue,
                    isArchived: memo.isArchived,
                    createdAt: memo.createdAt,
                    date: memo.date
                )
            }
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
            if !memo.isArchived {
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
    
    func fetchMemos() async throws -> [MemoSendable] {
        return [
         
        ]
    }
    
    func addMemo(newMemo: Memo) async throws {
        print("📝 プレビュー: メモ追加 \(newMemo.text)")
    }
    
}

final class MemoSendable: Sendable {
    let id:UUID
    let text: String
    let date: Date?
    let category: String
    let isArchived: Bool
    let createdAt: Date
    let priorityValue: Double
    var priority: MemoPriority {
        MemoPriority.fromValue(priorityValue)
    }
    
    init(text: String, category: String, priorityValue: Double, isArchived: Bool, createdAt: Date, date: Date?) {
        self.id = UUID()
        self.text = text
        self.category = category
        self.isArchived = isArchived
        self.createdAt = createdAt
        self.priorityValue = priorityValue
        self.date = date
    }
}
    
