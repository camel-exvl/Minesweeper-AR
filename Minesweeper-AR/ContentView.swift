//
//  ContentView.swift
//  Minesweeper-AR
//
//  Created by zjucvglab509 on 2024/6/10.
//

import SwiftUI
import RealityKit
import ARKit

struct ContentView : View {
    let viewModel = ViewModel()
    
    var body: some View {
        ARViewContainer(viewModel: viewModel).edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    let viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    func makeUIView(context: Context) -> ARView {
        let arView = MinesweeperARView(viewModel: viewModel, frame: .zero)
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        arView.session.run(config, options: [])
        
        arView.addCoaching()
        arView.setupGestures()
        arView.session.delegate = arView
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
}

#Preview {
    ContentView()
}
