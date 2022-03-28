//
//  Extensions.swift
//  QuestShare
//
//  Created by Karol Wojtas on 12/10/2021.
//

import Foundation
import SwiftUI

extension Color {
    var asDoubleArray: [Double]? {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var o: CGFloat = 0
        guard UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &o) else {
            return nil
        }        
        return [Double(r), Double(g), Double(b), Double(o)]
    }
}
