//
//  RootNodeStatus.swift
//  QuestShare
//
//  Created by Karol Wojtas on 24/10/2021.
//

import SwiftUI

struct RootNodeStatus: View {
    var rootNodeTransform: QSRootNodeTransform?
    let vectorFormatStyle = Measurement<UnitLength>.FormatStyle(
        width: .abbreviated,
        usage: .general,
        numberFormatStyle: .number
    )
    let degreeFormatStyle = Measurement<UnitAngle>.FormatStyle(
        width: .narrow,
        usage: .general,
        numberFormatStyle: .number
    )
    var body: some View {
        VStack {
            if let safeTransform = rootNodeTransform {
                HStack {
                    Text("x:")
                    vectorComponent(safeTransform.position.x)
                    Text("y:")
                    vectorComponent(safeTransform.position.y)
                    Text("distance:")
                    vectorComponent(safeTransform.distance)
                }
                HStack {
                    Text("bearing:")
                    degrees(safeTransform.bearing)
                    Text("heading:")
                    degrees(safeTransform.heading)
                }
            } else {
                Text("no data")
            }
        }
        .padding(4.0)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8.0))
        .font(.subheadline)
    }
    
    func vectorComponent(_ value: Double) -> Text {
        Text(Measurement(value: value, unit: UnitLength.meters), format: vectorFormatStyle)
            .foregroundColor(.blue)
    }
    
    func degrees(_ value: Double) -> Text {
        Text(Measurement(value: value, unit: UnitAngle.degrees), format: degreeFormatStyle)
            .foregroundColor(.blue)
    }
}

struct RootNodeStatus_Previews: PreviewProvider {
    static var previews: some View {
        RootNodeStatus(rootNodeTransform: QSRootNodeTransform(
            position: QSVector2(x: 1.123123, y: 1.123123),
            bearing: 45
        ))
            .environment(\.locale, Locale(identifier: "pl"))
    }
}
