//
//  AuthManager.swift
//  QuestShare
//
//  Created by Karol Wojtas on 11/10/2021.
//

import Foundation
import FirebaseAuth

class AuthManager {
    private init() {}
    
    static var shared: AuthManager = {
            let instance = AuthManager()
            return instance
        }()
    static func currentUser() -> QSUser? {
        if let safeUser = Auth.auth().currentUser {
            return QSUser(of: safeUser)
        } else {
            return nil
        }
    }
}
