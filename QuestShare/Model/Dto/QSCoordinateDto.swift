//
//  QSCoordinateDto.swift
//  QuestShare
//
//  Created by Karol Wojtas on 09/10/2021.
//

import Foundation

struct QSCoordinateDto: Codable {
    var longitude: Double = 0.0
    var latitude: Double = 0.0
    
    init(model: QSCoordinate) {
        self.longitude = model.longitude
        self.latitude = model.latitude
    }
}

extension QSCoordinate {
    convenience init(dto: QSCoordinateDto){
        self.init(latitude: dto.latitude, longitude: dto.longitude)
    }
}
