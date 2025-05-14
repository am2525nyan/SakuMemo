//
//  ImageCreatorRepository.swift
//  SakuMemo
//
//  Created by saki on 2025/05/13.
//

import Foundation
import ImagePlayground
import CoreGraphics
import Dependencies


final class ImageCreatorRepository {
    
    static var shared = ImageCreatorRepository()
    
    func generateImage(text: String)async throws -> CGImage? {
        do {
            let creator = try await ImageCreator()
            guard let style = creator.availableStyles.first else { return nil }
            
            
            let images = creator.images(
                for: [.text(text)],
                style: style,
                limit: 1)
            
            for try await image in images {
                let anImage = image.cgImage
                return anImage
            }
            
            
            
            // Receive the images.
            
        }
        catch ImageCreator.Error.notSupported {
            print("このデバイスでは画像生成はできません")
        } catch ImageCreator.Error.creationFailed {
            print("画像生成に失敗しました")
        } catch {
            print("エラー: \(error.localizedDescription)")
        }
        return nil
    }
}
struct ImageCreatorRepositoryKey: DependencyKey{
    static var liveValue = ImageCreatorRepository()
}
extension DependencyValues{
    var imageCreatorRepository:ImageCreatorRepository{
        get{self[ImageCreatorRepositoryKey.self]}
        set{self[ImageCreatorRepositoryKey.self] = newValue}
    }
}
