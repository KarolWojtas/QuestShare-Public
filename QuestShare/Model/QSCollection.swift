//
//  QSCollection.swift
//  QuestShare
//
//  Created by Karol Wojtas on 22/05/2021.
//

import Foundation
import RealmSwift

protocol QSCollectionModel: QSBaseObjectModel {
    associatedtype LocationList
    associatedtype Creator: QSUserModel
    var edited: Date {get set}
    var locations: LocationList {get set}
    var user: Creator? {get set}
    var serverId: String? {get set}
}

class QSCollection: QSBaseObject, QSCollectionModel {
    @Persisted var user: QSUser? = nil
    @Persisted var edited: Date = Date()
    @Persisted var locations: List<QSLocation>
    @Persisted var serverId: String? = nil
    
    func assignOther(_ other: QSCollection){
        user = other.user
        edited = other.edited
        locations = other.locations
        name = other.name
        desc = other.desc
    }
    
    func copy() -> QSCollection {
        let clone = QSCollection()
        clone._id = _id
        clone.name = name
        clone.desc = desc
        clone.user = user
        clone.edited = edited
        clone.locations = locations
        clone.serverId = serverId
        return clone
    }
}

extension QSCollection {
    var editedSeconds: Int {
        Int(edited.timeIntervalSince1970)
    }
}
