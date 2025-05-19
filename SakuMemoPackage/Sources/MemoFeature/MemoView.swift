//
//  TaskView.swift
//  SakuMemo
//
//  Created by saki on 2025/04/18.
//

import SwiftUI
import ComposableArchitecture
import SwiftData
import PopupView
import Components
import SharedModel
import MemoDetailFeature
import AddMemoFeature

public struct MemoView: View {
    public init(store: StoreOf<MemoFeature>) {
        self.store = store
    }
    @Bindable var store: StoreOf<MemoFeature>
    @FocusState var isFocused: Bool
    @Environment(\.scenePhase) var scenePhase
    @Query(filter: #Predicate<Memo>{$0.isArchived == false},sort: \Memo.createdAt, order: .reverse) var memos: [Memo]
    
    public var body: some View {
        ZStack{
            VStack {
                AddMemoComponent(
                    tapped: {
                        store.send(.addMemo)
                    },
                    text:$store.text, isFocused: _isFocused
                )
                ListComponent(memos: .constant(memos), tapAction: {memo in
                    store.send(.showDetail(memo))
                }, swipeTrailingAction: { memo in
                    store.send(.deleteMemo(memo))
                }, swipeLeadingAction: { memo in
                    store.send(.archive(memo))
                }, trailingText: "削除", leadingText: "アーカイブ")
                
            }
            
            .onAppear(){
                store.send(.onAppear)
                
            }
            .sheet(item: $store.scope(state: \.detail, action: \.presentMemoDetail)){detail in
                MemoDetailView(store: detail)
                    .presentationDetents([ .height(250)])
                    .presentationDragIndicator(.visible)
                    .presentationBackground(Material.thick)
                
                
            }
            .sheet(item: $store.scope(state: \.add, action: \.presentAddMemo)){add in
                AddMemoView(store: add)
                    .presentationDetents([.height(250)])
                    .presentationDragIndicator(.visible)
                    .presentationBackground(Material.thick)
                
                
            }
            FloatingButton(showAddMemo: {
                store.send(.showAddMemo)
            })
            .padding(.bottom, 20)
            .padding(.trailing,20)
        }
        .popup(isPresented: $store.isShowPopup) {
            FloaterTop()
        } customize: {
            $0
                .type(.floater())
                .position(.top)
                .animation(.spring())
                .displayMode(.window)
                .disappearTo(.topSlide)
        }
    }
    
 struct FloatingButton: View {
        var showAddMemo: ()->Void
      public  var body: some View {
            VStack{
                Spacer()
                HStack{
                    Spacer()
                    Button(action: {
                        showAddMemo()
                    }) {
                        Text("+")
                        
                            .font(.system(size: 30))
                            .frame(width: 30, height: 30)
                            .padding()
                            .background(.cyan)
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


#Preview {
    MemoView(store:
            .init(initialState: MemoFeature.State(
//                isShowPopup: false
            ),
                  reducer: {
        MemoFeature()
    })  )
    
}

