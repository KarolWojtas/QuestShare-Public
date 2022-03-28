//
//  QSCoordinate.swift
//  QuestShare
//
//  Created by Karol Wojtas on 22/05/2021.
//

import Foundation
import RealmSwift

class QSCoordinate: EmbeddedObject {
    @Persisted var longitude: Double = 0.0
    @Persisted var latitude: Double = 0.0
    convenience init(latitude: Double, longitude: Double) {
        self.init()
        self.latitude = latitude
        self.longitude = longitude
    }
    
    func clone() -> QSCoordinate {
        QSCoordinate(latitude: self.latitude, longitude: self.longitude)
    }
}

extension QSCoordinate {
    override var description: String {
        String(format: "%.3f\u{00B0}, %.3f\u{00B0}", self.latitude, self.longitude)
    }
}
