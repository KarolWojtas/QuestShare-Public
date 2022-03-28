//
//  ARSceneCoordinator.swift
//  QuestShare
//
//  Created by Karol Wojtas on 24/08/2021.
//

import Foundation
import ARKit
import Combine
import SceneKit
import RealmSwift
import SceneKit.ModelIO

extension ARScene {
    
    class Coordinator: NSObject {
        let parent: ARScene
        let sceneVM: LocationSceneViewModel
        let readonly: Bool
        var sceneView: ARSCNView?
        let defaultText = "Text"
        lazy var modelRoot: SCNNode = {
            createRootNode()
        }()
        private var cancellables = Set<AnyCancellable>()
        private var nodeMap = Dictionary<ObjectId, SCNNode>()
        var nodeInteraction: BasicNodeInteraction!
        var planes = Set<SCNNode>()
        var rootNodeTransform: QSRootNodeTransform? = nil
        let settings: QSSettings
        var selectedNode: SCNNode? = nil
        
        init(parent: ARScene, sceneVM: LocationSceneViewModel, readonly: Bool = false, settings: QSSettings? = nil) {
            self.parent = parent
            self.sceneVM = sceneVM
            self.readonly = readonly
            self.settings = settings ?? QSSettings()
            self.rootNodeTransform = sceneVM.rootNodeTransform
            super.init()
            nodeInteraction = BasicNodeInteraction()
            nodeInteraction.delegate = self
        }
        
        deinit {
            print("ARScene Coordinator deinit")
        }
    }
}

//MARK: - SceneVM integration
extension ARScene.Coordinator {
    
    func initNodeEventListener(){
        sceneVM.$nodeEvent
            .subscribe(on: RunLoop.main)
        // .removeDuplicates()
            .sink { [unowned self] event in
                if let safeEvent = event {
                    switch safeEvent {
                    case .list(nodes: let nodes):
                        self.handleAddNode(nodes: nodes)
                    case .added(node: let node):
                        self.handleAddNode(node: node)
                    case .deleted(node: let node):
                        self.handleDeleteNode(node)
                    case .updated(node: let node):
                        self.handleUpdateNode(node)
                    default:
                        break
                    }
                }
            }
            .store(in: &cancellables)
        
        /// handle particles for selected nodes
        sceneVM.$selectedNode
            .subscribe(on: RunLoop.main)
            .removeDuplicates()
            .sink{ [weak self] qsNode in
                self?.removeSelectedParticles(self?.selectedNode)
                let currNode = self?.scnNodeFor(qsNode: qsNode)
                self?.addSelectedParticles(self?.scnNodeFor(qsNode: qsNode))
                self?.selectedNode = currNode
            }
            .store(in: &cancellables)
    }
    
    private func handleAddNode(node: QSNode? = nil, nodes: [QSNode]? = nil){
        if let safeNode = node {
            addNodeToParent(safeNode)
        } else if let safeNodes = nodes {
            for node in safeNodes {
                addNodeToParent(node)
            }
        }
    }
    
    /// add node to given parent, by default to modelRoot
    private func addNodeToParent(_ node: QSNode, parent: SCNNode? = nil){
        let scnNode = getNode(node)
        if let safeScnNode = scnNode {
            let parentNode = parent ?? modelRoot
            nodeMap[node._id] = safeScnNode
            parentNode.addChildNode(safeScnNode)
            safeScnNode.applyNodeTransform(node: node)
        }
    }
    
    private func getNode(_ node: QSNode) -> SCNNode? {
        if let safeAsset = node.asset {
            if safeAsset.shape != nil {
                return getShapeNode(node)
            } else if AssetManager.isAppAsset(assetId: node.assetId) {
                return getAppNode(node)
            }
        }
        return nil
    }
    
    private func handleDeleteNode(_ node: QSNode){
        let scnNode = nodeMap[node._id]
        scnNode?.removeFromParentNode()
        nodeMap.removeValue(forKey: node._id)
        if selectedNode == scnNode {
            selectedNode = nil
        }
    }
    
    private func handleUpdateNode(_ node: QSNode){
        if node.asset?.shape != nil {
            updateShapeNode(node, nodeMap[node._id]!)
        }
    }
    
    private func getAppNode(_ node: QSNode) -> SCNNode? {
        if let appNodeName = node.assetId {
            let scnNode = AssetManager.nodeForAsset(assetId: appNodeName)
            scnNode?.scale = SCNVector3(ARSceneConstants.appModelScale, ARSceneConstants.appModelScale, ARSceneConstants.appModelScale)
            scnNode?.position = SCNVector3(0, 0, -0.5)
            return scnNode
        }
        return nil
    }
    
    private func getShapeNode(_ node: QSNode) -> SCNNode? {
        switch node.asset?.shape {
        case .text:
            return getTextNode(node)
        case .sphere:
            return getSphereNode(node)
        case .box:
            return getBoxNode(node)
        default:
            return nil
        }
    }
    
    private func getTextNode(_ node: QSNode) -> SCNNode {
        let text = SCNText(string: node.text ?? defaultText, extrusionDepth: 1.0)
        if let safeColor = node.color {
            text.firstMaterial?.diffuse.contents = UIColor(safeColor)
        } else {
            text.firstMaterial?.diffuse.contents = UIColor.blue
        }
        let textNode = SCNNode(geometry: text)
        textNode.position = SCNVector3(0, 0, -0.5)
        textNode.scale = SCNVector3(ARSceneConstants.textModelScale, ARSceneConstants.textModelScale, ARSceneConstants.textModelScale)
        return textNode
    }
    
    private func getSphereNode(_ node: QSNode) -> SCNNode {
        let sphere = SCNSphere(radius: 0.2)
        sphere.firstMaterial?.diffuse.contents = UIColor.blue
        sphere.firstMaterial?.name = "Color"
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.position = SCNVector3(0, 0, -0.5)
        return sphereNode
    }
    
    private func getBoxNode(_ node: QSNode) -> SCNNode {
        let box = SCNBox(width: 0.3, height: 0.3, length: 0.3, chamferRadius: 0)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.blue
        box.materials = [material]
        let boxNode = SCNNode(geometry: box)
        boxNode.position = SCNVector3(0, 0, -0.5)
        return boxNode
    }
    
    /// update scene node with attributes (text or color)
    private func updateShapeNode(_ node: QSNode, _ scnNode: SCNNode) {
        switch node.asset?.shape {
        case .text:
            if let textGeometry = scnNode.geometry as? SCNText {
                textGeometry.string = node.text
                if let safeColor = node.color {
                    textGeometry.firstMaterial?.diffuse.contents = UIColor(safeColor)
                }
            }
        default:
            return
        }
    }
    
    private func qsNodeFor(scnNode: SCNNode?) -> QSNode? {
        if let interactableNode = interactableNode(for: scnNode),
           let mapItem = nodeMapItem(for: interactableNode){
            return sceneVM.nodes?.first{$0._id == mapItem.key}
        }
        return nil
    }
    
    private func nodeMapItem(for node: SCNNode) -> (key: ObjectId, value: SCNNode)? {
        return nodeMap.first (where: { (_, value: SCNNode) in value === node})
    }
    
    private func scnNodeFor(qsNode: QSNode?) -> SCNNode? {
        guard let objectId = qsNode?._id else {
            return nil
        }
        return nodeMap[objectId]
    }
    
    private func setRootTransform(_ transform: QSRootNodeTransform, node: SCNNode? = nil) {
        let rootNode = node ?? modelRoot
        /// no change in x sign
        rootNode.position.x = Float(transform.position.x)
        /// positive z is for south, in root transform positive y is in front
        rootNode.position.z = -Float(transform.position.y)
    }
    
    private func setRootRotation(_ transform: QSRootNodeTransform, node: SCNNode? = nil) {
        // not needed with .gravityAndHeading
        let rootNode = node ?? modelRoot
        print(transform.northRotation, rootNode.eulerAngles.y)
        rootNode.eulerAngles.y = Float(transform.northRotation)
    }
    
    private func createRootNode() -> SCNNode {
        if settings.rootNodeVisible {
            let sphere = SCNSphere(radius: 0.1)
            sphere.materials[0].diffuse.contents = UIColor.yellow
            return SCNNode(geometry: sphere)
        } else {
            let node = SCNNode()
            node.renderingOrder = -1
            return node
        }
    }
    
    private func createSelectedParticle(geometry: SCNGeometry? = nil) -> SCNParticleSystem {
        let particles = SCNParticleSystem(named: "particle.scnp", inDirectory: "Objects.scnassets")!
        // trail.particleColor = color
        if let safeGeometry = geometry {
            particles.emitterShape = safeGeometry
        }
        return particles
    }
    
    private func addSelectedParticles(_ node: SCNNode?) {
        let geometryNode = node?.geometry != nil ? node : node?.firstChildWithGeometry()
        geometryNode?.addParticleSystem(createSelectedParticle(geometry: geometryNode?.geometry))
    }
    
    private func removeSelectedParticles(_ node: SCNNode?){
        let geometryNode = node?.geometry != nil ? node : node?.firstChildWithGeometry()
        if let safeParticleSystem = geometryNode?.particleSystems?[0] {
            geometryNode?.removeParticleSystem(safeParticleSystem)
        }
    }
}

//MARK: - Ar Coaching Overlay Delegate
extension ARScene.Coordinator: ARCoachingOverlayViewDelegate {
    
    func addCoaching(){
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.delegate = self
        // #if !targetEnvironment(simulator)
        coachingOverlay.session = sceneView?.session
        // #endif
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.goal = .horizontalPlane
        coachingOverlay.activatesAutomatically = true
        sceneView?.addSubview(coachingOverlay)
    }
    
    func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {
        print("coaching activated")
    }
    
    func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        print("coaching deactivated")
    }
}

//MARK: - AR Scene View Delegate
extension ARScene.Coordinator: ARSCNViewDelegate {
    
    // on find plane - find out if new plane is closer to root position, if yes attach modelRoot to it
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else {
            return
        }
        if modelRoot.parent == nil{
            planes.insert(node)
            sceneView?.scene.rootNode.addChildNode(modelRoot)
            modelRoot.worldPosition.y = planes.first!.worldPosition.y
            if let safeTransform = self.rootNodeTransform {
                if !settings.disableRootNodeTransform {
                    self.setRootTransform(safeTransform)
                }
                if !settings.disableRootNodeRotation && settings.worldAlignment != .gravityAndHeading{
                    self.setRootRotation(safeTransform)
                }
            }
            
        }
    }
    
    // on update plane - if modelRoot attached plane was updated, also upadte modelRoot position?
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else {
            return
        }
        if node == planes.first {
            modelRoot.worldPosition.y = node.worldPosition.y
        }
    }
}

//MARK: - gesture recognizer
extension ARScene.Coordinator: NodeInteractionDelegate {
    
    func addGestureRecognizers(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: nodeInteraction, action: #selector(nodeInteraction.onTapNode(recognizer:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        sceneView?.addGestureRecognizer(tapGestureRecognizer)
        if !readonly {
            let longPressGestureRecognizer = UILongPressGestureRecognizer(target: nodeInteraction, action: #selector(nodeInteraction.onLongPressNode(recognizer:)))
            sceneView?.addGestureRecognizer(longPressGestureRecognizer)
            let panGestureRecognizer = UIPanGestureRecognizer(target: nodeInteraction, action: #selector(nodeInteraction.onPanNode(recognizer:)))
            let doubleTapGestureRecognizer = UITapGestureRecognizer(target: nodeInteraction, action: #selector(nodeInteraction.onDoubleTap(recognizer:)))
            doubleTapGestureRecognizer.numberOfTapsRequired = 2
            tapGestureRecognizer.require(toFail: doubleTapGestureRecognizer)
            
            sceneView?.addGestureRecognizer(longPressGestureRecognizer)
            sceneView?.addGestureRecognizer(panGestureRecognizer)
            sceneView?.addGestureRecognizer(doubleTapGestureRecognizer)
        }
    }
    
    func translationEnded(node: SCNNode) {
        onTransformNode(node: node)
    }
    
    func rotationEnded(node: SCNNode) {
        onTransformNode(node: node)
    }
    
    func tapped(node: SCNNode) {
        if let qsNode = qsNodeFor(scnNode: node){
            sceneVM.selectedNode = qsNode
        }
    }
    
    func doubleTapped(worldPosition: SCNVector3) {
        if let selectedNode = sceneVM.selectedNode {
            if let scnNode = self.nodeMap[selectedNode._id] {
                //todo verify better solution - z coordinate might be better read for closer plane than root plane
                let alteredPosition = SCNVector3(x: worldPosition.x, y: planes.first!.worldPosition.y, z: worldPosition.z)
                scnNode.worldPosition = alteredPosition
                sceneVM.nodeEvent = .transform(
                    node: selectedNode,
                    position: QSVector(scnVector: scnNode.position)
                )
            }
        }
    }
    
    func onTransformNode(node: SCNNode){
        if let qsNode = qsNodeFor(scnNode: node){
            sceneVM.nodeEvent = .transform(
                node: qsNode,
                position: QSVector(scnVector: node.position),
                rotation: QSVector(scnVector: node.eulerAngles)
            )
        }
    }
    
    func interactableNode(for node: SCNNode?) -> SCNNode? {
        guard let safeNode = node else {
            return nil
        }
        if let mapItem = nodeMapItem(for: safeNode) {
            return mapItem.value
        } else {
            for (_, node) in nodeMap {
                if let _ = node.childNode(withName: safeNode.name ?? "", recursively: true) {
                    return node
                }
            }
            return nil
        }
    }
}
