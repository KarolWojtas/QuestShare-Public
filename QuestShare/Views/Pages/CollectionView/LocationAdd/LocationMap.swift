//
//  LocationMap.swift
//  QuestShare
//
//  Created by Karol Wojtas on 26/05/2021.
//

import SwiftUI
import MapKit
import RealmSwift
import Combine

struct LocationMap: UIViewRepresentable {
    
    let annotationInsets: CGFloat = 40.0
    @Binding var annotations: [LocationMapAnnotation]
    var locationManager: LocationManager? = nil
    var editedLocation: QSLocation? = nil
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.showsUserLocation = true
        
        mapView.delegate = context.coordinator
        context.coordinator.mapView = mapView
        context.coordinator.addGestureRecognizer(mapView)
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        /// filter only location annotations (not user annotations)
        let locationsAnnotations = uiView.annotations.compactMap {$0 as? LocationMapAnnotation}
        /// updating annotations should only run when size changes
        if locationsAnnotations.count != annotations.count {
            updateAnnotations(uiView)
        }
        
    }
    
    /// update annotations on MKMapView, set visible map region
    func updateAnnotations(_ uiView: MKMapView){
        if let safeLocationManager = locationManager {
            guard !annotations.isEmpty else {
                uiView.setRegion(safeLocationManager.defaultMapRegion, animated: true)
                return
            }
            uiView.addAnnotations(annotations)
            
            let rect: MKMapRect = safeLocationManager.mapRect(for: annotations.map{$0.coordinate})
            uiView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: annotationInsets, left: annotationInsets, bottom: annotationInsets, right: annotationInsets), animated: true)
        }
    }
    
    class Coordinator: NSObject {
        var parent: LocationMap
        var mapView: MKMapView? = nil
        private var cancellabels = Set<AnyCancellable>()
        private var currLocAnno: LocationMapAnnotation?
        
        init(_ parent: LocationMap) {
            self.parent = parent
        }
        
        deinit {
            print("LocationMap.Coordinator deinit")
        }
    }
}

//MARK: - LocationMap.Coordinator - Add Annotation
extension LocationMap.Coordinator {
    
    func addAnnotation(at coordinate: CLLocationCoordinate2D){
        if let safeMap = mapView {
            // remove existing annotations
            let idToDelete: ObjectId? = parent.editedLocation?._id ?? nil
            let annotationsToRemove = parent.annotations.filter { $0.id == idToDelete}
            if !annotationsToRemove.isEmpty {
                mapView?.removeAnnotations(annotationsToRemove)
                let difference = Set(parent.annotations).symmetricDifference(Set(annotationsToRemove))
                parent.annotations = Array(difference)
            }
            let annotation = LocationMapAnnotation(id: parent.editedLocation?._id ?? nil, name: "", coordinate: coordinate)
            safeMap.addAnnotation(annotation)
            parent.annotations.append(annotation)
        }
    }
    
    func addGestureRecognizer(_ mapView: MKMapView){
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        longPressGestureRecognizer.minimumPressDuration = 1
        mapView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    @objc func handleLongPress(sender: UITapGestureRecognizer){
        if sender.state == .began {
            if let safeMap = mapView {
                let location = sender.location(in: safeMap)
                let coordinate = safeMap.convert(location, toCoordinateFrom: safeMap)
                addAnnotation(at: coordinate)
            }
        }
    }
}

//MARK: - MKMapViewDelegate

extension LocationMap.Coordinator: MKMapViewDelegate {
    
    /*
     Customize map annotation view
     */
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let locationAnnotation = annotation as? LocationMapAnnotation {
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "LocationMapAnnotation")
            annotationView.markerTintColor = .gray
            if parent.editedLocation?._id == locationAnnotation.id {
                annotationView.markerTintColor = .red
            }
            return annotationView
        }
        /// use default annotation view (e.g. user location)
        return nil
    }
}

struct LocationMap_Previews: PreviewProvider {
    @State static var annotations = [LocationMapAnnotation]()
    static var previews: some View {
        LocationMap(annotations: $annotations)
    }
}
