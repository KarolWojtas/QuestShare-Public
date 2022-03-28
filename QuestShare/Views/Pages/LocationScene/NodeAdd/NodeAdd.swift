//
//  NodeAdd.swift
//  QuestShare
//
//  Created by Karol Wojtas on 10/08/2021.
//

import SwiftUI
import RealmSwift

struct NodeAdd: View {
    @Binding var open: Bool
    @ObservedResults(QSNodeAsset.self) private var assets
    var onChoose: ((QSNodeAsset) -> Void)?
    var body: some View {
        List {
            ForEach(assets, id: \.id) { asset in
                NodeAssetImage(asset: asset)
                    .padding()
                    .onTapGesture {
                        open = false
                        if let safeOnChoose = onChoose {
                            safeOnChoose(asset)
                        }
                    }
            }
        }
    }
}

struct NodeAdd_Previews: PreviewProvider {
    @State static var open = true
    static var previews: some View {
        NodeAdd(open: $open)
    }
}
