//
//  TextHighlight.swift
//  QuestShare
//
//  Created by Karol Wojtas on 10/07/2021.
//

import SwiftUI

struct TextHighlight: View {
    var body: some View {
        TextHighlightShape()
            .foregroundColor(.green.opacity(0.75))
    }
}

struct TextHighlight_Previews: PreviewProvider {
    static var previews: some View {
        Text("Some text")
            .font(.title)
            .fontWeight(.semibold)
            .background(TextHighlight())
            .preferredColorScheme(.dark)
    }
}

struct TextHighlightShape: Shape {
    let heightModifier: CGFloat = 2.2
    let heightOffset: CGFloat = 1.55
    func path(in rect: CGRect) -> Path {
        Path { p in
            let shapeRect = CGRect(x: 6, y: rect.height / heightOffset, width: rect.width, height: rect.height / heightModifier)
            p.addRoundedRect(in: shapeRect, cornerSize: CGSize(width: 4.0, height: 8.0))
        }
    }
}
