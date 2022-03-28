//
//  ModalTitle.swift
//  QuestShare
//
//  Created by Karol Wojtas on 18/08/2021.
//

import Foundation
import SwiftUI

extension Text {
    func modalTitle() -> some View {
        self.font(.title)
            .fontWeight(.semibold)
            .background(TextHighlight())
            .padding(.top, 8)
    }
}
