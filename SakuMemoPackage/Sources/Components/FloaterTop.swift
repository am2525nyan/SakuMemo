//
//  FloaterTop.swift
//  SakuMemo
//
//  Created by saki on 2025/05/16.
//

import SwiftUI
import SharedModel

public struct FloaterTop: View {
    public init() {}

    public var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.mainColor)
                .frame(maxWidth: .infinity,maxHeight: 60)
                
            HStack{
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 24))
                

                VStack{
                    Text("登録完了！")
                        .foregroundColor(.white)
                        .bold()
                        .font(.system(size: 17))
                    Text("メモを追加しました！！")
                        .font(.system(size: 15))
                        .foregroundColor(.white)
                }
                .padding()
               
            }
            .padding(.horizontal,10)
           
          
        }
        
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
       
       
    }
}

#Preview {
    FloaterTop()
}
