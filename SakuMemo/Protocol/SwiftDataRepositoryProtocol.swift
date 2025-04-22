//
//  SwiftDataRepositoryProtocol.swift
//  SakuMemo
//
//  Created by saki on 2025/04/22.
//

import Foundation
import SwiftData

protocol SwiftDataRepositoryProtocol: Sendable {
    func fetchCards() async throws -> [Card]
    func addCard(newCard: Card) async throws
    func updateCard(card: Card) async throws
}
