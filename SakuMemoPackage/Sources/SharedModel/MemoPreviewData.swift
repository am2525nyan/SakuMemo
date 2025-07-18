//
//  MemoPreviewData.swift
//  SakuMemo
//
//  Created by saki on 2025/05/21.
//

import SwiftData
import SwiftUI

public struct MemoPreviewData: PreviewModifier {
    public init() {}
    public static func makeSharedContext() async throws -> ModelContainer {
        let container = try ModelContainer(for: Memo.self)

        // データがすでにあるか確認
        let existing = try container.mainContext.fetch(FetchDescriptor<Memo>())
        if existing.isEmpty {
            let sampleMemos = Memo.makeSampleMemos()
            for memo in sampleMemos {
                container.mainContext.insert(memo)
            }
        }

        return container
    }

    public func body(content: Content, context: ModelContainer) -> some View {
        content.modelContainer(context)
    }
}

public extension PreviewTrait where T == Preview.ViewTraits {
    @MainActor static var sampleMemos: Self = .modifier(MemoPreviewData())
}
