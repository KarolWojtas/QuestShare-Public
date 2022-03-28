//
//  RealmManager.swift
//  QuestShare
//
//  Created by Karol Wojtas on 15/07/2021.
//

import Foundation
import RealmSwift

class RealmManager {
    private let realm = try! Realm()
    
    private init() {}
    
    static var shared: RealmManager = {
        let instance = RealmManager()
        return instance
    }()
    static var realm: Realm = {
        shared.realm
    }()
    
    /// perform transaction
    static func deleteCollection(_ id: ObjectId){
        do {
            try realm.write{
                if let storedCollection = realm.object(ofType: QSCollection.self, forPrimaryKey: id){
                    deleteCollection(storedCollection)
                }
            }
        } catch {
            print("error deleting collection with id: \(id)")
        }
    }
    
    /// run inside write transaction
    static func deleteCollection(_ collection: QSCollection) {
        for location in collection.locations {
            deleteLocation(location)
        }
        realm.delete(collection)
    }
    
    static func deleteLocation(_ location: QSLocation) {
        realm.delete(location.nodes)
        if let safeWorkspace = location.workspace {
            deleteWorkspace(safeWorkspace)
        }
        realm.delete(location)
    }
    
    static func deleteWorkspace(_ workspace: QSLocationWorkspace) {
        realm.delete(workspace.nodes)
        realm.delete(workspace)
    }
    
    static func storeCollection(_ collection: QSCollection) {
        do {
            try realm.write{
                /// verify first - necessary for each branch
                for location in collection.locations {
                    verifyLocation(location)
                }
                if let safeServerId = collection.serverId,
                   let storedCollection = realm.objects(QSCollection.self)
                    .filter("serverId == %@", safeServerId).first {
                    /// remove previos locations
                    for location in storedCollection.locations {
                        deleteLocation(location)
                    }
                    storedCollection.assignOther(collection)
                } else {
                    realm.add(collection)
                }
            }
        } catch {
            print("error storing collection: \(collection)")
        }
    }
    
    /// make sure location from server has appropriate fields set
    static func verifyLocation(_ location: QSLocation){
        for node in location.nodes {
            assignAsset(node)
        }
    }
    
    /// run inside write transaction
    static func assignAsset(_ node: QSNode) {
        node.asset = realm.object(ofType: QSNodeAsset.self, forPrimaryKey: node.assetId)
    }
}
