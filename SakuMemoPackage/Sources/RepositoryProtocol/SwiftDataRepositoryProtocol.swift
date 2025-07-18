//
//  SwiftDataRepositoryProtocol.swift
//  SakuMemo
//
//  Created by saki on 2025/04/22.
//

import Foundation
import SharedModel
import SwiftData

public protocol SwiftDataRepositoryProtocol:Sendable {
    func fetchMemos() async throws -> [MemoSendable]
    func addMemo(newMemo: MemoSendable) async throws
    func deleteAllMemos() async throws
    func deleteMemo(memo: MemoSendable) async throws
    func archiveMemos() async throws
    func automaticPriorityValues() async throws
    
}
