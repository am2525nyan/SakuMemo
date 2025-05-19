//
//  Memo.swift
//  SakuMemo
//
//  Created by saki on 2025/04/18.
//

import Foundation
import SwiftData

public enum MemoCategory: String, Codable, CaseIterable {
    case todo = "ToDo"
    case shopping = "買い物"
    case note = "メモ"
    case unknown = "未分類"
}
public enum MemoPriority: String, Codable, CaseIterable {
    case hot = "🔥"
    case cold = "❄️"
    case warm = "🌤"
    
}

@Model
public final class Memo: Identifiable {
    @Attribute(.unique) public var id = UUID()
    public var text: String
    public var date: Date?
    public var category: String
    public  var isArchived: Bool
    public  var createdAt: Date
    public var priorityValue: Double
    public var priority: MemoPriority {
        MemoPriority.fromValue(priorityValue)
    }
    
    public init(
        text: String,
        category: String = "未分類",
        priorityValue: Double = 0.7,
        isArchived: Bool = false,
        createdAt: Date = .now,
        date: Date? = nil
    ) {
        self.id = UUID()
        self.text = text
        self.category = category
        self.isArchived = isArchived
        self.createdAt = createdAt
        self.priorityValue = priorityValue
        self.date = date
    }

}


public extension MemoPriority {
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
