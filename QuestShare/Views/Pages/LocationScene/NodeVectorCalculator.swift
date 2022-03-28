//
//  NodeVectorCalculator.swift
//  QuestShare
//
//  Created by Karol Wojtas on 25/10/2021.
//

import Foundation
import CoreLocation
import ARKit

extension CLLocationCoordinate2D: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
    }
    
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

struct NodeVectorCalculator {
    let target: CLLocationCoordinate2D
    let worldAlignment: ARConfiguration.WorldAlignment
    var originTransform: QSRootNodeTransform?
    private var resultMap: Dictionary<CLLocationCoordinate2D, QSRootNodeTransform> = [:]
    private let deltaRange = -180.0...180.0
    private let quarterRange = -90.0...90.0
    
    init(_ target: QSCoordinate?, _ worldAlignment: ARConfiguration.WorldAlignment?){
        self.target = CLLocationCoordinate2D(latitude: target?.latitude ?? 0, longitude: target?.longitude ?? 0)
        self.worldAlignment = worldAlignment ?? .gravityAndHeading
    }
    
    mutating func submit(location: CLLocation, heading: CLHeading) -> QSRootNodeTransform {
        let result = calculate(location, heading)
        return result
    }
    
    mutating func calculate(_ location: CLLocation, _ heading: CLHeading) -> QSRootNodeTransform {
        let bearing = location.coordinate.bearingTo(target)
        let distance = location.distance(from: target)
        let signedHeading = signedDegree(heading.trueHeading)
        let (x, y) = vectorFor(heading: signedHeading, bearing: bearing, distance: distance)
        let transform = QSRootNodeTransform(position: QSVector2(x: x, y: y), heading: signedHeading, bearing: bearing, distance: distance, coordinate: location.coordinate)
        return transform
    }
    
    func vectorFor(heading hFull: Double, bearing bFull: Double, distance: Double) -> (Double, Double) {
        let heading = signedDegree(hFull)
        let bearing = signedDegree(bFull)
        let angleDelta = worldAlignment == .gravityAndHeading
            ? signedDegree(bearing) // todo test prev angleDelta(bearing: Double)
            : angleDelta(heading: heading, bearing: bearing)
        let vector = vectorComponents(angleDelta, distance: distance)
        return vector
    }
    
    /// worldAlignment.gravity
    internal func angleDelta(heading: Double, bearing: Double) -> Double {
        let angleDelta = bearing - heading
        return signedDegree(angleDelta)
    }
    
    /// convert degrees to range <-180, 180>
    internal func signedDegree(_ value: Double) -> Double {
        let mod = abs(value).truncatingRemainder(dividingBy: 360.0)
        let moddedValue = mod.signFrom(value)
        if !deltaRange.contains(moddedValue){
            return moddedValue > 180 ? moddedValue - 360 : 360 + moddedValue
        } else {
            return moddedValue
        }
    }
    
    internal func vectorComponents(_ angleDelta: Double, distance: Double) -> (Double, Double) {
        if quarterRange.contains(angleDelta){
            let x = distance * sin(angleDelta.radians)
            let y = distance * cos(angleDelta.radians)
            return (x, y)
        } else {
            let quarterCorrection = 90.0.signFrom(angleDelta);
            let qAngleDelta = angleDelta - quarterCorrection
            let x = distance * cos(qAngleDelta.radians)
            let y = distance * sin(qAngleDelta.radians)
            /// x sign variable, y in this case always negative
            return (x.signFrom(angleDelta), y.negative)
        }
    }
}

extension Double {
    func signFrom(_ other: Double) -> Double {
        let result = other < 0.0 ? -abs(self) : abs(self)
        return result
    }
    
    var negative: Double {
        -abs(self)
    }
}
