//
//  MemoDetailFeature.swift
//  SakuMemo
//
//  Created by saki on 2025/04/30.
//

import Combine
import ComposableArchitecture
import Foundation
import Repository
import SharedModel

@Reducer
public struct MemoDetailFeature: Sendable {
    public init() {}
    @ObservableState
    public struct State {
        public init(memo: Memo, priorityValue: Double = 0.0) {
            self.memo = memo
            self.priorityValue = priorityValue
        }

        public var memo: Memo
        public var priorityValue = 0.0
        public var pendingDateUpdate: Date?
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case setNotification
        case removeNotification
        case debouncedDateChanged(Date?)
        case executeDebouncedNotificationUpdate
    }

    @Dependency(\.notificationManager) var notificationManager
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.priorityValue = state.memo.priorityValue
                return .none

            case let .binding(action):
                switch action {
                case \.memo.date:
                    // 日付が変更された時はデバウンス処理を開始
                    let newDate = state.memo.date
                    state.pendingDateUpdate = newDate
                    return .run { send in
                        // 1.5秒間待機してから実行
                        try await Task.sleep(for: .seconds(1.5))
                        await send(.executeDebouncedNotificationUpdate)
                    }
                    .cancellable(id: "dateUpdateDebounce")

                default:
                    return .none
                }

            case let .debouncedDateChanged(date):
                state.pendingDateUpdate = date
                return .run { send in
                    // 1.5秒間待機してから実行
                    try await Task.sleep(for: .seconds(1.5))
                    await send(.executeDebouncedNotificationUpdate)
                }
                .cancellable(id: "dateUpdateDebounce")

            case .executeDebouncedNotificationUpdate:
                // 最新の日付変更が反映されているかチェック
                let currentDate = state.memo.date
                if state.pendingDateUpdate == currentDate {
                    // 既存通知を削除
                    let id = state.memo.id.uuidString
                    notificationManager.removeReminderNotifications(for: id)

                    // 新しい日付で通知設定
                    if let date = currentDate {
                        print("3段階リマインド通知を設定しました！")
                        let text = state.memo.text
                        return .run { _ in
                            try await notificationManager.scheduleReminderNotifications(for: text, targetDate: date, memoId: id)
                        }
                    }
                }
                return .none

            case .setNotification:
                let date = state.memo.date
                if let date = date {
                    print("3段階リマインド通知を設定しました！")
                    let text = state.memo.text
                    let id = state.memo.id.uuidString
                    return .run { _ in
                        try await notificationManager.scheduleReminderNotifications(for: text, targetDate: date, memoId: id)
                    }
                }
                return .none

            case .removeNotification:
                let id = state.memo.id.uuidString
                notificationManager.removeReminderNotifications(for: id)
                return .none
            }
        }
    }
}
