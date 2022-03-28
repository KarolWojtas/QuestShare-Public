//
//  QSPosition.swift
//  QuestShare
//
//  Created by Karol Wojtas on 31/08/2021.
//

import Foundation
import RealmSwift
import SceneKit

protocol QSVectorModel {
    var x: Float {get set}
    var y: Float {get set}
    var z: Float {get set}
}

class QSVector: EmbeddedObject, QSVectorModel {
    @Persisted var x: Float = 0.0
    @Persisted var y: Float = 0.0
    @Persisted var z: Float = 0.0
    
    static var zero: QSVector {
        QSVector()
    }
    
    convenience init(scnVector: SCNVector3) {
        self.init()
        x = scnVector.x
        y = scnVector.y
        z = scnVector.z
    }
    
    convenience init(scnVector: SCNVector4) {
        self.init()
        x = scnVector.x
        y = scnVector.y
        z = scnVector.z
    }
    
    convenience init(x: Float = 0.0, y: Float = 0.0, z: Float = 0.0){
        self.init()
        self.x = x
        self.y = y
        self.z = z
    }
    
    func equal(to vector: SCNVector3?) -> Bool {
        if let scnVector = vector {
            return scnVector.x == x
                && scnVector.y == y
                && scnVector.z == z
        } else {
            return false
        }        
    }
    
    func copy() -> QSVector {
        let copy = QSVector()
        copy.x = self.x
        copy.y = self.y
        copy.z = self.z
        return copy
    }
}
