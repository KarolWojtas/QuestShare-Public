//
//  ExpandableWithIndicator.swift
//  QuestShare
//
//  Created by Karol Wojtas on 30/04/2021.
//

import SwiftUI

struct ExpandableWithHandleConstants {
    static let mainAnimation: Animation = .easeInOut(duration: 0.2)
    fileprivate static let indicatorHeight: CGFloat = 8.0
    fileprivate static let padding: CGFloat = 12.0
}

struct ExpandableWithHandle<Content: View>: View {
    let content: Content
    @Binding var isOpen: Bool
    var maxHeight: CGFloat?
    var width: CGFloat
    
    init(isOpen: Binding<Bool>, maxHeight: CGFloat?, width: CGFloat, @ViewBuilder content: () -> Content) {
        self.content = content()
        self._isOpen = isOpen
        self.maxHeight = maxHeight
        self.width = width
    }
    private var indicator: some View {
        ExpandableHandleArrow(pointingUpward: !isOpen)
            .animation(ExpandableWithHandleConstants.mainAnimation, value: isOpen)
            .frame(width: 40, height: ExpandableWithHandleConstants.indicatorHeight)
        
    }
    
    var maxHeightWithPadding: CGFloat {
        if let safeMaxHeight = maxHeight {
            return safeMaxHeight + ExpandableWithHandleConstants.padding + ExpandableWithHandleConstants.indicatorHeight
        } else {
            return .zero
        }
    }
    
    var body: some View {
        VStack (alignment: .center){
            HStack {
                Spacer()
                self.indicator
                    .padding(.top, ExpandableWithHandleConstants.padding)
                Spacer()
            }
            .contentShape(Rectangle())
            .frame(width: width)
            .onTapGesture {
                self.isOpen.toggle()
            }
            GeometryReader { geometry in
                self.content
                    .frame(width: geometry.size.width)
                    .opacity(isOpen ? 1 : 0)
                    .animation(ExpandableWithHandleConstants.mainAnimation, value: isOpen)
            }
        }
        .background(Color(.secondarySystemBackground))
         .cornerRadius(8.0)
        .frame(width: width,
               height: self.isOpen ? maxHeightWithPadding : .zero, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        .animation(ExpandableWithHandleConstants.mainAnimation, value: isOpen)
    }
}

struct ExpandableWithIndicator_Previews: PreviewProvider {
    @State static var isOpen = false
    static var previews: some View {
        ExpandableWithHandle(isOpen: $isOpen, maxHeight: CGFloat(200.0), width: .infinity){
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.yellow)
                .frame(
                    width: .infinity,
                    height: CGFloat(200.0)
                )
                .animation(.interactiveSpring(), value: isOpen)
        }
    }
}
