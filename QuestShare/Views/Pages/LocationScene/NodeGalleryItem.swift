//
//  NodeGalleryItem.swift
//  QuestShare
//
//  Created by Karol Wojtas on 04/05/2021.
//

import SwiftUI

struct NodeGalleryItem: View {
    var node: QSNode
    var editMode = false
    var selected = false
    var onDelete: (() -> Void)?
    var onEdit: ((QSNode) -> Void)?
    var onTap: ((QSNode) -> Void)?
    
    var body: some View {
        ZStack (alignment: .topTrailing){
            VStack {
                if let safeAsset = node.asset{
                    NodeAssetImage(asset: safeAsset)
                }
                Text(node.name)
            }
            .onTapGesture {
                if let safeOnTap = onTap {
                    safeOnTap(node)
                }
            }
            if editMode {
                HStack{
                    Spacer()
                    if node.asset?.shape != nil {
                        CircleButton(icon: "pencil") {
                            if let safeOnEdit = onEdit {
                                safeOnEdit(node)
                            }
                        }
                    }                    
                    CircleButton(icon: "xmark") {
                        if let safeDelete = onDelete {
                            safeDelete()
                        }
                    }
                }
            }                        
        }
        .padding()
        .background(selected ? selectedBackground : nil)
    }
    
    var selectedBackground: some View {
        RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
            .foregroundColor(Color.purple.opacity(0.6))
    }
}

struct NodeGalleryItem_Previews: PreviewProvider {
    @State static var node = QSNode(name: "test", asset: QSNodeAsset(shape: .text))
    static var previews: some View {
        NodeGalleryItem(node: node, editMode: true, selected: true)
            .preferredColorScheme(/*@START_MENU_TOKEN@*/.dark/*@END_MENU_TOKEN@*/)
    }
}
