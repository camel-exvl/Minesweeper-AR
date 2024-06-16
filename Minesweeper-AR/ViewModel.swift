//
//  ViewModel.swift
//  Minesweeper-AR
//
//  Created by zjucvglab509 on 2024/6/16.
//

class ViewModel {
    let gameSetting = GameSetting()
    var gameStatus: GameStatus = .ready
    var revealedTiles: Int = 0
    var allTileNum: Int = 0
    var tiles: [[TileData]] = []
    
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
    }
    
    func finishGame() {
        gameStatus = revealedTiles == allTileNum ? .win : .lose
    }
    
    func handleTap(tile: Tile) {
        if gameStatus != .playing && gameStatus != .ready {
            return
        }
        
        if tile.tile.isRevealed || tile.tile.isFlagged {
            return
        }
        if gameStatus == .ready {
            gameStatus = .playing
            // ensure the first tap is not a mine
            if tile.tile.isMine {
                (tile.parent as! Grid).generateAnotherMine(pos: tile.pos)
            }
        }
        revealedTiles += tile.reveal()
        if tile.tile.isMine {
            revealedTiles -= 1
        }
        if revealedTiles == allTileNum || tile.tile.isMine {
            self.finishGame()
        }
    }
}
