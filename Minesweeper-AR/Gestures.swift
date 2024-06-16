//
//  Gestures.swift
//  Minesweeper-AR
//
//  Created by zjucvglab509 on 2024/6/14.
//

import SwiftUI

extension MinesweeperARView {
    func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(_:)))
        self.addGestureRecognizer(tap)
        self.addGestureRecognizer(longPress)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        guard let touchInView = sender?.location(in: self) else { return }
        guard let tile = self.entity(at: touchInView) as? Tile else { return }
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
    
    @objc func handleLongPress(_ sender: UILongPressGestureRecognizer? = nil) {
        if sender?.state != .began || gameStatus != .playing {
            return
        }
        guard let touchInView = sender?.location(in: self) else { return }
        guard let tile = self.entity(at: touchInView) as? Tile else { return }
        
        if tile.tile.isRevealed {
            return
        }
        tile.longPress()
    }
}
