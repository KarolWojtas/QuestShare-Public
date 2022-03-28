//
//  QSNode.swift
//  QuestShare
//
//  Created by Karol Wojtas on 04/05/2021.
//

import Foundation
import RealmSwift
import SceneKit
import SwiftUI

protocol QSNodeModel: QSBaseObjectModel {
    associatedtype Attributes
    associatedtype Vector
    var assetId: String? {get set}
    var attributes: Attributes {get set}
    var scale: Vector? {get set}
    var position: Vector? {get set}
    var rotation: Vector? {get set}
}

class QSNode: QSBaseObject, QSNodeModel {
    @Persisted var asset: QSNodeAsset? {
        didSet {
            if asset != nil && asset != oldValue {
                assetId = asset?.id
            }
        }
    }
    @Persisted var assetId: String?
    @Persisted(originProperty: "nodes") var location: LinkingObjects<QSLocation>
    @Persisted var attributes: Map<String, String>
    @Persisted var scale: QSVector? = .zero
    @Persisted var position: QSVector? = .zero
    @Persisted var rotation: QSVector? = .zero
    
    convenience init(name: String, asset: QSNodeAsset?) {
        self.init(name: name)
        self.asset = asset
    }
    
    enum NodeAttributes: String {
        case text = "text"
        case color = "color"
    }
    
    var text: String? {
        get {
            attributes[NodeAttributes.text.rawValue]
        }
        set {
            attributes[NodeAttributes.text.rawValue] = newValue
        }
    }
    
    /// only copy id if you will not put copied node in realm
    func copy(withId: Bool = false) -> QSNode {
        let copy = QSNode(name: name, asset: asset)
        if withId {
            copy._id = _id
        }
        copy.desc = desc
        copy.assetId = assetId
        copy.location = location
        copy.attributes = attributes
        copy.position = position?.copy()
        copy.rotation = rotation?.copy()
        copy.scale = scale?.copy()
        return copy
    }
}

extension QSNode {
    /// color array mapped as string
    private var colorString: String? {
        get {
            attributes[NodeAttributes.color.rawValue]
        }
        set {
            attributes[NodeAttributes.color.rawValue] = newValue
        }
    }
    
    /// double array of rgba values
    var colorElements: [Double]? {
        get {
            colorString?.split(separator: "|")
                .compactMap{Double($0)}
        }
        set {
            colorString = newValue?.compactMap{String($0)}.joined(separator: "|")
        }
    }
    
    var color: Color? {
        get {
            if let safeElements = colorElements {
                if safeElements.count == 4 {
                    return Color(.sRGB, red: safeElements[0], green: safeElements[1], blue: safeElements[2], opacity: safeElements[3])
                }
            }
            return nil
        }
    }
}

