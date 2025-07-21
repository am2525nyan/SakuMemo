//
//  MemoView.swift
//  SakuMemo
//
//  Created by saki on 2025/04/18.
//

import AddMemoFeature
import Components
import ComposableArchitecture
import MemoDetailFeature
import PopupView
import SharedModel
import SubscriptionFeature
import SwiftData
import SwiftUI

public struct MemoView: View {
    public init(store: StoreOf<MemoFeature>) {
        self.store = store
    }

    @Bindable var store: StoreOf<MemoFeature>
    @FocusState var isFocused: Bool
    @Environment(\.scenePhase) var scenePhase
    @Query(filter: #Predicate<Memo> { $0.isArchived == false }, sort: \Memo.createdAt, order: .reverse) var memos: [Memo]
    @Query(filter: #Predicate<Memo> { $0.isArchived == true }, sort: \Memo.createdAt, order: .reverse) var archiveMemos: [Memo]

    public var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    AddMemoComponent(
                        tapped: {
                            store.send(.addMemo)
                        },
                        text: $store.text,
                        isFocused: _isFocused
                    )
                    HStack {
                        MemoCountCard(
                            label: "残りのメモ",
                            count: memos.count,
                            backgroundColor: Color.mainColor
                        )
                        .frame(width: 150, height: 100)
                        .padding(.trailing, 20)
                        MemoCountCard(
                            label: "アーカイブ数",
                            count: archiveMemos.count,
                            backgroundColor: Color.customPinkColor
                        )
                        .frame(width: 150, height: 100)
                    }
                    ListComponent(
                        memos: .constant(memos),
                        tapAction: { memo in
                            store.send(.showDetail(memo))
                        },
                        swipeTrailingAction: { memo in
                            store.send(.deleteMemo(memo))
                        },
                        swipeLeadingAction: { memo in
                            store.send(.archive(memo))
                        },
                        trailingText: "削除",
                        leadingText: "アーカイブ"
                    )
                }
                .onAppear {
                    store.send(.onAppear)
                }
                .sheet(item: $store.scope(state: \.detail, action: \.presentMemoDetail)) { detail in
                    MemoDetailView(store: detail)
                        .presentationDetents([.height(250)])
                        .presentationDragIndicator(.visible)
                        .presentationBackground(Material.thick)
                }
                .sheet(item: $store.scope(state: \.add, action: \.presentAddMemo)) { add in
                    AddMemoView(store: add)
                        .presentationDetents([.height(250)])
                        .presentationDragIndicator(.visible)
                        .presentationBackground(Material.thick)
                }
                .sheet(item: $store.scope(state: \.subscription, action: \.presentSubscription)) { subscription in
                    SubscriptionView(store: subscription)
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible)
                        .presentationBackground(Material.thick)
                }
                FloatingButton(showAddMemo: {
                    store.send(.showAddMemo)
                })
                .padding(.bottom, 20)
                .padding(.trailing, 20)
            }

            .popup(isPresented: $store.isShowPopup) {
                FloaterTop()
            }
            customize: {
                $0
                    .type(.floater())
                    .position(.top)
                    .animation(.spring())
                    .displayMode(.window)
                    .disappearTo(.topSlide)
            }
            .navigationTitle("SakuMemo")
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: {
                            store.send(.showSubscription)
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.yellow)
                                Text("Pro")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.orange)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.yellow.opacity(0.2))
                            )
                        }
                    }
                }
        }
    }

    struct FloatingButton: View {
        var showAddMemo: () -> Void
        var body: some View {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        showAddMemo()
                    }) {
                        Text("+")
                            .font(.system(size: 30))
                            .frame(width: 30, height: 30)
                            .padding()
                            .background(Color.mainColor)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                    .padding()
                }
            }
        }
    }
}

struct MemoCountCard: View {
    let label: String
    let count: Int
    let backgroundColor: Color
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(backgroundColor)

            VStack(alignment: .center) {
                Text(label)
                    .padding(.top, 10)
                    .foregroundColor(.white)
                Spacer()
                HStack {
                    Spacer()
                    Text(String(count))
                        .font(.system(size: 40))
                        .bold()
                        .foregroundColor(.white)
                        .padding(.bottom, 10)
                        .offset(x: -5)
                    Text("こ")
                        .foregroundColor(.white)
                }
                .padding(.trailing, 10)
            }
        }
        .frame(width: 150, height: 100)
        .padding(.trailing, 20)
    }
}

#Preview(traits: .sampleMemos) {
    MemoView(
        store:
        .init(
            initialState: MemoFeature.State(
            ),
            reducer: {
                MemoFeature()
            }
        )
    )
}
