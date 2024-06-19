//
//  Model.swift
//  Minesweeper-AR
//
//  Created by zjucvglab509 on 2024/6/16.
//

enum GameStatus {
    case prepare
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
