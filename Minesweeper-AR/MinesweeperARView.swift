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
    case ready
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
    var gameStatus: GameStatus = .ready
    var revealedTiles: Int = 0
    var allTileNum: Int = 0
    var tiles: [[TileData]] = []
    
    var waitForAnchor: Cancellable?
    
    func initGame() {
        allTileNum = gameSetting.rows * gameSetting.columns - gameSetting.mines
        tiles = Array(repeating: Array(repeating: TileData(), count: gameSetting.columns), count: gameSetting.rows)
        
        // generate mines
        var positions = Array(0..<gameSetting.rows * gameSetting.columns)
        for i in 0..<gameSetting.mines {
            let j = Int.random(in: i..<positions.count)
            positions.swapAt(i, j)
        }
        
        for i in 0..<gameSetting.mines {
            let (row, column) = (positions[i] / gameSetting.columns, positions[i] % gameSetting.columns)
            tiles[row][column].isMine = true
            for x in -1...1 {
                for y in -1...1 {
                    if x == 0 && y == 0 {
                        continue
                    }
                    let newRow = row + x
                    let newColumn = column + y
                    if newRow >= 0 && newRow < gameSetting.rows && newColumn >= 0 && newColumn < gameSetting.columns {
                        tiles[newRow][newColumn].minesAround += 1
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
