//
//  QSVectorDto.swift
//  QuestShare
//
//  Created by Karol Wojtas on 09/10/2021.
//

import Foundation

struct QSVectorDto: QSVectorModel, Codable {
    var x: Float = 0.0
    
    var y: Float = 0.0
    
    var z: Float = 0.0
    
    init(model: QSVector){
        self.x = model.x
        self.y = model.y
        self.z = model.z
    }
}

extension QSVector {
    convenience init(dto: QSVectorDto){
        self.init()
        self.x = dto.x
        self.y = dto.y
        self.z = dto.z
    }
}
