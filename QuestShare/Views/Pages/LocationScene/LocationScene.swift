//
//  QuestPointEdit.swift
//  QuestShare
//
//  Created by Karol Wojtas on 30/04/2021.
//

import SwiftUI
import RealmSwift

struct LocationScene: View {
    var location: QSLocation
    @Environment(\.dismiss) var dismiss
    @State var galleryOpen = false
    @State var initAsync = false
    @State var nodeAddOpen = false
    @State var editedNode: QSNode?
    @State var confirmSaveOpen = false
    let list: [String] = []
    @StateObject var vm = LocationSceneViewModel()
    @EnvironmentObject var settingsVM: SettingsViewModel
    @Environment(\.readonly) var readonly
    var nodeGalleryHeight: CGFloat = 300.0
    
    var body: some View {
        ZStack (alignment: .bottom){
            if !vm.distanceToLarge && vm.rootNodeTransform != nil {
                ARScene(sceneVM: vm, readonly: readonly)
            }            
            VStack {
                if settingsVM.rootNodeStatus {
                    RootNodeStatus(rootNodeTransform: vm.rootNodeTransform)
                }
                Spacer()
                if initAsync {
                    sceneHUD
                }
            }
            if vm.distanceToLarge {
                LocationIndicator(distance: vm.distance, horizontalAccuracy: vm.currentLocation?.horizontalAccuracy)
                    .animation(.easeIn, value: vm.distanceToLarge)
            }
        }
        .onUIKitAppear(perform: prepareState)
        .onDisappear(){
            vm.onDisappear()
        }
        .frame(height: .infinity)
        .sheet(item: $editedNode) { node in
            NodeEdit(node: node){attrs in
                vm.updateNodeAttributes(node, attrs: attrs)
                editedNode = nil
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    vm.cancelWorkspace()
                    dismiss()
                }){
                    Image(systemName: "arrow.uturn.backward.circle")
                }
                .readonlyHide()
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("save"){
                    confirmSaveOpen = true
                }
                .readonlyHide()
            }
        }
        .alert("workspace-save-prompt", isPresented: $confirmSaveOpen) {
            Button("save"){
                vm.saveWorkspace()
                confirmSaveOpen = false
                dismiss()
            }
            Button("cancel"){
                confirmSaveOpen = false
            }
        }
    }
    
    var sceneHUD: some View {
        VStack {
            HStack {
                Spacer()
                CircleButton(icon: "plus", size: .medium, color: .purple){
                    nodeAddOpen.toggle()
                }
                .readonlyHide()
                .sheet(isPresented: $nodeAddOpen){
                    NodeAdd(open: $nodeAddOpen, onChoose: { asset in
                        addNewNode(asset: asset)
                    })
                }
            }
            .animation(ExpandableWithHandleConstants.mainAnimation, value: galleryOpen)
            .padding(8.0)
            ExpandableWithHandle(isOpen: $galleryOpen, maxHeight: CGFloat(nodeGalleryHeight), width: .infinity) {
                NodeGallery(
                    sceneVM: vm,
                    itemHeight: nodeGalleryHeight,
                    editMode: !readonly,
                    onEdit: { node in
                        editedNode = node
                    })
                    .animation(.interactiveSpring(), value: galleryOpen)
            }
        }
    }
    
    func addNewNode(asset: QSNodeAsset){
        vm.addNode(QSNode(), asset: asset)
    }
    
    private func prepareState(){
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            initAsync = true
        }
        vm.locationId = location._id
        vm.settings = settingsVM.snapshot
        vm.readonly = readonly
        vm.onAppear()
    }
}

struct LocationSceneEdit_Previews: PreviewProvider {
    @State static var presented = false
    static var previews: some View {
        LocationScene(location: QSLocation(name: "Test", desc: "Test"))
            .environmentObject(LocationManager())
    }
}
