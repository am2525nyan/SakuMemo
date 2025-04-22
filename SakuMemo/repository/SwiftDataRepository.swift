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
    
    func fetchCards() async throws -> [Memo] {
        try context.fetch(FetchDescriptor<Memo>())
    }
    
    func addCard(newCard: Memo) async throws {
        context.insert(newCard)
        try context.save()
    }
    
}

struct SwiftDataRepositoryKey: DependencyKey {
    @MainActor
    static var liveValue: SwiftDataRepositoryProtocol = {
        let container = try! ModelContainer(for: Memo.self)
        return SwiftDataRepository(container: container)
    }()
}

extension DependencyValues {
    var swiftDataRepository: SwiftDataRepositoryProtocol {
        get { self[SwiftDataRepositoryKey.self] }
        set { self[SwiftDataRepositoryKey.self] = newValue }
    }
}
