//
//  GeminiRepositoryProtocol.swift
//  SakuMemo
//
//  Created by saki on 2025/04/23.
//

import Foundation
import SharedModel

public protocol GeminiRepositoryProtocol: Sendable {
    func gemini(for content: String) async -> MemoAnalysisResult?
    func geminiText(for content: String) async -> [String]?
}
