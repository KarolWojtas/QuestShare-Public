//
//  LocationMap.swift
//  QuestShare
//
//  Created by Karol Wojtas on 22/05/2021.
//

import SwiftUI
import MapKit
import Combine

struct CollectionMap: UIViewRepresentable {
    let annotationInsets: CGFloat = 40.0
    var locationManager: LocationManager?
    @ObservedObject var collectionVM: CollectionViewModel
    typealias UIViewType = MKMapView
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.isRotateEnabled = false
        mapView.isZoomEnabled = false
        mapView.isPitchEnabled = false
        context.coordinator.mapView = mapView
        context.coordinator.initLocationsListener(collectionVM.$locations)
        context.coordinator.initSelectedLocationListener(collectionVM.$selectedLocation)
        mapView.isScrollEnabled = false
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
    }
    
    /// top padding is twice the size for selected annotations
    func setMapRectForAnnotations(uiView: MKMapView, annotations: [LocationMapAnnotation]){
        if let safeLocationManager = locationManager {
            guard !annotations.isEmpty else {
                uiView.setRegion(safeLocationManager.defaultMapRegion, animated: false)
                return
            }
            let rect: MKMapRect = safeLocationManager.mapRect(for: annotations.map{$0.coordinate})
            uiView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: annotationInsets * 2, left: annotationInsets, bottom: annotationInsets, right: annotationInsets), animated: false)
        }
    }
    
    func updateAnnotations(_ mapView: MKMapView, _ newAnnotations: [LocationMapAnnotation]){
        /// remove non existent annotations
        for prevAnnotation in mapView.annotations {
            guard let safePrevAnno = prevAnnotation as? LocationMapAnnotation else {
                continue
            }
            if !newAnnotations.contains(safePrevAnno) {
                mapView.removeAnnotation(prevAnnotation)
            }
        }
        /// add new annotations
        for newAnnotation in newAnnotations {
            let annoExists = mapView.annotations.contains(where: {anno in
                if let safeAnno = anno as? LocationMapAnnotation {
                    return safeAnno == newAnnotation
                } else {
                    return false
                }
            })
            if !annoExists {
                mapView.addAnnotation(newAnnotation)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        let parent: CollectionMap
        var mapView: MKMapView? = nil
        var cancellables = [AnyCancellable]()
        var locations: [QSLocation]? = nil
        
        
        init(_ parent: CollectionMap) {
            self.parent = parent
        }
        
        /// listen to locations changes - update annotations, store current locations
        func initLocationsListener(_ locations$: Published<[QSLocation]>.Publisher) {
            let locationsCancellable = locations$
                .map{[weak self] locations -> [LocationMapAnnotation] in
                    self?.locations = locations
                    let annotations: [LocationMapAnnotation] = locations.compactMap{$0.coordinate != nil ? LocationMapAnnotation(location: $0) : nil}
                    return annotations
                }
                .subscribe(on: RunLoop.main)
                .sink { [weak self] annotations in
                    if let safeMapView = self?.mapView {
                        self?.parent.updateAnnotations(safeMapView, annotations)
                        self?.parent.setMapRectForAnnotations(uiView: safeMapView, annotations: annotations)
                    }
                }
            cancellables.append(locationsCancellable)
        }
        
        /// listen to  selected location changes - can be changed from outside
        func initSelectedLocationListener(_ selectedLocation$: Published<QSLocation?>.Publisher){
            let cancellable = selectedLocation$
                .subscribe(on: RunLoop.main)
                .sink { [weak self] selectedLoc in
                    if let safeSelectedLoc = selectedLoc {
                        if let annotation = self?.findAnnotation(self?.mapView?.annotations, for: safeSelectedLoc) {
                            self?.mapView?.selectAnnotation(annotation, animated: true)
                        }
                    } else {
                        self?.mapView?.deselectAnnotation(nil, animated: true)
                    }
                }
            cancellables.append(cancellable)
        }
        
        private func findAnnotation(_ annotations: [MKAnnotation]?, for location: QSLocation) -> LocationMapAnnotation? {
            return annotations?.first { annotation in
                (annotation as? LocationMapAnnotation )?.id == location._id
            } as? LocationMapAnnotation
        }
        
        deinit {
            for cancellable in cancellables {
                cancellable.cancel()
            }
            print("CollectionMap.Coordinator deinit")
        }
    }
}

//MARK: - MKMapViewDelegate
extension CollectionMap.Coordinator: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let safeLocations = locations {
            let annotation = view.annotation as? LocationMapAnnotation
            if let foundLocation = safeLocations.first(where: {
                $0._id == annotation?.id
            }){
                parent.collectionVM.selectedLocation = foundLocation
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        parent.collectionVM.selectedLocation = nil
    }
}

struct CollectionMap_Previews: PreviewProvider {
    @StateObject static var vm = CollectionViewModel()
    static var previews: some View {
        CollectionMap(locationManager: LocationManager(), collectionVM: vm)
    }
}
