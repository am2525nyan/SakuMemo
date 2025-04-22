//
//  SwiftDataRepositoryProtocol.swift
//  SakuMemo
//
//  Created by saki on 2025/04/22.
//

import Foundation
import SwiftData

protocol SwiftDataRepositoryProtocol: Sendable {
    func fetchMemos() async throws -> [Memo]
    func addMemo(newCard: Memo) async throws
 
}
