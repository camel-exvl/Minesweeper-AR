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
    @ObservedObject var viewModel: ViewModel
    let arView: MinesweeperARView
    
    init() {
        let viewModel = ViewModel()
        self.viewModel = viewModel
        self.arView = MinesweeperARView(viewModel: viewModel, frame: .zero)
    }
    
    var body: some View {
        ZStack {
            ARViewContainer(viewModel: viewModel, arView: arView).edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    // title bar(remaing mines, restart button, time)
                    Text("💣 \(viewModel.remainingMines)")
                        .font(.title)
                        .padding()
                    Button(action: {
                        arView.initGame()
                    }) {
                        HStack {
                            Image(viewModel.smileImage)
                                .resizable()
                            .frame(width: 30, height: 30)}
                        .padding()
                        .background(Color.gray)
                    }
                    Text("⏱ \(viewModel.time)")
                        .font(.title)
                    .padding()}
                Spacer()
            }
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    let viewModel: ViewModel
    let arView: MinesweeperARView
    
    init(viewModel: ViewModel, arView: MinesweeperARView) {
        self.viewModel = viewModel
        self.arView = arView
    }
    
    func makeUIView(context: Context) -> ARView {
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
