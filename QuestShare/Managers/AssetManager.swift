//
//  AssetManager.swift
//  QuestShare
//
//  Created by Karol Wojtas on 12/08/2021.
//

import Foundation
import RealmSwift
import ModelIO
import SceneKit
import SceneKit.ModelIO

class AssetManager {
    private init() {}
    static let appAssetFiles: Set<AssetFile> = [
        .usdz("chair_swan"),
        .usdz("tv_retro"),
        .usdz("wheelbarrow"),
        .usdz("toy_robot")
    ]
    
    static var shared: AssetManager = {
        let instance = AssetManager()
        return instance
    }()
    
    /// asset setup - running in background
    static func bootstrapRealm(){
        let configuration = RealmManager.realm.configuration
        DispatchQueue(label: "background", qos: .background).async {
            autoreleasepool {
                do {
                    let realm = try! Realm(configuration: configuration)
                    try realm.write {
                        for asset in assetList {
                            if realm.object(ofType: QSNodeAsset.self, forPrimaryKey: asset.id) == nil {
                                realm.add(asset)
                            }
                        }
                    }
                } catch  {
                    print("Error bootstraping assets")
                }
            }
        }
    }
    
    fileprivate static var assetList: [QSNodeAsset] {
        var assets = appAssetFiles.map { assetFile -> QSNodeAsset in
            let assetName = assetFile.assetId
            return QSNodeAsset(id: assetName, model: assetName, image: assetName, imageType: .appResource)
        }
        assets.append(QSNodeAsset(shape: .text))
        return assets
    }
    
    static func asset(name: String) -> QSNodeAsset? {
        RealmManager.realm.objects(QSNodeAsset.self).filter("id == %@", name).first
    }
    
    static func isAppAsset(assetId: String?) -> Bool {
        if let safeId = assetId {
            return appAssetFiles.contains { $0.assetId == safeId}
        } else {
            return false
        }
    }
    
    static func urlPath(assetId: String) -> URL? {
        guard let asset = appAssetFiles.first(where: {$0.assetId == assetId}) else {
            return nil
        }
        return Bundle.main.url(
            forResource: assetId,
            withExtension: asset.fileExtension,
            subdirectory: "Objects.scnassets"
        )
    }
    
    static func nodeForAsset(assetId: String) -> SCNNode? {
        let asset = appAssetFiles.first(where: {$0.assetId == assetId})
        switch asset {
        case .scn(_):
            return scnNodeForAsset(assetId: assetId)
        case .usdz(_):
            return defaultNodeForAsset(assetId: assetId)
        case .none:
            return nil
        }
    }
    
    fileprivate static func scnNodeForAsset(assetId: String) -> SCNNode? {
        guard let urlPath = urlPath(assetId: assetId) else {
            return nil
        }
        let nodeScene = try? SCNScene(url: urlPath, options: [.checkConsistency: true])
        return nodeScene?.rootNode.childNode(withName: assetId, recursively: true)
    }
    
    fileprivate static func defaultNodeForAsset(assetId: String) -> SCNNode? {
        guard let urlPath = urlPath(assetId: assetId) else {
            return nil
        }
        let mdlAsset = MDLAsset(url: urlPath)
        mdlAsset.loadTextures()
        let scene = SCNScene(mdlAsset: mdlAsset)
        let node = scene.rootNode.childNode(withName: assetId, recursively: true)
        return node
    }
}

enum AssetFile: Hashable {
    case scn(_ assetId: String)
    case usdz(_ assetId: String)
    // case generic(_ assetId: String, fileExtension: String)
    
    var fileExtension: String {
        switch self {
        case .scn(_):
            return "scn"
        case .usdz(_):
            return "usdz"
        }
    }
    
    var assetId: String {
        switch self {
        case .scn(let assetId),
                .usdz(let assetId):
            return assetId
        }
    }
}
