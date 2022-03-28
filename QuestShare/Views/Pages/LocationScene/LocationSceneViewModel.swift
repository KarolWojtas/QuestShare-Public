//
//  LocationSceneViewModel.swift
//  QuestShare
//
//  Created by Karol Wojtas on 04/08/2021.
//

import Foundation
import Combine
import RealmSwift
import CoreLocation
import SwiftUI

class LocationSceneViewModel: NSObject, ObservableObject {
    let realm = RealmManager.realm
    private var _location: QSLocation?
    var location: QSLocation? {
        _location
    }
    var locationId: ObjectId? {
        get {
            _location?._id
        }
        set {
            _location = realm.object(ofType: QSLocation.self, forPrimaryKey: newValue)
            if let safeLoc = _location {
                let locCoordinate = safeLoc.coordinate!
                target = CLLocationCoordinate2D(latitude: locCoordinate.latitude, longitude: locCoordinate.longitude)
            } else {
                target = nil
            }
        }
    }
    private var cancellables: Set<AnyCancellable> = []
    private var nodeToken: NotificationToken?
    @Published var nodes: [QSNode]?
    @Published var nodeEvent: QSNodeEvent?
    @Published var rootNodeTransform: QSRootNodeTransform?
    @Published var selectedNode: QSNode?
    @Published var distance = 0.0
    @Published var currentLocation: CLLocation?
    @Published var distanceToLarge = false
    @Published var currentHeading: CLHeading? = nil
    private var target: CLLocationCoordinate2D? /// location coordinate
    private var locationManager = CLLocationManager()
    static let distanceTreshold = 20.0 /// treshold in meters
    var readonly = false
    var settings: QSSettings? = nil
    private var calculator: NodeVectorCalculator?
    
    var workspace: QSLocationWorkspace? {
        location?.workspace
    }
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    func removeNode(_ node: QSNode){
        // remove node from local list first, so that theres no reference of it after realm delete
        nodes?.removeAll{ $0._id == node._id }
        nodeEvent = .deleted(node: node.copy(withId: true))
        do {
            try realm.write{
                realm.delete(node)
                updateTimestamp()
            }
        } catch {
            print("error deleting node: \(node)")
        }
    }
    
    func updateTimestamp(){
        workspace?.timestamp = Date()
    }
    
    func addNode(_ node: QSNode, asset: QSNodeAsset){
        do {
            try realm.write{
                node.asset = realm.object(ofType: QSNodeAsset.self, forPrimaryKey: asset.id)
                node.name = generateNodeName(asset)
                setDefaultAttributes(node, asset: asset)
                workspace?.nodes.append(node)
            }
        } catch {
            print("error updating timestamp")
        }
        nodeEvent = .added(node: node)
    }
    
    func generateNodeName(_ asset: QSNodeAsset) -> String {
        let prefix = "\(asset.id)_"
        let indexes: [Int]? = nodes?
            .filter{ $0.asset?.id == asset.id }
            .map{ $0.name.suffix(from: prefix.endIndex) }
            .map{ Int($0) ?? 0 }
        let max = indexes?.max() ?? 0
        return "\(prefix)\(max + 1)"
    }
    
    func updateNodeAttributes(_ node: QSNode, attrs: NodeEditAttributes){
        do {
            try realm.write {
                node.text = attrs.text
                node.colorElements = attrs.color?.asDoubleArray
            }
        } catch {
            print("Error saving attributes on node: \(node._id)")
        }
        nodeEvent = .updated(node: node)
    }
    
    func saveWorkspace(){
        guard let safeNodes = location?.workspace?.nodes else {
            return
        }
        do {
            try realm.write{
                location?.nodes = List()
                location?.nodes.append(objectsIn: safeNodes.map{$0.copy()})
            }
            cancelWorkspace()
        } catch {
            print("error saving workspace")
        }
    }
    
    func cancelWorkspace(){
        guard let safeWorkspace = location?.workspace else {
            return
        }
        
        nodeToken?.invalidate()
        do {
            try realm.write{
                self.nodes = nil
                for node in safeWorkspace.nodes {
                    realm.delete(node)
                }
                realm.delete(safeWorkspace)
            }
        } catch {
            print("error cancelling workspace")
        }
    }
    
    private func setDefaultAttributes(_ node: QSNode, asset: QSNodeAsset){
        switch asset.shape {
        case .text:
            node.text = "Text"
            node.colorElements = Color.blue.asDoubleArray
        default:
            break
        }
    }
    
    deinit {
        print("LocationScene ViewModel deinit")
    }
}

//MARK: - VM initialization

extension LocationSceneViewModel: ViewModelLifecycle {
    
    func onAppear() {
        calculator = NodeVectorCalculator(location?.coordinate?.clone(), settings?.worldAlignment)
        initForWorkspace()
    }
    
    func onDisappear() {
        cancellables.forEach{$0.cancel()}
        calculator = nil
    }
    
    fileprivate func initForWorkspace(){
        if location?.workspace == nil && !readonly {
            do {
                try realm.write{
                    location?.workspace = QSLocationWorkspace()
                    location?.workspace?.nodes = List()
                    if let safeNodes = location?.nodes {
                        location?.workspace?.nodes.append(objectsIn: safeNodes.map{$0.copy()})
                    }
                }
            } catch  {
                print("Error initializing LocationSceneViewModel")
            }
        }
        observeNodes(nodes: readonly ? location?.nodes : location?.workspace?.nodes)
        listenToNodeUpdates()
        updateDistance()
        calculateRootPosition()
    }
    
    private func observeNodes(nodes: RealmSwift.List<QSNode>?){
        nodeToken = nodes?.observe{ [weak self] changes in
            switch changes {
            case .initial(let list):
                let nodeList = [QSNode](list)
                self?.nodes = [QSNode](list)
                self?.nodeEvent = .list(nodes: nodeList)
            case .update(let list, deletions: _, insertions: _, modifications: _):
                self?.nodes = [QSNode](list)
            case .error(let error):
                print("LocationScene VM nodes listener error: \(error)")
            }
        }
    }
    
    private func listenToNodeUpdates(){
        $nodeEvent
            .filter{$0?.isTransform ?? false}
            .sink { [weak self] (event: QSNodeEvent!) in
                if case .transform(node: let node, position: let position, rotation: let rotation) = event {
                    self?.updateNode(node, position: position, rotation: rotation)
                }
            }
            .store(in: &cancellables)
    }
    
    /// only update position/rotation if defined
    private func updateNode(_ node: QSNode, position: QSVector?, rotation: QSVector?){
        do {
            try realm.write{
                if position != nil || rotation != nil {
                    let storedNode = realm.object(ofType: QSNode.self, forPrimaryKey: node._id)
                    if let safePostion = position {
                        storedNode?.position = safePostion
                    }
                    if let safeRotation = rotation {
                        storedNode?.rotation = safeRotation
                    }
                } else {
                    realm.add(node, update: .modified)
                }
            }
        } catch  {
            print("Error updating node: \(node)")
        }
    }
}

extension LocationSceneViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        currentHeading = newHeading
    }
    
    /// calculate distance based on current location
    func updateDistance(){
        $currentLocation
            .throttle(for: .seconds(3), scheduler: RunLoop.main, latest: true)
            .map{[weak self] currLoc -> Double in
                /// calculate distance
                if let safeTarget = self?.target, let safeCurrLoc = currLoc {
                    return safeCurrLoc.distance(from: safeTarget)
                } else {
                    return 0.0
                }
            }
            .sink{[weak self] distance in
                self?.distance = distance
                let ignoreDistance = self?.settings?.ignoreDistance ?? false
                if !ignoreDistance {
                    self?.distanceToLarge = distance > LocationSceneViewModel.distanceTreshold
                }
            }
            .store(in: &cancellables)
    }
    
    /// calculate root node position based on current location and heading
    func calculateRootPosition(){
        $currentLocation
            .filter{$0 != nil}
            .combineLatest($currentHeading.filter{$0 != nil})
            .receive(on: DispatchQueue.global(qos: .background))
            .map{[weak self] (loc, heading) -> QSRootNodeTransform? in
                if let safeOrigin = loc,
                   let safeHeading = heading {
                    let transform = self?.calculator?.submit(location: safeOrigin, heading: safeHeading)
                    self?.setOriginTransform(transform)
                    return transform
                } else {
                    return nil
                }
            }
            .receive(on: RunLoop.main)
            .filter{$0 != nil}
            .sink{ [weak self] transform in
                if let safeTransform = transform, let safeSelf = self {
                    safeSelf.rootNodeTransform = safeTransform
                }
                
            }
            .store(in: &cancellables)
    }
    
    private func setOriginTransform(_ transform: QSRootNodeTransform?, overwrite: Bool = false) {
        if self.calculator?.originTransform == nil || overwrite {
            self.calculator?.originTransform = transform
        }
    }
}
