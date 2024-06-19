//
//  ViewModel.swift
//  Minesweeper-AR
//
//  Created by zjucvglab509 on 2024/6/16.
//

import Foundation
import SwiftUI

class ViewModel: ObservableObject {
    var gameSetting = GameSetting()
    var gameStatus: GameStatus = .ready
    var revealedTiles: Int = 0
    var allTileNum: Int = 0
    var tiles: [[TileData]] = []
    @Published var time = 0
    @Published var remainingMines = 0
    @Published var smileImage = "smile"
    @Published var showHelp = false
    
    func initGame() {
        gameStatus = .prepare
        smileImage = "smile"
        time = 0
        remainingMines = gameSetting.mines
        revealedTiles = 0
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
    }
    
    func finishGame() {
        gameStatus = revealedTiles == allTileNum ? .win : .lose
        smileImage = gameStatus == .win ? "smile_win" : "smile_lose"
        if gameStatus == .win {
            remainingMines = 0
        }
    }
    
    func handleTap(tile: Tile) {
        if gameStatus != .playing && gameStatus != .ready {
            return
        }
        
        if tile.tile.isFlagged {
            return
        }
        if gameStatus == .ready {
            gameStatus = .playing
            // ensure the first tap is not a mine
            if tile.tile.isMine {
                (tile.parent as! Grid).generateAnotherMine(pos: tile.pos)
            }
            // start timer
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                self.time += 1
                if self.gameStatus != .playing {
                    timer.invalidate()
                }
            }
        }
        let res = tile.tile.isRevealed ? (tile.parent as! Grid).safeNeighbors(of: tile) : tile.reveal()
        revealedTiles += res.0
        if revealedTiles == allTileNum || res.1 {
            self.finishGame()
        }
    }
}
