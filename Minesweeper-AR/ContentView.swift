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
    @State var difficultySelection = 0
    
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
                    HStack {
                        Image(systemName: "clock")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.blue)
                        Text("\(viewModel.time)")
                            .font(.title)
                    }.padding()
                    Picker(
                        selection: $difficultySelection,
                        label: Text("Difficulty")) {
                            Text("Easy").tag(0)
                            Text("Medium").tag(1)
                            Text("Hard").tag(2)
                        }.onChange(of: difficultySelection) { oldValue, newValue in
                            switch newValue {
                            case 0:
                                viewModel.gameSetting = GameSetting(rows: 9, columns: 9, mines: 10)
                            case 1:
                                viewModel.gameSetting = GameSetting(rows: 16, columns: 16, mines: 40)
                            case 2:
                                viewModel.gameSetting = GameSetting(rows: 16, columns: 30, mines: 99)
                            default:
                                break
                            }
                            arView.initGame()
                        }
                }
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
