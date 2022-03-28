//
//  CircleButton.swift
//  QuestShare
//
//  Created by Karol Wojtas on 18/08/2021.
//

import SwiftUI

struct CircleButton: View {
    var icon: String
    var size = CircleButtonSize.small
    var color = Color.gray
    var onTap: () -> Void
    
    var body: some View {
        Button(action : onTap){
            Image(systemName: icon)
                .foregroundColor(.black)
                .padding(size.rawValue)
        }
        .background(
            Circle()
                .foregroundColor(color.opacity(0.8))
        )
    }
    
    enum CircleButtonSize: CGFloat {
        case small = 4.0
        case medium = 8.0
    }
}

struct CircleButton_Previews: PreviewProvider {
    static var previews: some View {
        CircleButton(icon: "xmark", onTap: {})
    }
}
