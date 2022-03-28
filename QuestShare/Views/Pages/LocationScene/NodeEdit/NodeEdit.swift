//
//  NodeEdit.swift
//  QuestShare
//
//  Created by Karol Wojtas on 17/08/2021.
//

import SwiftUI

struct NodeEdit: View {
    var node: QSNode
    @State private var text: String = ""
    @State var onSave: ((NodeEditAttributes) -> Void)?
    @State private var color = Color.blue
    var body: some View {
        VStack {
            Text("edit-node")
                .modalTitle()
            if let safeAsset = node.asset {
                NodeAssetImage(asset: safeAsset)
                    .frame(width: 200)
            }
            Text(node.name)
            VStack{
                if node.asset?.shape == .text {
                    FormInputField(name: "text-node-form-name", value: $text, disabled: false, prompt: nil, type: .editor)
                        .frame(maxHeight: 200.0)
                }
                ColorPicker("color", selection: $color)
            }
            .padding()
            Spacer()
            ButtonGroup([
                Button("save"){
                    if let safeOnSave = onSave {
                        safeOnSave(NodeEditAttributes(text: text, color: color))
                    }
                }
            ])
        }
        .onAppear{
            text = node.text ?? ""
            if let safeColor = node.color {
                color = safeColor
            }
        }
    }
}

struct NodeEdit_Previews: PreviewProvider {
    static var previews: some View {
        NodeEdit(node: QSNode(name: "name", asset: QSNodeAsset(shape: .text)))
    }
}

struct NodeEditAttributes {
    let text: String?
    let color: Color?
}
