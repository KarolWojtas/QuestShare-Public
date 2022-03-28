//
//  UIKitAppear.swift
//  QuestShare
//
//  Created by Karol Wojtas on 10/10/2021.
//

import Foundation
import SwiftUI

struct UIKitAppear: UIViewControllerRepresentable {
    let action: () -> Void
    
    func makeUIViewController(context: Context) -> UIAppearViewController {
       let vc = UIAppearViewController()
        vc.action = action
        return vc
    }
    
    func updateUIViewController(_ controller: UIAppearViewController, context: Context) {
        controller.action = action
    }
}

class UIAppearViewController: UIViewController {
    var action: (() -> Void)? = nil

    override func viewDidAppear(_ animated: Bool) {
        if let safeAction = action {
            safeAction()
        }
    }
}

public extension View {
    func onUIKitAppear(perform: @escaping () -> Void) -> some View {
        self.background(UIKitAppear(action: perform))
    }
}
