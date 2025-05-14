//
//  ImageCreatorRepository.swift
//  SakuMemo
//
//  Created by saki on 2025/05/13.
//

import Foundation
import ImagePlayground

final class ImageCreatorRepository {
    
    static var shared = ImageCreatorRepository()
    
    func generateImage()async throws {
        do {
            let creator = try await ImageCreator()
            guard let style = creator.availableStyles.first else { return }


            let images = creator.images(
                for: [.text("A cat wearing mittens.")],
                style: style,
                limit: 4)


            // Receive the images.
            for try await image in images {
                let anImage = image.cgImage


                // Do something with the image.
            }
        }
        catch ImageCreator.Error.notSupported {
            print("Image creation not supported on the current device.")
        }

        
    }
}
