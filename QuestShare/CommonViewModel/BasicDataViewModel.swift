//
//  BasicDataViewModel.swift
//  QuestShare
//
//  Created by Karol Wojtas on 22/06/2021.
//

import Foundation
import Combine

final class BasicDataViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var desc: String = ""
    
    @Published var isNameValid = false
    @Published var namePrompt: String? = nil
    
    var cancellables: Set<AnyCancellable> = []
    
    init() {
        $name
            .map{!$0.isEmpty}
            .assign(to: \.isNameValid, on: self)
            .store(in: &cancellables)
        $isNameValid
            .map{$0 ? nil : "name-required-prompt"}
            .assign(to: \.namePrompt, on: self)
            .store(in: &cancellables)
    }
    
    deinit {
        for cancellable in cancellables {
            cancellable.cancel()
        }
    }
}
