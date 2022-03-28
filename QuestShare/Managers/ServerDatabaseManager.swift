//
//  DatabaseManager.swift
//  QuestShare
//
//  Created by Karol Wojtas on 02/10/2021.
//

import Foundation
import Combine

protocol ServerDatabaseManager {
    func addCollection(_ collection: QSCollection) -> Future<String, Error>
    func removeCollection(_ collection: QSCollection) -> Future<Void, Error>
    func getCollections(query: String, limit: Int) -> Future<[QSCollection]?, Never>
}

struct EmptyDbManager: ServerDatabaseManager {
    
    func addCollection(_ collection: QSCollection) -> Future<String, Error> {
        Future{ promise in
            promise(.success(""))
        }
    }
    
    func removeCollection(_ collection: QSCollection) -> Future<Void, Error> {
        Future{ promise in
            promise(.success(Void()))
        }
    }
    
    func getCollections(query: String, limit: Int) -> Future<[QSCollection]?, Never> {
        Future{ promise in
            promise(.success(nil))
        }
    }
    
    
}
