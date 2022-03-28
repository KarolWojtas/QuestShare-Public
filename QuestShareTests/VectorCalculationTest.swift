//
//  VectorCalculationTest.swift
//  QuestShareTests
//
//  Created by Karol Wojtas on 28/10/2021.
//

import XCTest
@testable import QuestShare
import CoreLocation

class VectorCalculationTest: XCTestCase {
    var sut: NodeVectorCalculator!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = NodeVectorCalculator(nil, nil)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testBearing() throws {
        let c1 = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        let c2 = CLLocationCoordinate2D(latitude: 2.0, longitude: 0.0)
        let bearing = c1.bearingTo(c2)
        XCTAssertEqual(bearing, 0);
    }
    
    func testAngleDelta() throws {
        let assertions: [(Double, Double, Double)] = [
            (0.0, 45.0, 45.0),
            (-90, -78.0, 12.0),
            (90.0, -78.0, -168.0),
            (180.0, -78.0, 102.0),
            (-50.0, 130, 180.0),
            (-63.0, 145, -152.0),
        ]
        for (heading, bearing, result) in assertions {
            XCTAssertEqual(sut.angleDelta(heading: heading, bearing: bearing), result)
        }
    }
    
    func testSignFrom(){
        XCTAssertEqual(1.signFrom(1), 1)
        XCTAssertEqual((-1).signFrom(1), 1)
        XCTAssertEqual(1.signFrom(-1), -1)
        XCTAssertEqual((1 - 2).signFrom(1), 1)
    }
    
    func testSignedDegree() throws {
        let assertions: [(Double, Double)] = [
            (180.0, 180.0),
            (90.0, 90.0),
            (270.0, -90.0),
            (-270.0, 90.0),
            (-450.0, -90.0),
            (550.0, -170.0),
            (370.0, 10.0),
        ]
        for (value, result) in assertions {
            XCTAssertEqual(sut.signedDegree(value), result)
        }
    }
    
    func testCalculate(){
        let (x, y) = sut.vectorFor(heading: -63.0, bearing: 145.0, distance: 32.0)
        print(x, y)
    }
    
    func testNorthRotation(){
        let assertions: [(Double, Double)] = [
            (-90.0, -90.0),
            (90.0, 90.0),
            (-150.0, -30.0),
            (30.0, 150.0),
            (-180.0, 0.0),
            (180.0, 180.0),
        ]
        for (heading, northRotation) in assertions {
            XCTAssertEqual(QSRootNodeTransform(heading: heading).northRotation, northRotation)
        }
    }

}
