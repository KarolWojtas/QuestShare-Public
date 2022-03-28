//
//  BasicNodeInteraction.swift
//  QuestShare
//
//  Created by Karol Wojtas on 02/09/2021.
//

import Foundation
import SceneKit
import ARKit

protocol NodeInteractionDelegate: AnyObject {
    func translationEnded(node: SCNNode)
    func rotationEnded(node: SCNNode)
    func tapped(node: SCNNode)
    func doubleTapped(worldPosition: SCNVector3)
    func interactableNode(for: SCNNode?) -> SCNNode?
}

class BasicNodeInteraction {
    
    private var localTranslatePosition: CGPoint?
    private var transformedNode: SCNNode?
    private var initialAngleY: Float = 0.0
    weak var delegate: NodeInteractionDelegate?
    
    @objc func onLongPressNode(recognizer: UIPanGestureRecognizer){
        guard let sceneView = recognizer.view as? ARSCNView else {
            return
        }
        let touchPoint = recognizer.location(in: sceneView)
        // [.boundingBoxOnly: true]
        
        switch recognizer.state {
        case .began:
            let hitTest = sceneView.hitTest(touchPoint, options: nil).first
            guard let node = delegate?.interactableNode(for: hitTest?.node) else {
                return
            }
            transformedNode = node
            localTranslatePosition = touchPoint
        case .changed:
            if let safeTranslatePosition = localTranslatePosition,
               let safeNode = transformedNode {
                let deltaX = Float((touchPoint.x - safeTranslatePosition.x) / 500)
                let deltaZ = Float((touchPoint.y - safeTranslatePosition.y) / 500)
                safeNode.localTranslate(by: SCNVector3(deltaX, 0.0, deltaZ))
                localTranslatePosition = touchPoint
            }
        case .ended,
                .cancelled,
                .failed:
            if let safeTransformedNode = transformedNode {
                delegate?.translationEnded(node: safeTransformedNode)
            }
            transformedNode = nil
            localTranslatePosition = nil
        default:
            break
        }
        
    }
    
    @objc func onPanNode(recognizer: UIPanGestureRecognizer){
        guard let sceneView = recognizer.view as? ARSCNView else {
            return
        }
        let touch = recognizer.location(in: sceneView)
        switch recognizer.state {
        case .began:
            let hitTest = sceneView.hitTest(touch, options: nil).first
            guard let node = delegate?.interactableNode(for: hitTest?.node) else {
                return
            }
            transformedNode = node
            // store starting y angle
            initialAngleY = transformedNode?.eulerAngles.y ?? 0.0
        case .changed:
            let translation = recognizer.translation(in: sceneView)
            // getting x because we are interested in left <-> right panning to rotate by y axis
            var newAngleY = Float(translation.x) * (Float) (Double.pi)/180
            newAngleY += initialAngleY
            transformedNode?.eulerAngles.y = newAngleY
            break
        case .ended,
                .cancelled,
                .failed:
            if let safeTransformedNode = transformedNode {
                delegate?.rotationEnded(node: safeTransformedNode)
            }
            transformedNode = nil
            initialAngleY = 0.0
        default:
            break
        }
    }
    
    @objc func onTapNode(recognizer: UITapGestureRecognizer){
        guard let sceneView = recognizer.view as? ARSCNView else {
            return
        }
        let touch = recognizer.location(in: sceneView)
        let hitTestOptions: [SCNHitTestOption: Any] = [.boundingBoxOnly: true]
        let hitTestResults = sceneView.hitTest(touch, options: hitTestOptions)
        if let result = hitTestResults.first {
            delegate?.tapped(node: result.node)
        }
    }
    
    @objc func onDoubleTap(recognizer: UITapGestureRecognizer){
        guard let sceneView = recognizer.view as? ARSCNView else {
            return
        }
        let touch = recognizer.location(in: sceneView)
        guard let raycastQuery = sceneView.raycastQuery(from: touch, allowing: .existingPlaneGeometry, alignment: .horizontal)
        else {
            return
        }
        if let result = sceneView.session.raycast(raycastQuery).first {
            let column = result.worldTransform.columns.3
            let vector = SCNVector3(x: column.x, y: column.y, z: column.z)
            delegate?.doubleTapped(worldPosition: vector)
        }
    }
    
    deinit {
        print("BasicNodeInteraction deinit")
    }
}
