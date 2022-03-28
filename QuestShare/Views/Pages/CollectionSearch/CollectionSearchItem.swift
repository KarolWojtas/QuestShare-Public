//
//  CollectionSearchItem.swift
//  QuestShare
//
//  Created by Karol Wojtas on 02/10/2021.
//

import SwiftUI

struct CollectionSearchItem: View {
    var item: QSCollection
    var owned = false
    var stored: QSCollection?
    
    var body: some View {
        HStack {
            VStack (alignment: .leading) {
                Text(item.name)
                if let safeEmail = item.user?.email {
                    Text(safeEmail)
                        .font(.caption)
                }
                if let safeName = item.user?.displayName {
                    Text(safeName)
                        .font(.caption)
                }
            }
            Spacer()
            HStack {
                Spacer()
                if let safeStored = stored {
                    if owned {
                        Image(systemName: "square.and.arrow.up.circle")
                            .foregroundColor(safeStored.editedSeconds > item.editedSeconds ? .yellow : .green)
                            .font(.system(size: 20))
                    }
                    Image(systemName: "iphone.circle")
                        .foregroundColor(safeStored.edited < item.edited ? .yellow : .green)
                        .font(.system(size: 20))
                }
            }
        }
    }
}

struct CollectionSearchItem_Previews: PreviewProvider {
    static var previews: some View {
        CollectionSearchItem(item: QSCollection())
    }
}
