//
//  CollectionListItem.swift
//  QuestShare
//
//  Created by Karol Wojtas on 23/05/2021.
//

import SwiftUI

struct CollectionListItem: View {
    var collection: QSCollection
    var body: some View {
        VStack (alignment: .leading){
            Text(collection.name)
            if let safeEmail = collection.user?.email {
                Text(safeEmail)
                    .font(.caption)
            }
        }
    }
}

struct CollectionListItem_Previews: PreviewProvider {
    static var previews: some View {
        CollectionListItem(collection: TestData.collections[0])
    }
}
