//
//  Constants.swift
//  QuestShare
//
//  Created by Karol Wojtas on 30/04/2021.
//

import Foundation

struct TestData {
    static var collections: [QSCollection] = [
        QSCollection(name: "Test collection", desc: "Test collection description")
    ]
    
    static var nodes: [QSNode] = [
        QSNode(name: "Swan chair"),
        QSNode(name: "Retro TV"),
        QSNode(name: "Wheelbarrow"),
        QSNode(name: "No photo")
    ]
}
