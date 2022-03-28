//
//  QSRootNodeTransform.swift
//  QuestShare
//
//  Created by Karol Wojtas on 24/10/2021.
//

import Foundation
import CoreLocation

struct QSVector2: Equatable {
    var x: Double = 0.0
    var y: Double = 0.0
    
    static var zero: QSVector2 {
        QSVector2()
    }
}
struct QSRootNodeTransform: Equatable {
    var position: QSVector2 = .zero
    var heading: Double = 0.0
    var bearing: Double = 0.0
    var distance: Double = 0.0
    var coordinate: CLLocationCoordinate2D?
    
    /// deprecated since using .gravityAndHeading
    var northRotation: Double {
           if abs(heading) == 90.0 || heading == 180.0{
               return heading
           } else {
               return (180.signFrom(heading)) - heading
           }
       }
}
