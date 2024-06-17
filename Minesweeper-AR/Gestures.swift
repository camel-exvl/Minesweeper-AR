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
        if viewModel.gameStatus != .ready && viewModel.gameStatus != .playing {
            return
        }
        if sender?.state == .ended {
            viewModel.smileImage = "smile_click"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if self.viewModel.gameStatus == .ready || self.viewModel.gameStatus == .playing {
                    self.viewModel.smileImage = "smile"
                }
            }
        }
        guard let touchInView = sender?.location(in: self) else { return }
        guard let tile = self.entity(at: touchInView) as? Tile else { return }
        
        viewModel.handleTap(tile: tile)
        if viewModel.gameStatus == .win || viewModel.gameStatus == .lose {
            self.finishGame()
        }
    }
    
    @objc func handleLongPress(_ sender: UILongPressGestureRecognizer? = nil) {
        if viewModel.gameStatus != .ready && viewModel.gameStatus != .playing {
            return
        }
        if sender?.state == .began {
            viewModel.smileImage = "smile_click"
        } else if sender?.state == .ended {
            viewModel.smileImage = "smile"
        }
        if sender?.state != .began || viewModel.gameStatus != .playing {
            return
        }
        guard let touchInView = sender?.location(in: self) else { return }
        guard let tile = self.entity(at: touchInView) as? Tile else { return }
        
        if tile.tile.isRevealed {
            return
        }
        if tile.tile.isFlagged {
            viewModel.remainingMines += 1
        } else {
            viewModel.remainingMines -= 1
        }
        tile.longPress()
    }
}
