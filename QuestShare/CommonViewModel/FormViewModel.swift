//
//  FormViewModel.swift
//  QuestShare
//
//  Created by Karol Wojtas on 22/06/2021.
//

import Foundation
import Combine

protocol FormViewModel {
    var requiredFields: [KeyPath<Self, String>]? { get }
    func validate() -> Bool
}

extension FormViewModel {
    var requiredFields$: [KeyPath<Self, Published<String>>]? {
        nil
    }
    // todo maybe return invalid keypaths?
    func validate() -> Bool {
        if let safeRequiredFields = requiredFields {
            for path in safeRequiredFields {
                if self[keyPath: path].isEmpty {
                    return false
                }
            }
            return true
        } else {
            return true
        }
    }
}
