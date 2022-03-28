//
//  NodeGallery.swift
//  QuestShare
//
//  Created by Karol Wojtas on 04/05/2021.
//

import SwiftUI
import RealmSwift

struct NodeGallery: View {
    @ObservedObject var sceneVM: LocationSceneViewModel
    var itemHeight: CGFloat = 300.0
    var editMode: Bool
    var onEdit: ((QSNode) -> Void)?
    private let itemPadding = CGFloat(8.0)
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                if let safeNodes = sceneVM.nodes {
                    ForEach(safeNodes){node in
                        NodeGalleryItem(node: node,
                                        editMode: editMode,
                                        selected: sceneVM.selectedNode == node,
                                        onDelete: {
                                            sceneVM.removeNode(node)
                                        },
                                        onEdit: onEdit,
                                        onTap: onTapItem(_:))
                            .frame(height: itemHeight - (itemPadding * 2))
                    }
                }
            }
            .padding(.bottom, itemPadding)
            .padding(.horizontal, itemPadding)
        }
    }
    
    func onTapItem(_ node: QSNode) {
        sceneVM.selectedNode = sceneVM.selectedNode == node ? nil : node
    }
}

struct NodeGallery_Previews: PreviewProvider {
    static var nodes: [QSNode] = Array(1...5).map { index in
        QSNode(name: "node \(index) name", asset: QSNodeAsset(shape: .text))
    }
    static var previews: some View {
        NodeGallery(sceneVM: LocationSceneViewModel(), editMode: true)
    }
}
