//
//  ContentView.swift
//  QuestShare
//
//  Created by Karol Wojtas on 30/04/2021.
//

import SwiftUI
import RealmSwift
import Firebase
import FirebaseFunctions

struct ContentView: View {
    var firebaseEmulators = false
    let settingsVM = SettingsViewModel()
    var body: some View {
        Home()
            .environment(\.locale, .init(identifier: "pl"))
            .environmentObject(settingsVM)
            .onAppear(){
                setupRealm()
                print(Realm.Configuration.defaultConfiguration.fileURL?.absoluteString ?? "")
                FirebaseApp.configure()
                if firebaseEmulators {
                     setupLocalEmulators()
                }
                settingsVM.onAppear()
            }
    }
    
    func setupRealm(){
        let config = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
        Realm.Configuration.defaultConfiguration = config
    }
    
    func setupLocalEmulators(){
        let settings = Firestore.firestore().settings
        settings.host = "localhost:8080"
        settings.isPersistenceEnabled = false
        settings.isSSLEnabled = false
        Firestore.firestore().settings = settings
        Auth.auth().useEmulator(withHost:"localhost", port:9099)
        Functions.functions().useEmulator(withHost: "localhost", port: 5001)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
