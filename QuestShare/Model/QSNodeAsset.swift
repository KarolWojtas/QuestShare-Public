//
//  QSNodeImage.swift
//  QuestShare
//
//  Created by Karol Wojtas on 12/08/2021.
//

import Foundation
import RealmSwift

class QSNodeAsset: Object, ObjectKeyIdentifiable {
    // identifier for nodes in readable form
    @Persisted(primaryKey: true) var id: String
    @Persisted var model: String? // path to 3d model
    @Persisted var image: String? // path to model image
    @Persisted var imageType: ImageType?
    @Persisted var shape: NodeShape? // simple shape asset
    
    enum ImageType: Int, PersistableEnum {
        case system = 1
        case appResource = 2
        case fileResource = 3
    }
    
    enum NodeShape: Int, PersistableEnum {
        case sphere = 1
        case box = 2
        case text = 3
    }
    
    convenience init(id: String, model: String?, image: String?, imageType: ImageType?){
        self.init()
        self.id = id
        self.model = model
        self.image = image
        self.imageType = imageType
    }
    
    convenience init(shape: NodeShape?) {
        self.init()
        self.shape = shape
        switch self.shape {
        case .text:
            self.image = "text.cursor"
            self.imageType = .system
            self.id = "text"
        default:
            self.id = UUID().uuidString
        }
        // TODO add premade image for shapes
    }
}
