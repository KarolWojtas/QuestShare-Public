//
//  FirebaseManager.swift
//  QuestShare
//
//  Created by Karol Wojtas on 02/10/2021.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import Combine

struct FirebaseManager: ServerDatabaseManager {
    
    let collectionsPath = "collections"
    
    func addCollection(_ collection: QSCollection) -> Future<String, Error>{
        Future { promise in
            let db = Firestore.firestore()
            do {
                var dto = QSCollectionDto(model: collection)
                if let safeServerId = dto.serverId {
                    try db.collection(collectionsPath)
                        .document(safeServerId)
                        .setData(from: dto)
                    promise(.success(safeServerId))
                } else {
                    if let safeUser = AuthManager.currentUser() {
                        dto.user = QSUserDto(model: safeUser)
                    }
                    let addedDoc = try db.collection(collectionsPath)
                        .addDocument(from: dto)
                    promise(.success(addedDoc.documentID))
                }
            } catch {
                promise(.failure(error))
            }
        }
    }
    
    func removeCollection(_ collection: QSCollection) -> Future<Void, Error>{
        Future { promise in
            let db = Firestore.firestore()
            if let serverId = collection.serverId {
                db.collection(collectionsPath)
                    .document(serverId)
                    .delete{ error in
                        if let safeError = error {
                            promise(.failure(safeError))
                        } else {
                            promise(.success(Void()))
                        }
                    }
            } else {
                promise(.failure(OperationError(message: "collection has no server id")))
            }
        }
    }
    
    func getCollections(query: String, limit: Int) -> Future<[QSCollection]?, Never> {
        //https://stackoverflow.com/questions/46573804/firestore-query-documents-startswith-a-string
        Future { promise in
            let db = Firestore.firestore()
            var request = db.collection(collectionsPath)
                .limit(to: limit)
            /// filter results by query
            if let upperBound = getQueryUpperBound(query) {
                request = request
                    .whereField("name", isGreaterThanOrEqualTo: query)
                    .whereField("name", isLessThan: upperBound)
            }
            
            request.getDocuments { (snapshot: QuerySnapshot?, error: Error?) in
                guard let documents = snapshot?.documents else {
                    promise(.success(nil))
                    return
                }
                let dtoResults = documents.compactMap { docSnapshot in
                    try? docSnapshot.data(as: QSCollectionDto.self)
                }
                let results = dtoResults.map{QSCollection(dto: $0)}
                promise(.success(results))
            }
        }
    }
    
    private func getQueryUpperBound(_ value: String?) -> String? {
        guard let query = value else {
            return nil
        }
        if query.isEmpty {
            return nil
        }
        let suffix = query.suffix(1).first
        if let suffixCharCode = suffix?.unicodeScalars.first?.value,
           let nextUnicodeScalar = UnicodeScalar(suffixCharCode + 1){
            var result = String(query.prefix(query.count - 1))
            let nextChar = Character(nextUnicodeScalar)
            result.append(nextChar)
            return result
        } else {
            return nil
        }
        
    }
    
    struct OperationError: Error {
        var message: String = ""
    }
}

