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
    func fetchMemos() async throws -> [Memo] {
        return [
            Memo(text: "バナナ", category: .shopping,priority: .hot),
            Memo(text: "Reducer書く", category: .todo, priority: .warm),
            Memo(text: "旅行準備したい", category: .note, priority: .cold),
            Memo(text: "りんご", category: .shopping,priority: .hot),
            Memo(text: "インターンのDM返す！", category: .todo, priority: .hot),
            Memo(text: "visionPro欲しい", category: .note, priority: .cold),
            ]
    }

    func addMemo(newMemo: Memo) async throws {
        print("📝 プレビュー: メモ追加 \(newMemo.text)")
    }
}
