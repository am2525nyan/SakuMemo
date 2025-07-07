//
//  File.swift
//  SakuMemoPackage
//
//  Created by saki on 2025/05/16.
//

import Foundation
public final class MemoSendable: Sendable {
    public let id:UUID
    public let text: String
    public let date: Date?
    public let category: String
    public let isArchived: Bool
    public  let createdAt: Date
    public let priorityValue: Double
    public var priority: MemoPriority {
        MemoPriority.fromValue(priorityValue)
    }
    
    public init(id: UUID,text: String, category: String, priorityValue: Double, isArchived: Bool, createdAt: Date, date: Date?) {
        self.id = id
        self.text = text
        self.category = category
        self.isArchived = isArchived
        self.createdAt = createdAt
        self.priorityValue = priorityValue
        self.date = date
    }
}
    
public final class MemoAnalysisResult: Decodable {
    public let importance: Double
    public let category: String

    public init(importance: Double, category: String) {
        self.importance = importance
        self.category = category
    }
}
