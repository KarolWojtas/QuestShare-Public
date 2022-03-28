//
//  ARScene.swift
//  QuestShare
//
//  Created by Karol Wojtas on 24/08/2021.
//

import Foundation
import SwiftUI
import SceneKit
import ARKit

struct ARScene: UIViewRepresentable {
    
    typealias UIViewType = ARSCNView
    var sceneVM: LocationSceneViewModel
    var readonly = false
    @EnvironmentObject var settingsVM: SettingsViewModel
    
    func makeCoordinator() -> ARScene.Coordinator {
        ARScene.Coordinator(parent: self, sceneVM: sceneVM, readonly: readonly, settings: settingsVM.snapshot)
    }
    
    func makeUIView(context: Context) -> ARSCNView {
        let sceneView = ARSCNView()
        context.coordinator.sceneView = sceneView
        // Set the view's delegate
        sceneView.delegate = context.coordinator
        
        // Show statistics such as fps and timing information
        // sceneView.showsStatistics = true
        // sceneView.debugOptions = [.showFeaturePoints, .showWorldOrigin]
        
        // Create a new scene
        let scene = SCNScene()
        // Set the scene to the view
        sceneView.scene = scene
        
        sceneView.automaticallyUpdatesLighting = true
        sceneView.autoenablesDefaultLighting = true
        let configuration = ARWorldTrackingConfiguration()
        configuration.environmentTexturing = .automatic
        configuration.planeDetection = .horizontal
        configuration.worldAlignment = settingsVM.worldAlignment
        sceneView.session.run(configuration)
        
        context.coordinator.initNodeEventListener();
        context.coordinator.addCoaching()
        context.coordinator.addGestureRecognizers()
        return sceneView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {
        
    }
}
