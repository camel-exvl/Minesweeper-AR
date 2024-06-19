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
                ZStack {
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
                    }
                    HStack {
                        Picker(
                            selection: $difficultySelection,
                            label: Text("Difficulty")) {
                                Text("Easy").tag(0)
                                Text("Medium").tag(1)
                                Text("Hard").tag(2)
                            }.onChange(of: difficultySelection) { newValue in
                                switch newValue {
                                case 0:
                                    viewModel.gameSetting = GameSetting(rows: 9, columns: 9, mines: 10)
                                case 1:
                                    viewModel.gameSetting = GameSetting(rows: 12, columns: 12, mines: 25)
                                case 2:
                                    viewModel.gameSetting = GameSetting(rows: 16, columns: 16, mines: 40)
                                default:
                                    break
                                }
                                arView.initGame()
                            }.padding()
                        Spacer()
                        Button(action: {
                            viewModel.showHelp = true
                        }) {
                            Text("Help")
                                .padding()
                        }
                    }
                }
                Spacer()
            }
        }.sheet(isPresented: $viewModel.showHelp) {
            HelpView(viewModel: viewModel)
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

struct HelpView: View {
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        VStack {
            Text("Minesweeper AR")
                .font(.title)
                .padding()
            
            HStack {
                Text("First, Find a flat surface to place the game and start.")
                    .font(.title3)
                    .padding()
                Spacer()
            }
            
            HStack {
                Text("Tap square to reveal it. If a number appears, it tells you how many mines are in the eight squares that surround the numbered square.")
                    .font(.title3)
                    .padding()
                Spacer()
            }
            
            HStack {
                Text("If you think a square might have a mine, tap and hold it for a second to place a flag. Tap and hold again to remove the flag.")
                    .font(.title3)
                    .padding()
                Spacer()
            }
            
            HStack {
                Text("You can tap a numbered square with the correct number of flags around it to reveal the remaining squares.")
                    .font(.title3)
                    .padding()
                Spacer()
            }
            
            HStack {
                Text("If you reveal a mine, the game is over. If you reveal all the squares that don't have mines, you win.")
                    .font(.title3)
                    .padding()
                Spacer()
            }
            
            HStack {
                Text("You can tap the smiley face to restart the game.")
                    .font(.title3)
                    .padding()
                Spacer()
            }
            
            Spacer()
        }
    }
}

#Preview {
    ContentView()
}
