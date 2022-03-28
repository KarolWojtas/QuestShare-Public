//
//  CollectionSearch.swift
//  QuestShare
//
//  Created by Karol Wojtas on 02/10/2021.
//

import SwiftUI

struct CollectionSearch: View {
    var dbManager: ServerDatabaseManager?
    @StateObject var vm = CollectionSearchViewModel()
    var body: some View {
        VStack {
            List(vm.results){ collection in
                CollectionSearchItem(
                    item: collection,
                    owned: collection.user?.uid == vm.user?.uid,
                    stored: vm.matchDict[collection]
                )
                    .swipeActions {
                        Button {vm.storeCollection(collection)}
                        label : {Label("Save", systemImage: "square.and.arrow.down")}
                    }
            }
            .searchable(text: $vm.query)
        }
        .onAppear{
            vm.dbManager = dbManager
            vm.onAppear()
        }
        .onDisappear{
            vm.onDisappear()
        }
    }
}

struct CollectionSearch_Previews: PreviewProvider {
    static var previews: some View {
        CollectionSearch(dbManager: EmptyDbManager())
    }
}
