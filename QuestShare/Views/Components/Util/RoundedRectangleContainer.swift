//
//  RoundedRectangleContainer.swift
//  QuestShare
//
//  Created by Karol Wojtas on 27/05/2021.
//

import SwiftUI

struct RoundedRectangleContainer<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading){
                content
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.thickMaterial)
            )
        }
    }
}

struct RoundedRectangleContainer_Previews: PreviewProvider {
    static var previews: some View {
        RoundedRectangleContainer{
            Text("Hello")
        }
    }
}
