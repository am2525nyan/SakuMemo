//
//  TaskView.swift
//  SakuMemo
//
//  Created by saki on 2025/04/18.
//

import SwiftUI
import ComposableArchitecture
import SwiftData

struct MemoView: View {
    @Bindable var store: StoreOf<MemoFeature>
    @Environment(\.scenePhase) var scenePhase
    @Query(filter: #Predicate<Memo>{$0.isArchived == false},sort: \Memo.createdAt, order: .reverse) var memos: [Memo]
    var body: some View {
        ZStack{
           
            VStack {
                HStack{
                    TextField("メモを入力", text: $store.text)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: {
                        store.send(.addMemo)
                    }, label:
                            {
                        Image(systemName: "paperplane.fill")
                    })
                    
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                
                List {
                    ForEach(memos) { memo in
                        HStack{
                            MemoCellView(memo: memo)
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            store.send(.showDetail(memo))
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                store.send(.deleteMemo(memo))
                            } label: {
                                Text("削除")
                            }
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                store.send(.archive(memo))
                                
                            } label: {
                                Text("アーカイブ")
                            }
                            .tint(.cyan)
                        }
                    }
                    
                }
            }
            .listStyle(PlainListStyle())
            .onAppear(){
                store.send(.onAppear)
                Task{
                    do{
                      //  await GeminiRepository().geminiText(for: "シュークリームを作る")
                    }
                }
            }
            .sheet(item: $store.scope(state: \.detail, action: \.presentMemoDetail)){detail in
                MemoDetailView(store: detail)
                    .presentationDetents([ .height(250)])
                    .presentationDragIndicator(.visible)
                    .presentationBackground(Material.thick)
                
                
            }
            .sheet(item: $store.scope(state: \.add, action: \.presentAddMemo)){add in
                AddMemoView(store: add)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
                    .presentationBackground(Material.thick)
                
                
            }
            FloatingButton(showAddMemo: {
                print("呼ばれた")
                store.send(.showAddMemo)
            })
        }
    }
    struct FloatingButton: View {
        var showAddMemo: ()->Void
        var body: some View {
            VStack{
                Spacer()
                HStack{
                    Spacer()
                    Button(action: {
                        print("add")
                        showAddMemo()
                    }) {
                        Image(systemName: "plus")
                            .padding()
                            .background(.cyan)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            .shadow(radius: 10)
                    }
                    .padding()
                }
            }
        }
    }
}

#Preview {
    MemoView(store:
            .init(initialState: MemoFeature.State(),
                  reducer: {
        MemoFeature()
    }))
}

