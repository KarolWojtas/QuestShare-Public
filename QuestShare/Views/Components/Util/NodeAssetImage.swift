//
//  NodeAssetImage.swift
//  QuestShare
//
//  Created by Karol Wojtas on 17/08/2021.
//

import SwiftUI

struct NodeAssetImage: View {
    var asset: QSNodeAsset
    private let systemImagePadding: CGFloat = 32.0
    var body: some View {
        if let safeImage = asset.image, let safeImageType = asset.imageType {
            switch safeImageType {
            case .system:
                Image(systemName: safeImage)
                    .resizable()
                    .scaledToFit()
                    .padding(systemImagePadding)
            case .appResource:
                Image(safeImage, bundle: .main)
                    .resizable()
                    .scaledToFit()
            default:
                // todo add file image support
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .padding(systemImagePadding)
            }
        } else {
            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .padding(systemImagePadding)
        }
    }
}

struct NodeAssetImage_Previews: PreviewProvider {
    static var previews: some View {
        NodeAssetImage(asset: QSNodeAsset())
    }
}
