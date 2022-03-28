//
//  QSUserDto.swift
//  QuestShare
//
//  Created by Karol Wojtas on 10/10/2021.
//

import Foundation
import FirebaseAuth

struct QSUserDto: Codable, QSUserModel {
    var email = ""
    var displayName: String?
    var uid = ""
    
    init(model: QSUser){
        self.email = model.email
        self.displayName = model.displayName
        self.uid = model.uid
    }
    
    init(of user: FirebaseAuth.User) {
        self.email = user.email ?? ""
        self.uid = user.uid
        self.displayName = user.displayName
    }
}

extension QSUser {
    convenience init(dto: QSUserDto){
        self.init()
        self.email = dto.email
        self.displayName = dto.displayName
        self.uid = dto.uid
    }
}
