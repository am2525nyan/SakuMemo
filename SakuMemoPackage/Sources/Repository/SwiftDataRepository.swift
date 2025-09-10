//
//  SwiftDataRepository.swift
//  SakuMemo
//
//  Created by saki on 2025/04/22.
//

import ComposableArchitecture
import Foundation
import RepositoryProtocol
import SharedModel
import SwiftData

@DependencyClient

public struct SwiftDataRepository: SwiftDataRepositoryProtocol {
    private let container: ModelContainer

    // コンストラクタで `ModelContainer` を渡す
    public init(container: ModelContainer) {
        self.container = container
    }

    @MainActor public var context: ModelContext {
        container.mainContext
    }

    public func fetchMemos() async throws -> [MemoSendable] {
        try await MainActor.run {
            let context = container.mainContext
            return try context.fetch(FetchDescriptor<Memo>())
                .map { memo in
                    MemoSendable(
                        id: memo.id,
                        text: memo.text,
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

    public func automaticPriorityValues() async throws {
    try await MainActor.run {
        let context = container.mainContext
        let now = Date()
        let memos = try context.fetch(FetchDescriptor<Memo>())

        for memo in memos where !memo.isArchived {
            let createdAt = memo.createdAt
            let dateSinceCreation = Calendar.current.dateComponents([.day], from: createdAt, to: now).day ?? 0
            let sinceDays = 3
            if dateSinceCreation >= sinceDays {
                let decreasePriorityValue = 0.2
                memo.priorityValue -= decreasePriorityValue

                // 重要度が0以下かつ作成から7日以上経過したら自動アーカイブ
                let archiveThresholdDays = 7
                if memo.priorityValue <= 0, dateSinceCreation >= archiveThresholdDays {
                    memo.isArchived = true
                }
            }
        }
        try context.save()
    }
}
}

final class SwiftDataRepositoryMock: SwiftDataRepositoryProtocol {
    @MainActor var context: ModelContext {
        fatalError("Mock context not implemented")
    }

    func automaticPriorityValues() async throws {
        print("優先度変更")
    }

    func archiveMemos() async throws {
        print("アーカイブ")
    }

    func deleteMemo(memo: MemoSendable) async throws {
        print("削除")
    }

    func deleteAllMemos() async throws {
        print("全件削除完了！")
    }

    func fetchMemos() async throws -> [MemoSendable] {
        [
        ]
    }

    func addMemo(newMemo: MemoSendable) async throws {
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

let liveModelContainer: ModelContainer = createModelContainer()

let testModelContainer: ModelContainer = createModelContainer()

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

    var database: SwiftDataRepositoryProtocol {
        get { self[SwiftDataRepositoryKey.self] }
        set { self[SwiftDataRepositoryKey.self] = newValue }
    }
}
