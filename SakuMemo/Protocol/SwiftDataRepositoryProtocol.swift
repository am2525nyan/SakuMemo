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
    func addMemo(newMemo: Memo) async throws
    func deleteAllMemos() async throws
    func deleteMemo(memo: Memo) async throws
    
}
