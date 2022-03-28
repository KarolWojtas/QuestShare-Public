//
//  UserViewModel.swift
//  QuestShare
//
//  Created by Karol Wojtas on 23/09/2021.
//

import Foundation
import Combine
import Firebase

class UserViewModel: ObservableObject, ViewModelLifecycle {
    @Published var user: QSUser?
    private var authStateListener: AuthStateDidChangeListenerHandle?
    
    func onAppear() {
        authStateListener = Auth.auth().addStateDidChangeListener{ [weak self] auth, user in
            if let safeUser = user {
                self?.user = QSUser(of: safeUser)
            } else {
                self?.user = nil
            }
        }
    }
    
    func onDisappear() {
        
    }
    
    deinit {
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }
}
