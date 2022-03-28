//
//  QSUser.swift
//  QuestShare
//
//  Created by Karol Wojtas on 23/09/2021.
//

import Foundation
import RealmSwift
import Firebase

protocol QSUserModel {
    var email: String {get set}
    var displayName: String? {get set}
    var uid: String {get set}
}

class QSUser: EmbeddedObject, QSUserModel {
    @Persisted var email = ""
    @Persisted var displayName: String?
    @Persisted var uid = ""
    
    convenience init(of user: FirebaseAuth.User){
        self.init()
        self.email = user.email ?? ""
        self.uid = user.uid
        self.displayName = user.displayName
    }
    
    convenience init(email: String, displayName: String? = nil){
        self.init()
        self.email = email
        self.displayName = displayName
    }
}
