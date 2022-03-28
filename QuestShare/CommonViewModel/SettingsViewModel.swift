//
//  SettingsViewModel.swift
//  QuestShare
//
//  Created by Karol Wojtas on 31/10/2021.
//

import Foundation
import Combine
import ARKit

class SettingsViewModel: ObservableObject, ViewModelLifecycle {
    static let ignoreDistanceKey = "ignoreDistance"
    static let rootNodeStatusKey = "rootNodeStatus"
    static let disableRootNodeTransformKey = "disableRootNodeTransform"
    static let disableRootNodeRotationKey = "disableRootNodeRotation"
    static let rootNodeVisibleKey = "rootNodeVisible"
    @Published var ignoreDistance = false
    @Published var rootNodeStatus = false
    @Published var disableRootNodeTransform = false
    /// deprecated since using .gravityAndHeadring
    @Published var disableRootNodeRotation = false
    @Published var rootNodeVisible = false
    let worldAlignment: ARConfiguration.WorldAlignment = .gravityAndHeading
    private var cancellables = Set<AnyCancellable>()
    
    func onAppear() {
        ignoreDistance = UserDefaults.standard.bool(forKey: SettingsViewModel.ignoreDistanceKey)
        settingsListener($ignoreDistance, key: Self.ignoreDistanceKey)
        
        rootNodeStatus = UserDefaults.standard.bool(forKey: SettingsViewModel.rootNodeStatusKey)
        settingsListener($rootNodeStatus, key: Self.rootNodeStatusKey)
        
        disableRootNodeTransform = UserDefaults.standard.bool(forKey: SettingsViewModel.disableRootNodeTransformKey)
        settingsListener($disableRootNodeTransform, key: Self.disableRootNodeTransformKey)
        
        disableRootNodeRotation = UserDefaults.standard.bool(forKey: SettingsViewModel.disableRootNodeRotationKey)
        settingsListener($disableRootNodeRotation, key: Self.disableRootNodeRotationKey)
        
        rootNodeVisible = UserDefaults.standard.bool(forKey: SettingsViewModel.rootNodeVisibleKey)
        settingsListener($rootNodeVisible, key: Self.rootNodeVisibleKey)
    }
    
    func onDisappear() {
        cancellables.forEach{$0.cancel()}
    }
    
    func settingsListener<T>(_ publisher: Published<T>.Publisher, key: String) {
        publisher
            .sink { value in
                UserDefaults.standard.set(value, forKey: key)
            }
            .store(in: &cancellables)
    }
    
    var snapshot: QSSettings {
        QSSettings(
            ignoreDistance: ignoreDistance,
            rootNodeStatus: rootNodeStatus,
            disableRootNodeTransform: disableRootNodeTransform,
            disableRootNodeRotation: disableRootNodeRotation,
            rootNodeVisible: rootNodeVisible,
            worldAlignment: worldAlignment
        )
    }
}

struct QSSettings {
    var ignoreDistance = false
    var rootNodeStatus = false
    var disableRootNodeTransform = false
    var disableRootNodeRotation = false
    var rootNodeVisible = false
    var worldAlignment: ARConfiguration.WorldAlignment = .gravity
}
