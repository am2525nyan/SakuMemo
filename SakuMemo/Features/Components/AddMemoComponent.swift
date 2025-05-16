//
//  AddMemoComponent.swift
//  SakuMemo
//
//  Created by saki on 2025/05/16.
//

import SwiftUI

struct AddMemoComponent: View {
    let tapped: ()->Void
    @FocusState var isFocused: Bool
    @Binding var text: String
    var body: some View {
        HStack{
            VStack{
                TextField("メモを入力", text: $text)
                    .textFieldStyle(CustomTextFieldStyle(isFocused: _isFocused ))
                    .focused($isFocused)
            }
            Button(action: {
                tapped()
            }, label:
                    {
                ZStack{
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.cyan)
                        .frame(width: 50, height: 50)
                    Image(systemName: "paperplane.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.white)
                }
            })
            
            
            
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        
    }
}

#Preview {
    AddMemoComponent(tapped: {
        print("")},
                     text: .constant("テスト"))
    
}
