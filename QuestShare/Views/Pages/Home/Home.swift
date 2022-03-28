//
//  Home.swift
//  QuestShare
//
//  Created by Karol Wojtas on 22/05/2021.
//

import SwiftUI
import RealmSwift

struct Home: View {
    @StateObject var vm = HomeViewModel()
    @State var authOpen = false
    
    var body: some View {
        NavigationView{
            VStack{
                Text("welcome-header")
                    .font(.largeTitle)
                    .background(TextHighlight())
                List {
                    if let safeCollections = vm.collections {
                        ForEach(safeCollections, id: \._id){ collection in
                            NavigationLink(
                                destination: CollectionView(collection: collection)
                                    .environment(
                                        \.readonly,
                                         collection.user?.uid != nil && collection.user?.uid != vm.user?.uid
                                    )) {
                                        CollectionListItem(collection: collection)
                                    }
                                    .swipeActions {
                                        Button(role: .destructive) {
                                            vm.deleteCollection(collection)
                                        } label : {Label("Delete", systemImage: "trash")}
                                        if collection.user?.uid == vm.user?.uid {
                                            Button {vm.uploadCollection(collection)}
                                            label : {Label("Upload", systemImage: "square.and.arrow.up")}
                                        }
                                    }
                            
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {authOpen = true}){
                        Image(systemName: vm.user != nil ? "person.fill" : "person")
                    }
                    .sheet(isPresented: $authOpen){
                        AuthPage(userVM: vm)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(
                        destination: CollectionView(collection: nil, editMode: true)
                    ) {
                        Image(systemName: "plus")
                            .font(.system(size: 20))
                    }
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    Spacer()
                    NavigationLink(destination: CollectionSearch(dbManager: vm.dbManager)){
                        Image(systemName: "magnifyingglass.circle.fill")
                            .font(.system(size: 20))
                    }
                }
            }
            .onAppear{
                vm.dbManager = FirebaseManager()
                vm.onAppear()
                AssetManager.bootstrapRealm()
            }
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
