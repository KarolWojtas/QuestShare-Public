//
//  SelectedLocation.swift
//  QuestShare
//
//  Created by Karol Wojtas on 10/07/2021.
//

import SwiftUI

struct SelectedLocation: View {
    var location: QSLocation
    var editMode: Bool
    var onEdit: (() -> Void)?
    @State private var locationScenePresented = false
    @State private var locationSceneReadonly = false
    @Environment(\.readonly) var readonly
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(location.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .background(TextHighlight())
                Spacer()
                if editMode {
                    Button("edit"){
                        if let safeOnEdit = onEdit {
                            safeOnEdit()
                        }
                    }
                }
            }
            if let safeCoordinate = location.coordinate {
                Text(safeCoordinate.description)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            if let safeDesc = location.desc {
                Text(safeDesc)
            }
            if !editMode {
                Divider()
                    .background(Color.white)
                Text("ar-scene")
                    .fontWeight(.medium)
                Text(location.workspace == nil ? "ar-scene-new-prompt" : "ar-scene-continue-prompt")
                    .font(.caption)
                HStack (alignment: .center){
                    Spacer()
                    actions
                    Spacer()
                }
            }
        }
    }
    
    private var actions: some View {
        var buttons: [Button<Text>] = [
            Button("ar-scene-view"){
                locationSceneReadonly = true
                locationScenePresented = true
            }
        ]
        if !readonly {
            buttons.append(
                Button(location.workspace != nil ? "ar-scene-continue" : "ar-scene-new"){
                    locationSceneReadonly = false
                    locationScenePresented = true
                }
            )
        }
        return HStack {
            ButtonGroup(buttons)
            NavigationLink(
                destination: LocationScene(location: location)
                    .environment(\.readonly, locationSceneReadonly),
                isActive: $locationScenePresented
            ){
                EmptyView()
            }
        }
    }
    
}

struct SelectedLocation_Previews: PreviewProvider {
    static var previews: some View {
        SelectedLocation(location: QSLocation(name: "Airport", desc: "Heathrow"), editMode: false)
    }
}
