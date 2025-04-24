//
//  GeminiRepositoryProtocol.swift
//  SakuMemo
//
//  Created by saki on 2025/04/23.
//

import Foundation
protocol GeminiRepositoryProtocol: Sendable {
    func gemini(for content: String)async -> String
}
