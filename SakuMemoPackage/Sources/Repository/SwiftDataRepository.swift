//
//  SwiftDataRepository.swift
//  SakuMemo
//
//  Created by saki on 2025/04/22.
//

import Foundation
import ComposableArchitecture
import SwiftData
import RepositoryProtocol
import SharedModel


@DependencyClient

public struct SwiftDataRepository: SwiftDataRepositoryProtocol {
    
    private let container: ModelContainer
    
    // コンストラクタで `ModelContainer` を渡す
    public init(container: ModelContainer) {
        self.container = container
    }
    
    @MainActor var context: ModelContext {
        container.mainContext
    }
    
    
    
    public func fetchMemos() async throws -> [MemoSendable] {
        return try await MainActor.run {
            let context = container.mainContext
            return try context.fetch(FetchDescriptor<Memo>())
                .map { memo in
                    MemoSendable(
                        id: memo.id, text: memo.text,
                        category: memo.category,
                        priorityValue: memo.priorityValue,
                        isArchived: memo.isArchived,
                        createdAt: memo.createdAt,
                        date: memo.date
                    )
                }
        }
    }
    
    
    public func addMemo(newMemo: MemoSendable) async throws {
        try await MainActor.run {
            let memo = Memo(
                text: newMemo.text,
                category: newMemo.category,
                priorityValue: newMemo.priorityValue,
                isArchived: newMemo.isArchived,
                createdAt: newMemo.createdAt,
                date: newMemo.date
            )
            let context = container.mainContext
            context.insert(memo)
            try context.save()
        }
    }
    
    
    public func deleteAllMemos() async throws {
        await MainActor.run {
            do {
                let fetchDescriptor = FetchDescriptor<Memo>()
                let context = container.mainContext
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
    }
    
    public func deleteMemo(memo: MemoSendable) async throws {
        try await MainActor.run {
            let context = container.mainContext
            
            // 外部値としてキャプチャ
            let targetId = memo.id
            
            // その値を使って Predicate を定義
            let descriptor = FetchDescriptor<Memo>(
                predicate: #Predicate { $0.id == targetId }
            )
            
            let results = try context.fetch(descriptor)
            
            for target in results {
                context.delete(target)
            }
            
            try context.save()
        }
    }
    
    
    public func archiveMemos() async throws {
        try await MainActor.run {
            let context = container.mainContext
            let now = Date()
            let memos = try context.fetch(FetchDescriptor<Memo>())
            
            for memo in memos {
                if !memo.isArchived {
                    let createdAt = memo.createdAt
                    let date = memo.date
                    let daysSinceCreation = Calendar.current.dateComponents([.day], from: createdAt, to: now).day ?? 0
                    
                    if daysSinceCreation >= 7 {
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
    
    public func automaticPriorityValues() async throws{
        try await MainActor.run {
            let context = container.mainContext
            let now = Date()
            let memos = try context.fetch(FetchDescriptor<Memo>())
            
            for memo in memos {
                let createdAt = memo.createdAt
                let dateSinceCreation = Calendar.current.dateComponents([.day], from: createdAt, to: now).day ?? 0
                
                if dateSinceCreation >= 3 {
                    memo.priorityValue = memo.priorityValue - 0.4
                    
                }
                
            }
            try context.save()
        }
    }
    
}


final class SwiftDataRepositoryMock: SwiftDataRepositoryProtocol {
    func automaticPriorityValues() async throws {
        print("優先度変更")
    }
    
    
    public func archiveMemos() async throws {
        print("アーカイブ")
    }
    
    public func deleteMemo(memo: MemoSendable) async throws{
        print("削除")
    }
    
    
    public func deleteAllMemos() async throws {
        print("全件削除完了！")
    }
    
    public func fetchMemos() async throws -> [MemoSendable] {
        return [
            
        ]
    }
    
    public func addMemo(newMemo: MemoSendable) async throws {
        print("📝 プレビュー: メモ追加 \(newMemo.text)")
    }
    
}



func createModelContainer() -> ModelContainer {
    do {
        let schema = Schema([
            Memo.self,
            UserSubscription.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        
        // 永続化履歴の問題を解決するためにリセット
        Task { @MainActor in
            do {
                let context = container.mainContext
                try context.save()
            } catch {
                print("初期化エラー: \(error)")
            }
        }
        
        return container
    } catch {
        fatalError("ModelContainerの生成に失敗しました: \(error)")
    }
}
let liveModelContainer: ModelContainer = {
    return createModelContainer()
}()

let testModelContainer: ModelContainer = {
    return createModelContainer()
}()

public enum SwiftDataRepositoryKey: DependencyKey {
    public static let liveValue: SwiftDataRepositoryProtocol = {
        let container = createModelContainer()
        return SwiftDataRepository(container: container)
    }()
    
    public static let previewValue: SwiftDataRepositoryProtocol = {
        let container = createModelContainer()
        return SwiftDataRepository(container: container)
    }()
    
    public static let testValue: SwiftDataRepositoryProtocol = {
        let container = createModelContainer()
        return SwiftDataRepository(container: container)
    }()
}

public extension DependencyValues {
    var swiftDataRepository: SwiftDataRepositoryProtocol {
        get { self[SwiftDataRepositoryKey.self] }
        set { self[SwiftDataRepositoryKey.self] = newValue }
    }
    
    var database: SwiftDataRepository {
        get { self[SwiftDataRepositoryKey.self] as! SwiftDataRepository }
        set { self[SwiftDataRepositoryKey.self] = newValue }
    }
}
