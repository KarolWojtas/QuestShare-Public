//
//  LocationManager.swift
//  QuestShare
//
//  Created by Karol Wojtas on 25/05/2021.
//

import Foundation
import Combine
import CoreLocation
import MapKit

class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    @Published var currentLocation: CLLocation? = nil
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func getMapRegion(locations: [QSLocation]) -> MKCoordinateRegion {
        let coordinates = locations
            .compactMap { $0.coordinate }
            .map{CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)}
        return MKCoordinateRegion(self.mapRect(for: coordinates))
    }
    
    func getMapRegion(annotations: [LocationMapAnnotation]) -> MKCoordinateRegion {
        let coordinates = annotations
            .map{$0.coordinate}
        return MKCoordinateRegion(self.mapRect(for: coordinates))
    }
    
    func mapRect(for coordinates: [CLLocationCoordinate2D]) -> MKMapRect {
        var rect: MKMapRect = .null
        for coordinate in coordinates {
            let point: MKMapPoint = MKMapPoint(coordinate)
            rect = rect.union(MKMapRect(x: point.x, y: point.y, width: 0.1, height: 0.1))
        }
        return rect
    }
    
    var defaultMapRegion: MKCoordinateRegion {
        let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        if let safeCoordinate = currentLocation?.coordinate {
            return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: safeCoordinate.latitude, longitude: safeCoordinate.longitude), span: defaultSpan)
        } else {
            return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), span: defaultSpan)
        }
    }
    
    // https://stackoverflow.com/questions/26998029/calculating-bearing-between-two-cllocation-points-in-swift
    // http://www.movable-type.co.uk/scripts/latlong.html 19.10.2021
    static func bearing(fromLat: Double, fromLon: Double, toLat: Double, toLon: Double) -> Double{
        let lat1 = fromLat.radians
        let lon1 = fromLon.radians
        
        let lat2 = toLat.radians
        let lon2 = toLon.radians
        
        let dLon = lon2 - lon1
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)
        
        return radiansBearing.degrees
    }
}

//MARK: - CLLocationManager
extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location
        }
    }
}

//MARK: - Coordinate calculation

extension Double {
    var radians: Double {
        return self * .pi / 180
    }
    var degrees: Double {
        return self * 180 / .pi
    }
}

extension CLLocationCoordinate2D {
    func bearingTo(_ target: CLLocationCoordinate2D) -> Double {
        return LocationManager.bearing(fromLat: self.latitude, fromLon: self.longitude, toLat: target.latitude, toLon: target.longitude)
    }
    
    func bearingTo(_ target: QSCoordinate) -> Double {
        return LocationManager.bearing(fromLat: self.latitude, fromLon: self.longitude, toLat: target.latitude, toLon: target.longitude)
    }
    
}

extension CLLocation {    
    func distance(from: QSCoordinate) -> Double {
        self.distance(from: CLLocation(latitude: from.latitude, longitude: from.longitude))
    }
    
    func distance(from: CLLocationCoordinate2D) -> Double {
        self.distance(from: CLLocation(latitude: from.latitude, longitude: from.longitude))
    }
}
