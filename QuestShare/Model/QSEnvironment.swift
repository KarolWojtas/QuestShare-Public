//
//  QSEnvironment.swift
//  QuestShare
//
//  Created by Karol Wojtas on 25/09/2021.
//

import Foundation
import SwiftUI

private struct QSReadonlyKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var readonly: Bool {
        get {
            self[QSReadonlyKey.self]
        }
        set {
            self[QSReadonlyKey.self] = newValue
        }
    }
}
