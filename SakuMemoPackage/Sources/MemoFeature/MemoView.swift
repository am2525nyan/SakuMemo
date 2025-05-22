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
    @Query(filter: #Predicate<Memo>{$0.isArchived == true},sort: \Memo.createdAt, order: .reverse) var archiveMemos: [Memo]

    
    public var body: some View {
        ZStack{
            VStack {
                AddMemoComponent(
                    tapped: {
                        store.send(.addMemo)
                    },
                    text:$store.text, isFocused: _isFocused
                )
                HStack{
                    ZStack{
                        RoundedRectangle(cornerRadius:10)
                            .fill(.cyan)
                          
                          
                        VStack(alignment:.center){
                            Text("残りのメモ")
                                .padding(.top,10)
                                .foregroundColor(.white)
                            Spacer()
                            HStack{
                                Spacer()
                                Text(String(memos.count))
                                    .font(.system(size: 40))
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding(.bottom,10)
                                    .padding(.trailing,-5)
                                Text("こ")
                                    .foregroundColor(.white)
                                
                                   
                            }
                            .padding(.trailing,10)
                          
                        }
                    }
                    .frame(width: 150,height: 100)
                    .padding(.trailing,20)
                    ZStack{
                        RoundedRectangle(cornerRadius:10)
                            .fill(.orange)
                          
                          
                        VStack(alignment:.center){
                            Text("アーカイブ数")
                                .padding(.top,10)
                                .foregroundColor(.white)
                            Spacer()
                            HStack{
                                Spacer()
                                Text(String(archiveMemos.count))
                                    .font(.system(size: 40))
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding(.bottom,10)
                                    .padding(.trailing,-5)
                                Text("こ")
                                    .foregroundColor(.white)
                                
                                   
                            }
                            .padding(.trailing,10)
                          
                        }
                    }
                    .frame(width: 150,height: 100)
                   
                    
                }
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


#Preview (traits: .sampleMemos) {
    MemoView(store:
            .init(initialState: MemoFeature.State(
                
            ),
                  reducer: {
        MemoFeature()
    })  )
    
}

