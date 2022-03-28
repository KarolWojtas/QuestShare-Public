//
//  CollectionsStore.swift
//  QuestShare
//
//  Created by Karol Wojtas on 24/05/2021.
//

import Foundation
import Combine
import RealmSwift
import UIKit
import Firebase

class HomeViewModel: UserViewModel {
    var realm = RealmManager.realm
    var dbManager: ServerDatabaseManager!
    @Published var collections: [QSCollection]?
    private var cancellables = Set<AnyCancellable>()
    private var collectionToken: NotificationToken?
    
    override func onAppear() {
        super.onAppear()
        collectionToken = realm.objects(QSCollection.self).observe(
            keyPaths: ["name", "desc", "user.email", "user.displayName", "serverId"]) { [weak self] changes in
            switch changes {
            case .initial(let list):
                self?.collections = [QSCollection](list).map{$0.copy()}
            case .update(let list, deletions: _, insertions: _, modifications: _):
                self?.collections = [QSCollection](list).map{$0.copy()}
            default:
                break
            }
        }
    }
    
    override func onDisappear() {
        super.onDisappear()
        collectionToken?.invalidate()
    }
    
    func deleteCollection(_ collection: QSCollection) {
        RealmManager.deleteCollection(collection._id)
    }
    
    func deleteCollection(at indexSet: IndexSet) {
        for index in indexSet {
            if let safeCollections = collections {
                let delete = safeCollections[index]
                RealmManager.deleteCollection(delete)
            }
        }
    }
    
    func uploadCollection(_ collection: QSCollection){
        dbManager.addCollection(collection)
            .sink(receiveCompletion: { (completion: Subscribers.Completion<Error>) in
                switch completion {
                case .failure(let error):
                    print(error)
                case .finished:
                    return
                }
            }){ [weak self] serverId in
                do {
                    try self?.realm.write {
                        let storedCollection = self?.realm.object(ofType: QSCollection.self, forPrimaryKey: collection._id)
                        storedCollection?.serverId = serverId
                        storedCollection?.user = self?.user
                    }
                } catch {
                    print("error updating serverId on collection")
                }
            }
            .store(in: &cancellables)
    }
}
