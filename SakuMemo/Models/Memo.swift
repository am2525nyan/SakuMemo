//
//  Memo.swift
//  SakuMemo
//
//  Created by saki on 2025/04/18.
//

import Foundation
import SwiftData

enum MemoCategory: String, Codable, CaseIterable {
    case todo = "ToDo"
    case shopping = "買い物"
    case note = "メモ"
    case unknown = "未分類"
}
enum MemoPriority: String, Codable, CaseIterable {
    case hot = "🔥"
    case cold = "❄️"
    case warm = "🌤"
    
}

@Model
class Memo: Identifiable {
    @Attribute(.unique) var id = UUID()
    var text: String
    var date: Date
    var category: MemoCategory
    var priority: MemoPriority
    var isArchived: Bool
    
    init(text: String, category: MemoCategory = .unknown, priority: MemoPriority = .warm) {
        self.id = UUID()
        self.text = text
        self.date = Date()
        self.category = category
        self.priority = priority
        self.isArchived = false
    }
}

extension MemoPriority {
    var emoji: String {
        switch self {
        case .hot: return "🔥"
        case .warm: return "🌤"
        case .cold: return "🧊"
        }
    }
    func opacity(for priority: MemoPriority) -> Double {
        switch priority {
        case .hot: return 1.0
        case .warm: return 0.7
        case .cold: return 0.4
        }
    }
}
