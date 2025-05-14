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
final class Memo: Identifiable {
    @Attribute(.unique) var id = UUID()
    var text: String
    var date: Date?
    var category: String
    var isArchived: Bool
    var createdAt: Date
    var priorityValue: Double
    var priority: MemoPriority {
        MemoPriority.fromValue(priorityValue)
    }
    
    init(text: String, category: String = "未分類", priorityValue: Double = 0.7) {
        self.id = UUID()
        self.text = text
        self.category = category
        self.isArchived = false
        self.createdAt = .now
        self.priorityValue = priorityValue
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
    static func fromValue(_ value: Double) -> MemoPriority {
        switch value {
        case ...0.3: return .cold
        case 0.3...0.7: return .warm
        default: return .hot
        }
    }
    
}
