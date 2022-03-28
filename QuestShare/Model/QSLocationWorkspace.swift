//
//  QSLocationWorkspace.swift
//  QuestShare
//
//  Created by Karol Wojtas on 19/07/2021.
//

import Foundation
import RealmSwift

/**
 This object is a workspace for location - user can add nodes, which are persisted constantly
 In case of interruption, changes on Scene are not lost, but simply stored on the side
  When saving location, it is removed and nodes are copied to nodes property of QSLocation
 */
class QSLocationWorkspace: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted(originProperty: "workspace") var location: LinkingObjects<QSLocation>
    @Persisted var nodes: List<QSNode>
    @Persisted var timestamp = Date()
}
