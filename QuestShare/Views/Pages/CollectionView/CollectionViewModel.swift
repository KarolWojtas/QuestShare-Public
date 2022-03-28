//
//  CollectionViewModel.swift
//  QuestShare
//
//  Created by Karol Wojtas on 03/07/2021.
//

import Foundation
import RealmSwift

/// ViewModel for CollectionView
class CollectionViewModel: ObservableObject, ViewModelLifecycle {
    let realm = RealmManager.realm
    private var _collection: QSCollection?
    var collection: QSCollection? {
        get {
            _collection
        }
        
        set {
            if let safeCollection = newValue {
                _collection = realm.object(ofType: QSCollection.self, forPrimaryKey: safeCollection._id)
            } else {
                _collection = nil
            }
        }
    }
    @Published var locations: [QSLocation] = []
    @Published var selectedLocation: QSLocation? = nil
    var user: QSUser? = nil
    
    func onAppear() {
        if let safeLocations = collection?.locations {
            self.locations = safeLocations.map{$0.copy()}
        } else {
            self.locations = []
        }
    }
    
    func onDisappear() {
        self.locations = []
        self.collection = nil
        self.selectedLocation = nil
    }
    
    func deleteLocation(_ location: QSLocation) {
        if let delIx = self.locations.firstIndex(of: location){
            //TODO delete workspace and nodes
            self.locations.remove(at: delIx)
        }
    }
    
    private func persistCollection(_ collection: QSCollection){
        do {
            try realm.write {
                realm.add(collection)
            }
        } catch  {
            print("error saving collection: \(collection)")
        }
    }
    
    func saveLocation(location: QSLocation, added: Bool){
        if added {
            locations.append(location)
        } else {
            let existing = locations.first{$0._id == location._id}
            if let safeExisting = existing {
                safeExisting.name = location.name
                safeExisting.desc = location.desc
                safeExisting.coordinate = location.coordinate
            }
        }
        // trigger locations publisher
        locations = locations
    }
    
    func saveCollection(name: String, desc: String) -> QSCollection? {
        if let safeCollection = self.collection {
            do {
                let objFromDb = realm.object(ofType: QSCollection.self, forPrimaryKey: safeCollection._id)!
                try realm.write{
                    objFromDb.name = name
                    objFromDb.desc = desc
                    objFromDb.user = user
                    updateLocations(objFromDb)
                    objFromDb.edited = Date()
                }
                self.collection = objFromDb
                return objFromDb
            } catch {
                print("error updating collection: \(error)")
                return self.collection
            }
        } else {
            let collection = QSCollection(name: name, desc: desc)
            collection.locations.append(objectsIn: self.locations)
            collection.user = user
            persistCollection(collection)
            self.collection = collection
            return collection
        }
    }
    
    private func updateLocations(_ collection: QSCollection){
        var updatedLocations = Set<QSLocation>()
        for editedLoc in locations {
            let storedLoc = collection.locations.first{$0._id == editedLoc._id}
            if let safeStoredLoc = storedLoc {
                // edited
                safeStoredLoc.name = editedLoc.name
                safeStoredLoc.desc = editedLoc.desc
                safeStoredLoc.coordinate = editedLoc.coordinate
                updatedLocations.insert(safeStoredLoc)
            } else {
                // new
                collection.locations.append(editedLoc)
                updatedLocations.insert(editedLoc)
            }
        }
        // deleted
        let deletedLocations = Set(collection.locations).symmetricDifference(updatedLocations)
        realm.delete(deletedLocations)
    }
}
