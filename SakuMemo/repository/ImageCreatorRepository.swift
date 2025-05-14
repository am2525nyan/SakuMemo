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
import ImageIO
import MobileCoreServices

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
    func saveCGImageToTemporaryFile(_ image: CGImage, fileName: String = "\(UUID().uuidString).jpg") throws -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        guard let destination = CGImageDestinationCreateWithURL(url as CFURL, kUTTypeJPEG, 1, nil) else {
            throw NSError(domain: "SaveImageError", code: 0, userInfo: [NSLocalizedDescriptionKey: "画像保存に失敗しました"])
        }
        
        CGImageDestinationAddImage(destination, image, nil)
        
        if CGImageDestinationFinalize(destination) {
            return url
        } else {
            throw NSError(domain: "SaveImageError", code: 1, userInfo: [NSLocalizedDescriptionKey: "画像ファイルの最終化に失敗しました"])
        }
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
