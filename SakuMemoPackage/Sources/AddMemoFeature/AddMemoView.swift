//
//  AddMemoView.swift
//  SakuMemo
//
//  Created by saki on 2025/05/03.
//

import ComposableArchitecture
import SharedModel
import SwiftUI
import Utils

public struct AddMemoView: View {
    public init(store: StoreOf<AddMemoFeature>) {
        self.store = store
    }

    @Bindable var store: StoreOf<AddMemoFeature>
    @FocusState private var isFocused: Bool
    public var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    store.send(.showTextField)
                } label: {
                    Image(systemName: "text.justifyright")
                }
                .padding(.leading, 20)
                .disabled(store.memoList.isEmpty)

                Button {
                    store.send(.save)
                } label: {
                    Image(systemName: "paperplane.fill")
                }
                .disabled(store.text.isEmpty && !store.isSending || !store.isTextField)
                .padding(.leading, 20)
            }
            .padding(.bottom, 20)
            if store.isTextField {
                TextField("メモを入力", text: $store.text, axis: .vertical)
                    .textFieldStyle(.customTextField(isFocused: _isFocused))
                    .lineLimit(5...300)
                    .focused($isFocused)
                    .padding(.top, 20)
                    .frame(minHeight: 100)
                    .fixedSize(horizontal: false, vertical: true)
                    .keyboardType(.default)
                    .submitLabel(.done)
            }

            if !store.isTextField || !store.memoList.isEmpty {
                List {
                    ForEach(store.memoList, id: \.self) { memo in
                        HStack {
                            Text(memo)
                            Spacer()
                            Button {
                                store.send(.addMemo(memo))
                            } label: {
                                Image(systemName: "plus")
                                    .foregroundStyle(Color.mainColor)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .swipeActions(
                            content: {
                                Button(role: .destructive) {
                                    store.send(.addMemo(memo))
                                } label: {
                                    Image(systemName: "plus")
                                        .foregroundStyle(Color.mainColor)
                                }
                                .tint(Color.mainColor)
                            }
                        )
                        .padding(.horizontal, 20)
                    }
                }
                .listStyle(.plain)
            }
        }
        .padding(.top, 20)
        .padding(.horizontal, 20)
        .dismissKeyboardOnTap()
        .onAppear {
            store.send(.checkSubscriptionStatus)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            // キーボード用の動的スペース
            Color.clear
                .frame(height: 0)
        }
        .alert("使用制限に達しました", isPresented: $store.showLimitAlert) {
            Button("OK") {
                store.send(.dismissLimitAlert)
            }
        } message: {
            Text("無料ユーザーは1日3回までメモを作成できます。\n無制限に使用するには課金してください。")
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if !store.isSubscribed {
                    Text("残り: \(store.remainingFreeMemos)回")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

#Preview {
    AddMemoView(store: .init(initialState: AddMemoFeature.State(
        //        memoList: [
        //            "シュー生地を作る",
        //            "カスタードクリームを作る",
        //            "生クリームを泡立てる",
        //            "シュー生地を焼く",
        //            "カスタードクリームを冷ます",
        //            "シュー生地にクリームを詰める",
        //            "粉砂糖をかける",
        //            "冷蔵庫で冷やす"
        //        ]
    ), reducer: {
        AddMemoFeature()
    }))
}
