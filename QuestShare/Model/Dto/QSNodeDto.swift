//
//  QSNodeDto.swift
//  QuestShare
//
//  Created by Karol Wojtas on 09/10/2021.
//

import Foundation
import RealmSwift

struct QSNodeDto: QSNodeModel, Codable {
    var name: String = ""
    
    var desc: String? = nil
    
    var assetId: String? = nil
    
    var attributes: [String : String] = [:]
    
    var scale: QSVectorDto? = nil
    
    var position: QSVectorDto? = nil
    
    var rotation: QSVectorDto? = nil
    
    init(model: QSNode) {
        self.assetId = model.assetId
        self.attributes = model.attributes.asDictionary()
        if let safeScale = model.scale {
            self.scale = QSVectorDto(model: safeScale)
        }
        if let safePosition = model.position {
            self.position = QSVectorDto(model: safePosition)
        }
        if let safeRotation = model.rotation {
            self.rotation = QSVectorDto(model: safeRotation)
        }
    }
}

extension QSNode {
    convenience init(dto: QSNodeDto){
        self.init()
        self.name = dto.name
        self.desc = dto.desc
        self.assetId = dto.assetId
        self.attributes = dto.attributes.asMap()
        if let safeScale = dto.scale {
            self.scale = QSVector(dto: safeScale)
        }
        if let safePosition = dto.scale {
            self.position = QSVector(dto: safePosition)
        }
        if let safeRotation = dto.scale {
            self.rotation = QSVector(dto: safeRotation)
        }
    }
}

//MARK: - Map asDictionary extension
extension Map where Key == String, Value == String {
    func asDictionary() -> [String : String] {
        var dict: [String : String] = [:]
        for key in self.keys {
            dict[key] = self[key]
        }
        return dict
    }
}

extension Dictionary where Key == String, Value == String {
    func asMap() -> Map<String, String> {
        let dict = Map<String, String>()
        for key in self.keys {
            dict[key] = self[key]
        }
        return dict
    }
}

