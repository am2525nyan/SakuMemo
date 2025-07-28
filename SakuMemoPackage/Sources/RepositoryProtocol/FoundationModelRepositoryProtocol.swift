//
//  FoundationModelRepositoryProtocol.swift
//  SakuMemo
//
//  Created by saki on 2025/07/28.
//

import Foundation
import SharedModel

@available(iOS 26.0, macOS 26.0, *)
public protocol FoundationModelRepositoryProtocol: Sendable {
    func respond(userInput: String) async throws -> MemoAnalysisResult
    func extractTasks(for content: String) async throws -> [String]
}
