//
//  Grid.swift
//  Minesweeper-AR
//
//  Created by zjucvglab509 on 2024/6/14.
//

import RealityKit

class Grid: Entity, HasModel, HasAnchoring {
    let data: [[TileData]]
    // set bounds and scale
    var minimumBounds: SIMD2<Float>? = nil {
      didSet {
        guard let bounds = minimumBounds else {
          return
        }
        let anchorPlane = AnchoringComponent.Target.plane(
          .horizontal,
          classification: .any,
          minimumBounds: bounds)
        let anchorComponent = AnchoringComponent(anchorPlane)

        self.anchoring = anchorComponent

        let maxDim = max(data.count, data[0].count)
        let minBound = bounds.min()
        self.scale = SIMD3<Float>(repeating: minBound / Float(maxDim))
      }
    }
    
    init(data: [[TileData]]) {
        self.data = data
        super.init()
        for i in 0..<data.count {
            for j in 0..<data[i].count {
                let tile = Tile(pos: SIMD2(i, j), tile: data[i][j])
                tile.scale = [0.9, 0.9, 0.9]
                tile.position = [Float(j) - Float(data[i].count - 1) / 2, 0, Float(i) - Float(data.count - 1) / 2]
                self.addChild(tile)
            }
        }
    }
    
    func revealNeighbors(of tile: Tile) {
        let x = tile.pos.x
        let y = tile.pos.y
        for i in -1...1 {
            for j in -1...1 {
                let newX = x + i
                let newY = y + j
                if newX < 0 || newX >= data.count || newY < 0 || newY >= data[0].count {
                    continue
                }
                let neighbor = self.children[(newX * data[0].count) + newY] as! Tile
                if !neighbor.tile.isRevealed && !neighbor.tile.isFlagged {
                    neighbor.reveal()
                }
            }
        }
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
}
