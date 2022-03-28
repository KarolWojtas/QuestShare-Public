//
//  QSLocation.swift
//  QuestShare
//
//  Created by Karol Wojtas on 22/05/2021.
//

import Foundation
import CoreLocation
import RealmSwift

protocol QSLocationModel: QSBaseObjectModel {
    associatedtype NodeList
    associatedtype Coordinate
    var nodes: NodeList {get set}
    var coordinate: Coordinate? {get set}
}

class QSLocation: QSBaseObject, QSLocationModel {
    @Persisted(originProperty: "locations") var collection: LinkingObjects<QSCollection>
    @Persisted var nodes: List<QSNode>
    @Persisted var coordinate: QSCoordinate? = nil
    @Persisted var workspace: QSLocationWorkspace? = nil
    convenience init(name: String, desc: String? = nil, nodes: [QSNode] = []) {
        self.init(name: name, desc: desc)
    }
    
    convenience init(name: String, desc: String? = nil, coordinate: QSCoordinate? = nil) {
        self.init(name: name, desc: desc)
        self.coordinate = coordinate
    }
    
    func copy() -> QSLocation {
        let copy = QSLocation(name: name, desc: desc)
        copy._id = _id
        if let safeCoordinate = coordinate {
            copy.coordinate = QSCoordinate(latitude: safeCoordinate.latitude, longitude: safeCoordinate.longitude)
        }
        copy.workspace = workspace
        copy.nodes = nodes
        return copy
    }
}
