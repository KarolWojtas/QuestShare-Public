//
//  CollectionSearchViewModel.swift
//  QuestShare
//
//  Created by Karol Wojtas on 02/10/2021.
//

import Foundation
import Combine
import FirebaseFirestoreSwift
import Firebase
import RealmSwift

class CollectionSearchViewModel: ObservableObject, ViewModelLifecycle {
    @Published var query: String = ""
    @Published var results: [QSCollection] = []
    @Published var matchDict: Dictionary<QSCollection, QSCollection> = [:]
    private var storedCollections: Results<QSCollection>?
    var limit = 10
    var dbManager: ServerDatabaseManager!
    private var cancellables = Set<AnyCancellable>()
    private let realm = RealmManager.realm
    var user: QSUser? = nil
    
    func onAppear() {
        user = AuthManager.currentUser()
        storedCollections = realm.objects(QSCollection.self)
        let _ = search()
        $query.throttle(for: .seconds(1), scheduler: RunLoop.main, latest: true)
            .map{ [weak self] (_: String) -> AnyPublisher<[QSCollection]?, Never> in
                self?.search() ?? Empty().eraseToAnyPublisher()
            }
            .switchToLatest()
            .sink { [weak self] (collections: [QSCollection]?) in
                self?.results = collections ?? []
                if let safeResults = self?.results,
                   let safeStored = self?.storedCollections,
                   let safeSelf = self {
                    safeSelf.matchDict = safeSelf.matchCollections(results: safeResults, stored: safeStored)
                }
            }
            .store(in: &cancellables)
    }
    
    func search() -> AnyPublisher<[QSCollection]?, Never> {
        return dbManager.getCollections(query: query, limit: limit)
            .eraseToAnyPublisher()
    }
    
    /// search for stored collections, which match results from server
    private func matchCollections(results: [QSCollection], stored: Results<QSCollection>) -> Dictionary<QSCollection, QSCollection> {
        var dict: Dictionary<QSCollection, QSCollection> = [:]
        for result in results {
            if let matchStored: QSCollection = stored.first(where: { $0.serverId == result.serverId}) {
                dict[result] = matchStored
            }
        }
        return dict
    }
    
    func storeCollection(_ collection: QSCollection){
        RealmManager.storeCollection(collection)
        /// refresh match dict
        matchDict = matchCollections(results: results, stored: storedCollections!)
    }
    
    func onDisappear() {
        for cancellable in cancellables {
            cancellable.cancel()
        }
        user = nil
        storedCollections = nil
        matchDict = [:]
    }
    
    deinit {
        print("CollectionSearch view model deinit")
    }
}
