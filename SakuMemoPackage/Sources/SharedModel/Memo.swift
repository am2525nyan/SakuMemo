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
    public var isArchived: Bool
    public var createdAt: Date
    public var priorityValue: Double
    public var currentPriorityValue: Double {
        if isArchived {
            return priorityValue
        }
        let daysPassed = Calendar.current.dateComponents([.day], from: createdAt, to: Date()).day ?? 0
        let decay = Double(daysPassed) * 0.05
        let newPriority = priorityValue - decay
        return max(0, newPriority)
    }

    public var priority: MemoPriority {
        MemoPriority.fromValue(currentPriorityValue)
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

    public static func makeSampleMemos() -> [Memo] {
        [
            Memo(
                text: "牛乳を買う",
                category: MemoCategory.shopping.rawValue,
                priorityValue: 0.8,
                isArchived: false,
                createdAt: Date()
            ),
            Memo(
                text: "寝たい",
                category: MemoCategory.note.rawValue,
                priorityValue: 0.5,
                isArchived: false,
                createdAt: Date(),
                date: Date().addingTimeInterval(3600 * 24 * 2)
            ),
            Memo(
                text: "シュークリームを作る",
                category: MemoCategory.todo.rawValue,
                priorityValue: 0.9,
                isArchived: false,
                createdAt: Date()
            ),
            Memo(
                text: "部屋の掃除したい",
                category: MemoCategory.note.rawValue,
                priorityValue: 0.3,
                isArchived: false,
                createdAt: Date()
            ),
            Memo(
                text: "airpodsケース",
                category: MemoCategory.unknown.rawValue,
                priorityValue: 0.2,
                isArchived: true,
                createdAt: Date()
            )
        ]
    }

    // MARK: - Due Date Helper Methods

    public var isDueSoon: Bool {
        guard let daysUntilDue = self.daysUntilDue else {
            return false
        }
        return daysUntilDue <= 3 && daysUntilDue >= 0 // 3日以内で期限未過ぎ
    }

    public var isOverdue: Bool {
        guard let date = date else {
            return false
        }
        return date < Date()
    }

    public var daysUntilDue: Int? {
        guard let date = date else {
            return nil
        }
        return Calendar.current.dateComponents([.day], from: Date(), to: date).day
    }
}

public extension MemoPriority {
    var emoji: String {
        switch self {
        case .hot:
            return "🔥"

        case .warm:
            return "🌤"

        case .cold:
            return "🧊"
        }
    }

    func opacity(for priority: MemoPriority) -> Double {
        switch priority {
        case .hot:
            return 1.0

        case .warm:
            return 0.7

        case .cold:
            return 0.4
        }
    }

    static func fromValue(_ value: Double) -> MemoPriority {
        switch value {
        case ...0.3:
            return .cold

        case 0.3...0.7:
            return .warm

        default:
            return .hot
        }
    }
}
