//
//  ExpandableHandleArrow.swift
//  QuestShare
//
//  Created by Karol Wojtas on 04/05/2021.
//

import SwiftUI

struct ExpandableHandleArrow: View {
    var pointingUpward: Bool    
    
    var body: some View {
        ExpandableHandleArrowShape(tipFraction: pointingUpward ? 0 : 1, baseFraction: pointingUpward ? 1 : 0)
            .foregroundColor(.secondary)     
    }
}

struct ExpandableHandleArrow_Previews: PreviewProvider {
    @State static var state = ["upward": true]
    static var previews: some View {
        VStack {
            ExpandableHandleArrow(pointingUpward: self.state["upward"]!)
                .frame(width: 80, height: 20)            
            Button("toggle"){
                self.state["upward"]?.toggle()
            }
            Text("\(self.state["upward"]! ? "upward" : "downward")")
        }.padding()
    }
}

struct ExpandableHandleArrowShape: Shape {
        
    var tipFraction: Double = 1
    var baseFraction: Double = 0
    
    var animatableData: AnimatablePair<Double, Double> {
        get {
            AnimatablePair(tipFraction, baseFraction)
        }
        set {
            self.tipFraction = newValue.first
            self.baseFraction = newValue.second
        }
    }
    
    func path(in rect: CGRect) -> Path {
        Path { p in
            p.move(to: CGPoint(x: 0, y: rect.height * CGFloat(baseFraction)))
            p.addLine(to: CGPoint(x: rect.width / 2, y: rect.height * CGFloat(tipFraction)))
            p.addLine(to: CGPoint(x: rect.width, y: rect.height * CGFloat(baseFraction)))
        }.strokedPath(StrokeStyle(lineWidth: 4, lineCap: .round))
    }
}

