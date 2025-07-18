import SwiftUI
import ComposableArchitecture
import SharedModel
#if canImport(UIKit)
import UIKit
#endif



public struct SubscriptionView: View {
    public init(store: StoreOf<SubscriptionFeature>) {
        self.store = store
    }
    
    @Bindable var store: StoreOf<SubscriptionFeature>
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if store.isSubscribed {
                        subscriptionActiveView
                    } else {
                        subscriptionPromptView
                    }
                    
                    if !store.products.isEmpty {
                        productsView
                    }
                    
                    if store.isLoading {
                        ProgressView("読み込み中...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .padding()
            }
            .navigationTitle("課金設定")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("復元") {
                        store.send(.restorePurchases)
                    }
                    .disabled(store.isLoading)
                }
            }
            .onAppear {
                store.send(.onAppear)
            }
            .alert("エラー", isPresented: $store.showError) {
                Button("OK") {
                    store.send(.dismissError)
                }
            } message: {
                Text(store.errorMessage ?? "不明なエラーが発生しました")
            }
        }
    }
    
    private var subscriptionActiveView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.largeTitle)
                .foregroundColor(.green)
            
            Text("プレミアムユーザー")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("無制限にメモを作成できます")
                .font(.body)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "infinity")
                        .foregroundColor(.blue)
                    Text("無制限メモ作成")
                }
                
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundColor(.purple)
                    Text("AI解析機能")
                }
                
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                    Text("開発者サポート")
                }
            }
            .padding()
            .background(Color.gray)
            .cornerRadius(12)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 2)
    }
    
    private var subscriptionPromptView: some View {
        VStack(spacing: 16) {
            Image(systemName: "star.fill")
                .font(.largeTitle)
                .foregroundColor(.yellow)
            
            Text("プレミアムにアップグレード")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("残り: \(store.remainingFreeMemos)回")
                .font(.headline)
                .foregroundColor(.orange)
            
            Text("無料ユーザーは1日3回までメモを作成できます")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "infinity")
                        .foregroundColor(.blue)
                    Text("無制限メモ作成")
                }
                
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundColor(.purple)
                    Text("AI解析機能")
                }
                
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                    Text("開発者サポート")
                }
            }
            .padding()
            .background(Color.gray)
            .cornerRadius(12)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 2)
    }
    
    private var productsView: some View {
        VStack(spacing: 12) {
            Text("プラン選択")
                .font(.headline)
                .padding(.bottom, 8)
            
            ForEach(store.products) { product in
                Button(action: {
                    store.send(.purchaseProduct(product))
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(product.displayName)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text(product.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text(product.price)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                }
                .disabled(store.isLoading || store.isSubscribed)
            }
        }
    }
}

#Preview {
    SubscriptionView(store: .init(
        initialState: SubscriptionFeature.State(),
        reducer: { SubscriptionFeature() }
    ))
}
