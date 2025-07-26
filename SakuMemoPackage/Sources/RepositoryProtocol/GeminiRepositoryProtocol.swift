//
//  GeminiRepositoryProtocol.swift
//  SakuMemo
//
//  Created by saki on 2025/04/23.
//

import Foundation
import SharedModel

public struct NotificationMessage: Codable {
    public let title: String
    public let body: String

    public init(title: String, body: String) {
        self.title = title
        self.body = body
    }
}

public protocol GeminiRepositoryProtocol: Sendable {
    func gemini(for content: String) async -> MemoAnalysisResult?
    func geminiText(for content: String) async -> [String]?
    func generateNotificationMessage(memoText: String, stage: String) async -> NotificationMessage?
}
