//  FoundationModelRepository.swift
//  SakuMemoPackage
//
//  Created by saki on 2025/06/30.
//

import ComposableArchitecture
import Foundation
import FoundationModels
import RepositoryProtocol
import SharedModel

@available(iOS 26.0, macOS 26.0, *)
public struct FoundationModelRepository: FoundationModelRepositoryProtocol {
    public init() {}

    public func respond(userInput: String) async throws -> MemoAnalysisResult {
        let model = SystemLanguageModel.default
        switch model.availability {
        case .available:
            let prompt = """
            「\(userInput)」を重要度に応じて0.0~1.0まで数字分けします。下記例を参考に判断してください：

            【緊急・重要・すぐにやること（0.8-1.0）】
            課題やる = 1.0, 会議準備 = 0.9, りんご買う = 0.9, 薬を飲む = 0.8, ゴミを捨てる = 0.8, 掃除機をかける = 0.8

            【重要だが緊急でない（0.5-0.7）】  
            appleについて調べる = 0.7, 本を読む = 0.6,  運動する = 0.5

            【願望・希望（0.1-0.4）】
            メモアプリ作りたい = 0.2, appleについて調べたい = 0.3, ゴミを捨てたい = 0.4, 旅行したい = 0.2

            【低優先度（0.0-0.2）】
            寝たい = 0.1, テレビ見たい = 0.1, なんとなく散歩 = 0.1

            語尾の「たい」「したい」は願望なので低めに設定してください。
            """
            let session = LanguageModelSession(instructions: prompt)
            let response = try await session.respond(to: userInput, generating: MemoResponse.self)
            print("Response: \(response)")
            return MemoAnalysisResult(importance: response.content.importance, category: response.content.category)
        // Show your intelligence UI.

        case .unavailable(.deviceNotEligible):
            throw FoundationModelRepositoryError.deviceNotEligible

        case .unavailable(.appleIntelligenceNotEnabled):
            throw FoundationModelRepositoryError.appleIntelligenceNotEnabled

        case .unavailable(.modelNotReady):
            throw FoundationModelRepositoryError.modelNotReady

        case let .unavailable(other):
            throw FoundationModelRepositoryError.other("\(other)")
        }
    }

    public func extractTasks(for content: String) async throws -> [String] {
        let model = SystemLanguageModel.default
        switch model.availability {
        case .available:
            let prompt = """
            「\(content)」から、タスクを抽出してください。幾つになっても大丈夫です。
            例えば以下のような文章があった時にはこのように抽出してください：

            例：明日友達が家に来てご飯を作るから、部屋の掃除をしてから、買い物に行く
            → 部屋の掃除機をかける、キッチンをきれいにする、買い物リストを作る、買い物に行く

            のようにタスクを抽出してください。
            """
            let session = LanguageModelSession(instructions: prompt)
            let response = try await session.respond(to: content, generating: TaskExtractionResponse.self)
            print("TaskExtraction Response: \(response)")
            return response.content.tasks

        case .unavailable(.deviceNotEligible):
            throw FoundationModelRepositoryError.deviceNotEligible

        case .unavailable(.appleIntelligenceNotEnabled):
            throw FoundationModelRepositoryError.appleIntelligenceNotEnabled

        case .unavailable(.modelNotReady):
            throw FoundationModelRepositoryError.modelNotReady

        case let .unavailable(other):
            throw FoundationModelRepositoryError.other("\(other)")
        }
    }
}

@available(iOS 26.0, macOS 26.0, *)
@Generable(description: "タスク")
struct MemoResponse {
    @Guide(description: "タスクの重要度", .range(0.0...1.0))
    let importance: Double
    @Guide(.anyOf(["買い物", "todo", "やりたいこと"]))
    let category: String
}

@available(iOS 26.0, macOS 26.0, *)
@Generable
struct TaskExtractionResponse {
    @Guide(description: "抽出されたタスクのリスト")
    let tasks: [String]
}

@available(iOS 26.0, macOS 26.0, *)
public struct FoundationModelsRepositoryKey: DependencyKey {
    public static let liveValue: FoundationModelRepositoryProtocol = FoundationModelRepository()
}

@available(iOS 26.0, macOS 26.0, *)
public extension DependencyValues {
    var foundationModelsRepository: FoundationModelRepositoryProtocol {
        get { self[FoundationModelsRepositoryKey.self] }
        set { self[FoundationModelsRepositoryKey.self] = newValue }
    }
}

@available(iOS 26.0, macOS 26.0, *)
enum FoundationModelRepositoryError: Error, LocalizedError {
    case appleIntelligenceNotEnabled
    case deviceNotEligible
    case modelNotReady
    case other(String)

    var errorDescription: String? {
        switch self {
        case .appleIntelligenceNotEnabled:
            return "Apple Intelligenceが有効化されていません。"

        case .deviceNotEligible:
            return "このデバイスでは利用できません。"

        case .modelNotReady:
            return "モデルの準備ができていません。"

        case let .other(str):
            return "不明な理由で利用できません: \(str)"
        }
    }
}
