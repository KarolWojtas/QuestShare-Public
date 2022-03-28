//
//  ReadonlyHide.swift
//  QuestShare
//
//  Created by Karol Wojtas on 18/10/2021.
//

import Foundation
import SwiftUI

struct ReadonlyHide: ViewModifier {
    @Environment(\.readonly) var readonly
    func body(content: Content) -> some View {
        if !readonly {
            content
        }
    }
}

extension View {
    func readonlyHide() -> some View {
        self.modifier(ReadonlyHide())
    }
}
