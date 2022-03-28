//
//  LocationList.swift
//  QuestShare
//
//  Created by Karol Wojtas on 10/07/2021.
//

import SwiftUI

struct LocationList: View {
    @ObservedObject var collectionVM: CollectionViewModel
    var editMode: Bool
    @Binding var show: Bool
    var body: some View {
        List {
            ForEach(collectionVM.locations, id: \._id){location in
                LocationListItem(location: location, editMode: editMode)
                    .padding(.vertical, 8)
                    .onTapGesture {
                        collectionVM.selectedLocation = location
                        show = false
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            collectionVM.deleteLocation(location)
                        } label : {Label("Delete", systemImage: "trash")}
                        .readonlyHide()
                    }
            }
        }
        .padding()
    }
}

struct LocationList_Previews: PreviewProvider {
    @StateObject static var vm = CollectionViewModel()
    @State static var show = true
    static var previews: some View {
        LocationList(collectionVM: vm, editMode: true, show: $show)
            .onAppear(){
                vm.locations = [
                    QSLocation(name: "test name", desc: "test desc")
                ]
            }
    }
}
