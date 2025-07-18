//
//  AddMemoComponent.swift
//  SakuMemo
//
//  Created by saki on 2025/05/16.
//

import SwiftUI
import Utils
import SharedModel

public struct AddMemoComponent: View {
    public init(tapped: @escaping ()->Void, text: Binding<String>,isFocused: FocusState<Bool>? = nil) {
        self.tapped = tapped
        self._text = text
        self.isFocused = (isFocused != nil)
        
    }
    public let tapped: ()->Void
    @FocusState var isFocused: Bool
    @Binding var text: String
    public var body: some View {
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
                        .fill(Color.mainColor)
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
