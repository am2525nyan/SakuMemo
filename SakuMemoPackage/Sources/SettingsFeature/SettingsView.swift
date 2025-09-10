//
//  SettingsView.swift
//  SakuMemo
//
//  Created by Claude on 2025/09/10.
//

import ComposableArchitecture
import SwiftUI

import TipKit

public struct SettingsView: View {
    public init(store: StoreOf<SettingsFeature>) {
        self.store = store
    }

    @Bindable var store: StoreOf<SettingsFeature>
    @State private var showArchiveHelp = false
    @State private var showPriorityHelp = false

    public var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack(spacing: 16) {
                        Image(systemName: "archivebox")
                            .foregroundColor(.blue)
                            .frame(width: 24)

                        Text("自動アーカイブ")
                            .font(.headline)

                        // ヘルプボタン
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showArchiveHelp.toggle()
                            }
                        } label: {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(.secondary)
                                .font(.system(size: 18))
                        }
                        .buttonStyle(.plain)

                        Spacer()

                        Stepper(value: $store.autoArchiveDays.sending(\.autoArchiveDaysChanged), in: 1...30) {
                            Text("\(store.autoArchiveDays)日")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 4)

                    if showArchiveHelp {
                        Text("重要度が0以下になったメモは、設定した日数が経過すると自動的にアーカイブされます。")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .padding(.top, 4)
                            .transition(.opacity.combined(with: .slide))
                    }
                } header: {
                    Label("アーカイブ設定", systemImage: "archivebox.fill")
                }

                Section {
                    HStack(spacing: 16) {
                        Image(systemName: "calendar")
                            .foregroundColor(.orange)
                            .frame(width: 24)

                        Text("重要度減少開始")
                            .font(.headline)

                        // ヘルプボタン
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showPriorityHelp.toggle()
                            }
                        } label: {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(.secondary)
                                .font(.system(size: 18))
                        }
                        .buttonStyle(.plain)

                        Spacer()

                        Stepper(value: $store.priorityDecreaseStartDays.sending(\.priorityDecreaseStartDaysChanged), in: 1...10) {
                            Text("\(store.priorityDecreaseStartDays)日")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.orange)
                        }
                    }
                    .padding(.vertical, 4)

                    if showPriorityHelp {
                        Text("メモ作成から指定した日数が経過すると、1日ごとに重要度が0.2ずつ自動的に減少します。")
                            .font(.caption)
                            .foregroundColor(.orange)
                            .padding(.top, 4)
                            .transition(.opacity.combined(with: .slide))
                    }
                } header: {
                    Label("重要度設定", systemImage: "star.fill")
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("メモの自動管理について")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("メモは時間が経過すると自動で重要度が下がり、最終的にアーカイブされます。設定でタイミングを調整できます。")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    SettingsView(
        store: Store(
            initialState: SettingsFeature.State(),
            reducer: {
                SettingsFeature()
            }
        )
    )
}
