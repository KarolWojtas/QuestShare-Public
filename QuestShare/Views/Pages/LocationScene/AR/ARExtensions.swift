//
//  ARExtensions.swift
//  QuestShare
//
//  Created by Karol Wojtas on 31/08/2021.
//

import Foundation
import SceneKit

//MARK: - SCNNode extensions
extension SCNNode {
    func applyNodeTransform(node: QSNode){
        if let safePosition = node.position {
            if !safePosition.equal(to: self.position) {
                position = SCNVector3(x: safePosition.x, y: safePosition.y, z: safePosition.z)
            }
        }

        // TODO disable scale for now
//        if !node.scale.isEqual(scale) {
//            scale = SCNVector3(x: node.scale.x, y: node.scale.y, z: node.scale.z)
//        }

        if let safeRotation = node.rotation {
            eulerAngles = SCNVector3(x: safeRotation.x, y: safeRotation.y, z: safeRotation.z)
        }
        
    }
    
    func firstChildWithGeometry() -> SCNNode? {
        return searchChildWithGeometry(childNodes)
    }
    
    private func searchChildWithGeometry(_ nodes: [SCNNode]) -> SCNNode? {
        if let child = nodes.first(where: {$0.geometry != nil}) {
            return child
        } else {
            let flatChildren: [SCNNode] = nodes.flatMap {$0.childNodes}
            return searchChildWithGeometry(flatChildren)
        }
    }
}
