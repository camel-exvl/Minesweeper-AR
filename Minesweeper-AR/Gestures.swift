//
//  Gestures.swift
//  Minesweeper-AR
//
//  Created by zjucvglab509 on 2024/6/14.
//

import SwiftUI

extension MinesweeperARView {
    func setupGestures() {
      let tap = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(_:)))
      self.addGestureRecognizer(tap)
    }
    
    @objc func handleLongPress(_ sender: UILongPressGestureRecognizer? = nil) {
        if sender?.state != .began {
            return
        }
        guard let touchInView = sender?.location(in: self) else { return }
        guard let tile = self.entity(at: touchInView) as? Tile else { return }
        
        if tile.tile.isRevealed {
            return
        }
        tile.flag()
    }
}
