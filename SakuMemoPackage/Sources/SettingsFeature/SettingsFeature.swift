//
//  SettingsFeature.swift
//  SakuMemo
//
//  Created by Claude on 2025/09/10.
//

import ComposableArchitecture
import Foundation

@Reducer
public struct SettingsFeature {
    public init() {}

    @ObservableState
    public struct State {
        public init() {
            self.autoArchiveDays = UserDefaults.standard.object(forKey: "autoArchiveDays") as? Int ?? 7
            self.priorityDecreaseValue = UserDefaults.standard.object(forKey: "priorityDecreaseValue") as? Double ?? 0.2
            self.priorityDecreaseStartDays = UserDefaults.standard.object(forKey: "priorityDecreaseStartDays") as? Int ?? 3
        }

        var autoArchiveDays: Int
        var priorityDecreaseValue: Double
        var priorityDecreaseStartDays: Int
    }

    public enum Action {
        case autoArchiveDaysChanged(Int)
        case priorityDecreaseValueChanged(Double)
        case priorityDecreaseStartDaysChanged(Int)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .autoArchiveDaysChanged(days):
                state.autoArchiveDays = days
                UserDefaults.standard.set(days, forKey: "autoArchiveDays")
                return .none

            case let .priorityDecreaseValueChanged(value):
                state.priorityDecreaseValue = value
                UserDefaults.standard.set(value, forKey: "priorityDecreaseValue")
                return .none

            case let .priorityDecreaseStartDaysChanged(days):
                state.priorityDecreaseStartDays = days
                UserDefaults.standard.set(days, forKey: "priorityDecreaseStartDays")
                return .none
            }
        }
    }
}
