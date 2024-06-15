//
//  MinesweeperARView.swift
//  Minesweeper-AR
//
//  Created by zjucvglab509 on 2024/6/11.
//

import RealityKit
import ARKit
import Combine

enum GameStatus {
    case playing
    case win
    case lose
}

struct GameSetting {
    var rows: Int = 9
    var columns: Int = 9
    var mines: Int = 10
}

struct TileData {
    var isRevealed: Bool = false
    var isMine: Bool = false
    var isFlagged: Bool = false
    var minesAround: Int = 0
}

class MinesweeperARView: ARView, ARSessionDelegate {
    let coachingOverlay = ARCoachingOverlayView()
    let gameSetting = GameSetting()
    var gameStatus: GameStatus = .playing
    var revealedTiles: Int = 0
    var allTileNum: Int = 0
    var tiles: [[TileData]] = []
    
    var waitForAnchor: Cancellable?
    
    func initGame() {
        allTileNum = gameSetting.rows * gameSetting.columns - gameSetting.mines
        tiles = Array(repeating: Array(repeating: TileData(), count: gameSetting.columns), count: gameSetting.rows)
        for _ in 0..<gameSetting.mines {
            var row = Int.random(in: 0..<gameSetting.rows)
            var column = Int.random(in: 0..<gameSetting.columns)
            while tiles[row][column].isMine {
                row = Int.random(in: 0..<gameSetting.rows)
                column = Int.random(in: 0..<gameSetting.columns)
            }
            tiles[row][column].isMine = true
            for i in -1...1 {
                for j in -1...1 {
                    if row + i >= 0 && row + i < gameSetting.rows && column + j >= 0 && column + j < gameSetting.columns {
                        tiles[row + i][column + j].minesAround += 1
                    }
                }
            }
        }
        showGrid()
    }
    
    func showGrid() {
        self.scene.anchors.removeAll()
        let grid = Grid(data: tiles)
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
        gameStatus = revealedTiles == allTileNum ? .win : .lose
        (self.scene.anchors[0] as! Grid).finish(win: gameStatus == .win)
    }
}
