//
//  QSNodeEvent.swift
//  QuestShare
//
//  Created by Karol Wojtas on 31/08/2021.
//

import Foundation

enum QSNodeEvent: Equatable {    
    case list(nodes: [QSNode])
    case deleted(node: QSNode)
    case added(node: QSNode)
    case updated(node: QSNode)
    case transform(node: QSNode, position: QSVector? = nil, rotation: QSVector? = nil)
    
    var isTransform: Bool {
        if case .transform(node: _) = self {
            return true
        } else {
            return false
        }
    }
}
