//
//  LocationIndicator.swift
//  QuestShare
//
//  Created by Karol Wojtas on 25/09/2021.
//

import SwiftUI
import CoreLocation

struct LocationIndicator: View {
    var distance: Double
    var horizontalAccuracy: Double? = nil
    
    var body: some View {
        VStack (spacing: 8.0){
            Spacer()
            Text(String(format: NSLocalizedString("distance-prompt", comment: ""), LocationSceneViewModel.distanceTreshold))
                .font(.title3)
            HStack {
                if let safeHorizontalAccuracy = horizontalAccuracy {
                    Text("Dokładność:")
                        .foregroundColor(Color(UIColor.systemGray))
                    Text(Measurement(value: safeHorizontalAccuracy, unit: UnitLength.meters),
                         format: .measurement(width: .narrow))
                        .foregroundColor(Color(UIColor.systemBlue))
                    Spacer()
                }
            }
            .font(.subheadline)
            HStack {
                Spacer()
                distanceText
                    .font(.title)
                    .background(TextHighlight())
                Spacer()
            }
            Spacer()
        }
        .padding(.horizontal, 8.0)
        .background(Color(UIColor.systemBackground))
        .edgesIgnoringSafeArea(.bottom)
    }
    
    var distanceText: Text {
        let (distance, unit) = distance >= 1000 ? (distance / 1000, UnitLength.kilometers) : (distance, UnitLength.meters)
        return Text(Measurement(value: distance, unit: unit), format: .measurement(width: .narrow))
    }
}

struct LocationIndicator_Previews: PreviewProvider {
    static var previews: some View {
        LocationIndicator(distance: 0.0, horizontalAccuracy: 5.0)
            .preferredColorScheme(.dark)
    }
}
