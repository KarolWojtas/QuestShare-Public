//
//  RepeatingShake.swift
//  QuestShare
//
//  Created by Karol Wojtas on 04/05/2021.
//

import SwiftUI
import Combine

struct RepeatingShake<Content: View>: View {
    @State private var rotation = 0.0
    var content: Content
    var disabled: Bool
    var duration = 0.5
    var angle: Double = 5
    
    let timer: Publishers.Autoconnect<Timer.TimerPublisher>
    
    var deleteAnimation: Animation {
        Animation.linear(duration: 0.5)
            .repeatForever(autoreverses: true)
    }
    
    init(duration: Double = 0.5,
         angle: Double = 5,
         disabled: Bool = false,
         @ViewBuilder content: () -> Content){
        self.duration = duration
        self.angle = angle
        self.disabled = disabled
        self.content = content()
        self.timer = Timer.publish(every: duration, on: .main, in: .common).autoconnect()
    }
    var body: some View {
        content
            .rotationEffect(Angle(degrees: rotation))
            .onReceive(timer, perform: { _ in
                if(!disabled){                                        
                    withAnimation {
                        rotation = rotation.isLess(than: 0.0) ? angle : -angle
                    }
                } else if (rotation != 0){
                    rotation = 0
                    timer.upstream.connect().cancel()
                }
            })
    }
}

struct RepeatingShake_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            RepeatingShake (disabled: false){
                Image(systemName: "trash")
                    .font(.system(size: 40))
            }
        }
    }
}
