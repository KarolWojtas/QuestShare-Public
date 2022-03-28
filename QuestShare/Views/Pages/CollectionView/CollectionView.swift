//
//  CollectionView.swift
//  QuestShare
//
//  Created by Karol Wojtas on 22/05/2021.
//

import SwiftUI
import RealmSwift
import Combine
import FirebaseAuth

struct CollectionView: View {
    var collection: QSCollection?
    @State var editMode = false
    @State private var showLocationList = false
    @State private var editedLocation: LocationAddParams? = nil
    @State private var visible = false
    @Environment(\.readonly) var readonly
    
    @StateObject private var basicDataVM = BasicDataViewModel()
    @StateObject private var collectionVM = CollectionViewModel()
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    BasicDataTitle(name: $basicDataVM.name, desc: $basicDataVM.desc, editMode: editMode)
                    HStack {
                        Text("locations")
                            .font(.title2)
                            .fontWeight(.medium)
                        Spacer()
                        Button("list"){
                            showLocationList.toggle()
                        }
                        if editMode {
                            Button(action: {
                                toggleLocationEdit(true)
                            }){
                                Image(systemName: "plus")
                                    .font(.system(size: 20))
                            }
                        }
                    }
                    .padding(.horizontal)
                    .sheet(isPresented: $showLocationList){
                        LocationList(collectionVM: collectionVM, editMode: editMode, show: $showLocationList)
                            .environmentObject(locationManager)
                    }
                    .sheet(item: $editedLocation) {loc in
                        LocationAdd(locations: collectionVM.locations,
                                    editedLocation: loc){newLoc, added in
                            collectionVM.saveLocation(location: newLoc, added: added)
                            toggleLocationEdit(false)
                        }
                                    .environmentObject(locationManager)
                    }
                    if visible {
                        CollectionMap(locationManager: locationManager, collectionVM: collectionVM)                       .frame(height: 350)
                            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 8, height: 8)))
                        
                    }
                    VStack(alignment: .leading) {
                        if let safeSelectedLocation = collectionVM.selectedLocation {
                            SelectedLocation(location: safeSelectedLocation, editMode: editMode) {
                                toggleLocationEdit(true, with: safeSelectedLocation)
                            }
                            
                        } else {
                            Text("locationNotSelected")
                        }
                    }
                    .padding(.horizontal)
                }
                .navigationBarTitle("collection-view-header", displayMode: .inline)
                .toolbar {
                    toolbarItems
                }
                .onAppear(){
                    visible = true
                    prepareState()
                }
                .onDisappear(){
                    visible = false
                }
            }
        }
        .padding(.top, 1) // prevent flickering
        .environmentObject(locationManager)
    }
    
    var toolbarItems: ToolbarItemGroup<TupleView<(Button<Image>?, Button<Text>?)>> {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            if editMode {
                Button(action: cancelChanges){
                    Image(systemName: "arrow.uturn.backward.circle")
                }
            }
            if !readonly {
                Button(editMode ? "save" : "edit"){
                    if editMode {
                        _ = collectionVM.saveCollection(name: basicDataVM.name, desc: basicDataVM.desc)
                    }
                    withAnimation {
                        editMode = !editMode
                    }
                }
            }
        }
    }
    
    func prepareState(){
        basicDataVM.name = collection?.name ?? ""
        basicDataVM.desc = collection?.desc ?? ""
        collectionVM.collection = collection
        if let safeUser = AuthManager.currentUser() {
            collectionVM.user = safeUser
        }
        collectionVM.onAppear()
    }
    
    func releaseState() {
        collectionVM.onDisappear()
    }
    
    func deleteLocation(_ location: QSLocation) {
        withAnimation {
            collectionVM.deleteLocation(location)
        }
    }
    
    func toggleLocationEdit(_ show: Bool, with location: QSLocation? = nil){
        editedLocation = show ? LocationAddParams(location) : nil
    }
    
    func cancelChanges() -> Void{
        prepareState()
        collectionVM.selectedLocation = nil
        withAnimation {
            editMode = !editMode
        }
    }
}

struct CollectionView_Previews: PreviewProvider {
    static var previews: some View {
        CollectionView(collection: TestData.collections[0])
    }
}



