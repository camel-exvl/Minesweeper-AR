//
//  MinesweeperARView.swift
//  Minesweeper-AR
//
//  Created by zjucvglab509 on 2024/6/11.
//

import RealityKit
import ARKit
import Combine

class MinesweeperARView: ARView, ARSessionDelegate {
    let coachingOverlay = ARCoachingOverlayView()
    let viewModel: ViewModel
    
    var waitForAnchor: Cancellable?
    
    init(viewModel: ViewModel, frame frameRect: CGRect) {
        self.viewModel = viewModel
        super.init(frame: frameRect)
    }
    
    @MainActor required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @MainActor required dynamic init(frame frameRect: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
    func initGame() {
        viewModel.initGame()
        showGrid()
    }
    
    func showGrid() {
        self.scene.anchors.removeAll()
        let grid = Grid(viewModel: viewModel)
        grid.minimumBounds = [0.5, 0.5]
        
        self.waitForAnchor = self.scene.subscribe(to: SceneEvents.AnchoredStateChanged.self, on: grid) { event in
            if event.isAnchored {
                DispatchQueue.main.async {
                    self.waitForAnchor?.cancel()
                    self.waitForAnchor = nil
                }
            }
        }
        self.scene.anchors.append(grid)
    }
    
    func finishGame() {
        (self.scene.anchors[0] as! Grid).finish(win: viewModel.gameStatus == .win)
    }
}
