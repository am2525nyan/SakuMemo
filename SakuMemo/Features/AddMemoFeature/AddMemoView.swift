//
//  AddMemoView.swift
//  SakuMemo
//
//  Created by saki on 2025/05/03.
//

import SwiftUI
import ComposableArchitecture

struct AddMemoView: View {
    @Bindable var store: StoreOf<AddMemoFeature>
    @FocusState private var isFocused: Bool
    var body: some View {
        VStack{
            HStack{
                Spacer()
                Button{
                    store.send(.save)
                }label: {
                    Image(systemName: "paperplane.fill")
                }
                .disabled(store.text.isEmpty && !store.isSending)
                .padding(.leading, 20)
                .padding(.bottom,20)
              
            }
            TextField("メモを入力",text: $store.text,axis: .vertical)
                .textFieldStyle(.customTextField(isFocused: _isFocused))
        }
        .padding(.horizontal, 20)
        .lineLimit(5...300)
        .focused($isFocused)
        .padding(.top, 20)
    }
}

#Preview {
    AddMemoView(store: .init(initialState: AddMemoFeature.State(), reducer: {
        AddMemoFeature()
    }))
}
