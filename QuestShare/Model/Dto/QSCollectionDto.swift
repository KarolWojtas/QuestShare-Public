//
//  QSCollectionDto.swift
//  QuestShare
//
//  Created by Karol Wojtas on 09/10/2021.
//

import Foundation
import FirebaseFirestoreSwift
import RealmSwift

struct QSCollectionDto: QSCollectionModel, Codable {
    @DocumentID var serverId: String?
    var name: String = ""
    var desc: String? = nil
    var user: QSUserDto? = nil
    var edited: Date = Date()
    var locations: [QSLocationDto] = []
    
    init(model: QSCollection) {
        self.serverId = model.serverId
        self.name = model.name
        self.desc = model.desc
        self.locations = model.locations.map{QSLocationDto(model: $0)}
        if let safeUser = model.user {
            self.user = QSUserDto(model: safeUser)
        }
        self.edited = model.edited
    }
    
}

extension QSCollection {
    convenience init(dto: QSCollectionDto) {
        self.init()
        self.serverId = dto.serverId
        self.name = dto.name
        self.desc = dto.desc
        self.locations = List<QSLocation>()
        self.locations.append(objectsIn: dto.locations.map{QSLocation(dto: $0)})
        if let safeUser = dto.user {
            self.user = QSUser(dto: safeUser)
        }
        self.edited = dto.edited
    }
}
