//
//  QSLocationDto.swift
//  QuestShare
//
//  Created by Karol Wojtas on 09/10/2021.
//

import Foundation
import FirebaseFirestoreSwift
import RealmSwift

struct QSLocationDto: QSLocationModel, Codable {
    var name: String = ""
    
    var desc: String? = nil
    
    var nodes: [QSNodeDto] = []
    
    var coordinate: QSCoordinateDto? = nil
    
    init(model: QSLocation) {
        self.name = model.name
        self.desc = model.desc
        self.nodes = model.nodes.map{QSNodeDto(model: $0)}
        if let safeCoordinate = model.coordinate {
            self.coordinate = QSCoordinateDto(model: safeCoordinate)
        }
    }
}

extension QSLocation {
    convenience init(dto: QSLocationDto) {
        self.init()
        self.name = dto.name
        self.desc = dto.desc
        self.nodes = List<QSNode>()
        self.nodes.append(objectsIn: dto.nodes.map{QSNode(dto: $0)})
        if let safeCoordinate = dto.coordinate {
            self.coordinate = QSCoordinate(dto: safeCoordinate)
        }
    }
}
