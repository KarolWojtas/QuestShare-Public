//
//  LocationListItem.swift
//  QuestShare
//
//  Created by Karol Wojtas on 25/05/2021.
//

import SwiftUI
import MapKit

struct LocationListItem: View {
    var location: QSLocation
    var editMode: Bool = false
    @State var center: CLLocationCoordinate2D
    @State private var distance = 0.0
    @EnvironmentObject var locationManager: LocationManager
    init(location: QSLocation, editMode: Bool) {
        self.location = location
        self.editMode = editMode
        let coordinate = location.coordinate!
        center = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
    var body: some View {
        HStack {
            VStack(alignment: .leading){
                Text(location.name)
                    .fontWeight(.bold)
                    .font(.title3)
                    .foregroundColor(Color.green)
                if let safeCoordinate = location.coordinate {
                    Text(safeCoordinate.description)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                if let safeDesc = location.desc {
                    Text(safeDesc)
                }
            }
            Spacer()
            VStack (alignment: .trailing){
                distanceText
            }
        }
        .contentShape(Rectangle())
        .frame(maxWidth: .infinity)
        .onReceive(locationManager.$currentLocation
                    .throttle(for: .seconds(5), scheduler: RunLoop.main, latest: true), perform: {
                        distance = $0?.distance(from: CLLocation(latitude: center.latitude, longitude: center.longitude)) ?? 0.0
        })
    }
    
    var distanceText: Text {
        let (distance, unit) = distance >= 1000 ? (distance / 1000, UnitLength.kilometers) : (distance, UnitLength.meters)
        return Text(Measurement(value: distance, unit: unit), format: .measurement(width: .narrow))
    }
}

struct LocationListItem_Previews: PreviewProvider {
    @State static var loc = QSLocation(name: "Sample location", desc: "superrrrr",coordinate: QSCoordinate(latitude: 18.0, longitude: 52.0))
    static var previews: some View {
        List(0..<1) { item in
            LocationListItem(location: loc, editMode: true)
                .environmentObject(LocationManager())
        }
    }
}

//MARK: - code for map preview
//        annotations = [LocationMapAnnotation(id: location._id, name: nil, coordinate: center)]
//        region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002))
//            Map(coordinateRegion: $region, annotationItems: annotations){
//                MapPin(coordinate: $0.coordinate)
//            }
//            .frame(width: 100, height: 100)
//            .disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
//            .clipShape(RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/))
