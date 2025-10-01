//
//  MemoView.swift
//  SakuMemo
//
//  Created by saki on 2025/04/18.
//

import AddMemoFeature
import Components
import ComposableArchitecture
import GoogleMobileAds
import MemoDetailFeature
import PopupView
import SharedModel
import SubscriptionFeature
import SwiftData
import SwiftUI
import Utils

public struct MemoView: View {
    public init(store: StoreOf<MemoFeature>) {
        self.store = store
    }

    @Bindable var store: StoreOf<MemoFeature>
    @FocusState var isFocused: Bool
    @Environment(\.scenePhase) var scenePhase
    @Query(filter: #Predicate<Memo> { $0.isArchived == false }, sort: \Memo.createdAt, order: .reverse) var memos: [Memo]
    @Query(filter: #Predicate<Memo> { $0.isArchived == true }, sort: \Memo.createdAt, order: .reverse) var archiveMemos: [Memo]
    @Query(filter: #Predicate<Memo> { $0.isArchived == false && $0.date != nil }, sort: \Memo.date) var memosWithDate: [Memo]

    var dueSoonMemos: [Memo] {
        memosWithDate.filter { memo in
            guard let date = memo.date else {
                return false
            }
            let now = Date()
            let calendar = Calendar.current
            let daysUntilDue = calendar.dateComponents([.day], from: now, to: date).day ?? 0
            return daysUntilDue <= 3 && daysUntilDue >= 0
        }
    }

    public var body: some View {
        NavigationView {
            ZStack {
                mainContentView
                FloatingButton(showAddMemo: {
                    store.send(.showAddMemo)
                })
                .padding(.bottom, 60)
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
                        proButton
                    }
                }
        }
    }

    private var mainContentView: some View {
        VStack {
            addMemoComponent
            memoCountCards
            memoScrollView
            bannerAdView
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
    }

    private var addMemoComponent: some View {
        AddMemoComponent(
            tapped: {
                store.send(.addMemo)
            },
            text: $store.text,
            isFocused: _isFocused
        )
    }

    private var memoCountCards: some View {
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
    }

    private var memoScrollView: some View {
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
            leadingText: "アーカイブ",
            dueSoonMemos: dueSoonMemos,
            showDetailMemo: { memo in
                store.send(.showDetail(memo))
            }
        )
    }

    private var bannerAdView: some View {
        let adSize = currentOrientationAnchoredAdaptiveBanner(width: 375)
        return BannerViewContainer(adSize)
            .frame(width: adSize.size.width, height: adSize.size.height)
    }

    private var proButton: some View {
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
                        Image(systemName: "plus")
                            .font(.system(size: 20))
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

    struct ScrollOffsetPreferenceKey: PreferenceKey {
        static let defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = nextValue()
        }
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
