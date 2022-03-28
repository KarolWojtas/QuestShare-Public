//
//  LocationAdd.swift
//  QuestShare
//
//  Created by Karol Wojtas on 25/05/2021.
//

import SwiftUI

struct LocationAdd: View {
    var locations: [QSLocation]
    var editedLocation: LocationAddParams?
    @StateObject var basicDataVM = BasicDataViewModel()
    @StateObject var viewModel = LocationAddViewModel()
    var onSave: ((QSLocation, Bool) -> Void)? = nil
    @EnvironmentObject var locationManager: LocationManager
    
    var body: some View {
        VStack {
            header
                .modalTitle()
            TabView {
                LocationMap(annotations: $viewModel.annotations,
                            locationManager: locationManager,
                            editedLocation: editedLocation?.value)
                    .tabItem {
                        Label(LocalizedStringKey("map"), systemImage: "map.fill")
                    }
                VStack {
                    BasicObjectDataForm(
                        disabled: false,
                        name: $basicDataVM.name,
                        desc: $basicDataVM.desc,
                        namePrompt: basicDataVM.namePrompt
                    )
                    .padding()
                }
                .padding(.horizontal, 8)
                .tabItem {
                    Label(LocalizedStringKey("data"), systemImage: "text.redaction")
                }
                .tabViewStyle(PageTabViewStyle())
            }
            HStack {
                Button("save"){
                    if let safeOnSave = onSave {
                        let (loc, added) = viewModel.locationChanges(name: basicDataVM.name, desc: basicDataVM.desc)
                        safeOnSave(loc, added)
                    }
                }
                .padding(.horizontal)
                .disabled(!basicDataVM.isNameValid)
            }.padding()
        }
        .onAppear(){
            prepareState()
        }
        .onDisappear(){
            viewModel.onDisappear()
        }
    }
    
    var header: Text {
        let headerTextKey = editedLocation?.value == nil ? "add-location" : "edit-location"
        return Text(LocalizedStringKey(headerTextKey))
    }
    
    func prepareState(){
        if let safeEditedLoc = editedLocation?.value {
            basicDataVM.name = safeEditedLoc.name
            basicDataVM.desc = safeEditedLoc.desc ?? ""
        }
        viewModel.locations = locations
        viewModel.editedLocation = editedLocation?.value
        viewModel.onAppear()
    }
}

struct LocationAdd_Previews: PreviewProvider {
    @State static var edited: LocationAddParams? = LocationAddParams(QSLocation())
    static var previews: some View {
        LocationAdd(locations: [], editedLocation: edited)
            .environmentObject(LocationManager())
    }
}

struct LocationAddParams: Identifiable {
    var id: UUID = UUID()
    var value: QSLocation?
    init(_ location: QSLocation?) {
        value = location
    }
}
