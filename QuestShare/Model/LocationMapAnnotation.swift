//
//  LocationMapAnnotation.swift
//  QuestShare
//
//  Created by Karol Wojtas on 26/05/2021.
//

import Foundation
import MapKit
import RealmSwift

class LocationMapAnnotation: NSObject, MKAnnotation, Identifiable {
    let id: ObjectId?
    let name: String?
    let coordinate: CLLocationCoordinate2D
    
    init(id: ObjectId?, name: String?, coordinate: CLLocationCoordinate2D) {
        self.id = id
        self.name = name
        self.coordinate = coordinate
    }
    
    convenience init(location: QSLocation) {
        let coordinate = location.coordinate ?? QSCoordinate(latitude: 0, longitude: 0)
        self.init(id: location._id, name: location.name,
                  coordinate: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude))
    }
}
