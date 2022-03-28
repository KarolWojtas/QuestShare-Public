//
//  QSUserDto.swift
//  QuestShare
//
//  Created by Karol Wojtas on 09/10/2021.
//

import Foundation
import FirebaseFirestoreSwift

struct QSAppUserDto: Codable, QSUserModel {
    @DocumentID var id: String? = nil
    var uid: String = ""
    var displayName: String? = nil
    var email: String = ""
}
