//
//  ButtonGroup.swift
//  QuestShare
//
//  Created by Karol Wojtas on 20/07/2021.
//

import SwiftUI

struct ButtonGroup<Content: View>: View {
    let content: [Content]
    
    init(_ content: [Content]) {
        self.content = content
    }
    
    var body: some View {
        HStack(alignment: .center) {
            ForEach(0..<content.count) { index in
                content[index]
                    .foregroundColor(.white)
                if index < (content.count - 1) {
                    Divider()
                        .background(Color.white)
                }
            }
        }
        .frame(height: 44)
        .padding(.horizontal)
        .background(Color.purple)
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 16.0, height: 8.0)))
    }
}

struct ButtonGroup_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            ButtonGroup(items)
        }
    }
    
    static var items: [AnyView] {
        [
            AnyView(Button("hello"){}),
            AnyView(Button("hello 2"){}),
            AnyView(NavigationLink("hello 3", destination: EmptyView()))
        ]
    }
}
