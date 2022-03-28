//
//  LocationAddViewModel.swift
//  QuestShare
//
//  Created by Karol Wojtas on 05/07/2021.
//

import Foundation
import RealmSwift

class LocationAddViewModel: ObservableObject, ViewModelLifecycle {
    var editedLocation: QSLocation? = nil
    var locations: [QSLocation] = []
    @Published var annotations: [LocationMapAnnotation] = []
    
    func onAppear() {
        self.annotations = locations.compactMap{$0.coordinate != nil ? LocationMapAnnotation(location: $0) : nil}
    }
    
    func onDisappear() {
        self.editedLocation = nil
        self.locations = []
        self.annotations = []
    }
    
    func locationChanges(name: String, desc: String) -> (QSLocation, Bool) {
        if let safeEditedLocation = editedLocation {
            // edited
            let anno = annotations.first{$0.id == safeEditedLocation._id}!
            let updatedLocation = QSLocation(name: name, desc: desc)
            updatedLocation._id = safeEditedLocation._id
            updatedLocation.coordinate = QSCoordinate(latitude: anno.coordinate.latitude, longitude: anno.coordinate.longitude)
            return (updatedLocation, false)
        } else {
            // added
            let anno = annotations.first{$0.id == nil}!
            let addedLocation = QSLocation(name: name, desc: desc)
            addedLocation._id = ObjectId.generate()
            addedLocation.coordinate = QSCoordinate(latitude: anno.coordinate.latitude, longitude: anno.coordinate.longitude)
            return (addedLocation, true)
        }
    }
}
