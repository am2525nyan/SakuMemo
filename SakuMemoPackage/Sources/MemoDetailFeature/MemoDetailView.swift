//
//  MemoDetailView.swift
//  SakuMemo
//
//  Created by saki on 2025/04/30.
//

import ComposableArchitecture
import SharedModel
import SwiftUI
import Utils

@ViewAction(for: MemoDetailFeature.self)
public struct MemoDetailView: View {
    public init(store: StoreOf<MemoDetailFeature>) {
        self.store = store
    }

    @Bindable public var store: StoreOf<MemoDetailFeature>
    @FocusState var isFocused: Bool
    public var body: some View {
        VStack {
            HStack {
                Text("内容：")
                TextField("メモ", text: $store.memo.text)
                    .textFieldStyle(.customTextField(isFocused: _isFocused))
                    .focused($isFocused)
            }
            HStack {
                Text("重要度：")
                Slider(
                    value: $store.memo.priorityValue,
                    in: 0...1,
                    step: 0.1
                )
            }
            HStack {
                Text("カテゴリー：")
                Menu {
                    Button("todo") {
                        store.memo.category = "todo"
                    }
                    Button("やりたいこと") {
                        store.memo.category = "やりたいこと"
                    }
                    Button("買い物") {
                        store.memo.category = "買い物"
                    }
                    Button("未分類") {
                        store.memo.category = "未分類"
                    }
                }
                label: {
                    Text(store.memo.category)
                }
                Spacer()
            }

            if store.memo.date != nil {
                HStack {
                    DatePicker(
                        "日付：",
                        selection: Binding<Date>(
                            get: { store.memo.date ?? Date() },
                            set: { store.memo.date = $0 }
                        ),
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    Button(
                        role: .destructive,
                        action: {
                            store.memo.date = nil
                        }, label: {
                            Text("×")
                                .font(.system(size: 25))
                        }
                    )
                }
            } else {
                Button(action: {
                    store.memo.date = Date()
                }, label: {
                    Text("日付を追加")
                })
                .buttonStyle(.customButton)
            }
        }
        .padding(.horizontal, 20)
        .dismissKeyboardOnTap()
        .onAppear {
            send(.onAppear)
        }
    }
}

#Preview {
    MemoDetailView(store: .init(initialState: MemoDetailFeature.State(memo: Memo(text: "お掃除する")), reducer: {
        MemoDetailFeature()
    }))
}
