//
//  QSBaseObject.swift
//  QuestShare
//
//  Created by Karol Wojtas on 22/05/2021.
//

import Foundation
import RealmSwift

protocol QSBaseObjectModel {
    var name: String { get set }
    var desc: String? { get set }
}

class QSBaseObject: Object, QSBaseObjectModel, ObjectKeyIdentifiable, Codable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var name: String = ""
    @Persisted var desc: String? = nil
    
    convenience init(name: String, desc: String? = nil) {
        self.init()
        self.name = name
        self.desc = desc
    }
}
